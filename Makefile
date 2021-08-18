appinsight = udacity-app-insights
group = acdnd-c4-project
user = udacityadmin
autoscale = udacityas
workspace = udacityworkspace
registry = thomdacr
actiongroup = udacity-action-group
alert = udacity-alert
automationaccount = udacity-automation
runbook = udacity-runbook


random := $(shell bash -c 'echo $$RANDOM')

vmss:
	./setup-script.sh
	az monitor log-analytics workspace create -g $(group) -n $(workspace)$(random)
	az monitor app-insights component create -g $(group) -l westus2 -a $(appinsight) --workspace $(workspace)$(random)
	@echo "ENABLE VM-INSIGHTS IN THE AZURE PORTAL USING WORKSPACE $(workspace)$(random)"

deploy:
	git checkout Deploy_to_VMSS
	$(eval vmssname = $(shell az vmss list -g $(group) --query '[].name' -o tsv))
	$(eval instrkey = $(shell az monitor app-insights component show -a $(appinsight) -g $(group) --query 'instrumentationKey' -o tsv))
	echo $(instrkey)
	cat azure-vote/main.py | perl -pe "s/^(APPLICATION_INSIGHTS_INTRUMENTATION_KEY = \"InstrumentationKey)=.*\"/\1=$(instrkey)\"/g" > tmp; mv tmp azure-vote/main.py
	cat azure-vote/main.py | perl -pe 's/^    (app\.run.+local)/    # \1/g' > tmp; mv tmp azure-vote/main.py
	cat azure-vote/main.py | perl -pe 's/^    # (app\.run.+remote)/    \1/g' > tmp; mv tmp azure-vote/main.py
	git add azure-vote/main.py
	git ci -m "update instrumentation key"
	git push
	$(eval instances = $(shell az vmss list-instance-connection-info -g $(group) -n $(vmssname) -o tsv))
	for instance in $(instances); do \
		ssh -o StrictHostKeyChecking=no $(user)@$${instance%%:*} -p $${instance##*:} 'bash -s' < deploy-vote-app.sh; \
	done

vmss-autoscale:
	$(eval vmssname = $(shell az vmss list -g $(group) --query '[].name' -o tsv))
	az monitor autoscale create -g $(group) -n $(autoscale) --resource $(vmssname) --min-count 2 --max-count 10 --count 2 --resource-type Microsoft.Compute/virtualMachineScaleSets
	az monitor autoscale rule create -g $(group) --autoscale-name $(autoscale) --condition "Percentage CPU > 70 avg 5m" --scale out 3
	az monitor autoscale rule create -g $(group) --autoscale-name $(autoscale) --condition "Percentage CPU < 30 avg 5m" --scale in 1
	$(eval instances = $(shell az vmss list-instance-connection-info -g $(group) -n $(vmssname) -o tsv))
	for instance in $(instances); do \
		ssh -o StrictHostKeyChecking=no $(user)@$${instance%%:*} -p $${instance##*:} 'bash -s' < create-vmss-load.sh; \
	done
	watch -n 30 az vmss list-instances -g $(group) -n $(vmssname) -o table

runbook:
	az automation account create -n $(automationaccount) -g $(group) --sku Basic
	az automation runbook create -n $(runbook) -g $(group) --automation-account-name $(automationaccount) --type Script
	cat runbook.ps1 | perl -pe 's/<runbook>/$(runbook)/g' > tmp; mv tmp runbook.ps1
	az automation runbook replace-content -n $(runbook) -g $(group) --automation-account-name $(automationaccount) --content @runbook.ps1
	az automation runbook publish -n $(runbook) -g $(group) --automation-account-name $(automationaccount)
	az monitor action-group create -g $(group) -n $(actiongroup) -a email udacity thomas.duerr@arvato-scs.com
	$(eval vmssname = $(shell az vmss list -g $(group) --query '[].name' -o tsv))
	$(eval scope = $(shell az vmss show -g $(group) -n $(vmssname) --query id -o tsv))
	az monitor metrics alert create -g $(group) -n $(alert) --action $(actiongroup) --scopes $(scope) --description "scale up vmss" --condition "avg Percentage CPU > 20" --window-size 1m
	@echo "NOW, EXTEND IN TEH PORTAL THE ACTION GROUP $(actiongroup) WITH AN ACTION OF TYPE 'Automation Runbook' AND THE RUNBOOK $(runbook)"

aks:
	./create-cluster.sh
	az acr create -g $(group) -n $(registry) --sku Basic --admin-enabled true
	az acr login -n $(registry)
	git checkout Deploy_to_AKS
	$(eval instrkey = $(shell az monitor app-insights component show -a $(appinsight) -g $(group) --query 'instrumentationKey' -o tsv))
	echo $(instrkey)
	cat azure-vote/main.py | perl -pe "s/^(APPLICATION_INSIGHTS_INTRUMENTATION_KEY = \"InstrumentationKey)=.*\"/\1=$(instrkey)\"/g" > tmp; mv tmp azure-vote/main.py
	git add azure-vote/main.py
	git ci -m "update instrumentation key"
	git push
	docker build -t azure-vote-front ./azure-vote
	docker tag azure-vote-front:v1 $(registry).azurecr.io/azure-vote-front:v1
	docker push $(registry).azurecr.io/azure-vote-front:v1
	az aks update -n udacity-cluster -g $(group) --attach-acr $(registry)
	kubectl apply -f azure-vote-all-in-one-redis.yaml
	kubectl get service azure-vote-front --watch

aks-autoscale:
	az monitor action-group create -n $(actiongroup) -g $(group) -a email udacity thomas.duerr@arvato-scs.com
	$(eval aksname = $(shell az aks list -g $(group) --query '[].name' -o tsv))
	$(eval scope = $(shell az aks show -g $(group) -n $(aksname) --query id -o tsv))
	$(eval alertdimension = $(shell az monitor metrics alert dimension create -n "Kubernetes namespace" --op Include -v Default -o tsv))
	$(eval alertcondition = $(shell az monitor metrics alert condition create -t static --aggregation "Average" --metric "podCount"  --op "GreaterThan" --threshold 3.0 --dimension $(alertdimension) -o tsv))
	az monitor metrics alert create -n $(alert) -g $(group) --scopes $(scope) -a $(actiongroup) --condition $(alertcondition) --window-size 1m --evaluation-frequency 1m --description "POD Count"
	kubectl autoscale deployment azure-vote-front --cpu-percent=30 --min=1 --max=10
	kubectl describe hpa azure-vote-front

clean:
	$(eval groups = $(shell az group list --query '[].name' -o tsv))
	@for group in $(groups); do \
		echo deleting group $${group}; \
		az group delete -n $${group} -y; \
	done

