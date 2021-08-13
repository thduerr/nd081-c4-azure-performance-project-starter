appinsight = udacity-app-insights
group = acdnd-c4-project
user = udacityadmin
autoscale = udacityas
workspace = udacityworkspace
registry = thomdacr
random := $(shell bash -c 'echo $$RANDOM')

vmss:
	./setup-script.sh
	az monitor log-analytics workspace create -g $(group) -n $(workspace)$(random)
	az monitor app-insights component create -g $(group) -l westus2 -a $(appinsight) --workspace $(workspace)$(random)
	@echo "ENABLE VM-INSIGHTS IN THE AZURE PORTAL"

update-instrumentationkey:
	$(eval vmssname = $(shell az vmss list -g $(group) --query '[].name' -o tsv))
	$(eval instrkey = $(shell az monitor app-insights component show -a $(appinsight) -g $(group) --query 'instrumentationKey' -o tsv))
	echo $(instrkey)
	cat azure-vote/main.py | perl -pe "s/^(APPLICATION_INSIGHTS_INTRUMENTATION_KEY = \"InstrumentationKey)=.*\"/\1=$(instrkey)\"/g" > tmp; mv tmp azure-vote/main.py
	cat azure-vote/main.py | perl -pe 's/^    (app\.run.+local)/    # \1/g' > tmp; mv tmp azure-vote/main.py
	cat azure-vote/main.py | perl -pe 's/^    # (app\.run.+remote)/    \1/g' > tmp; mv tmp azure-vote/main.py

push-to-github:
	git checkout Deploy_to_VMSS
	git add azure-vote/main.py
	git ci -m "update instrumentation key"
	git push

deploy: update-instrumentationkey push-to-github
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

aks:
	./create-cluster.sh
	az acr create -g $(group) -n $(registry) --sku Basic --admin-enabled true
	az acr login -n $(registry)
	docker build -t azure-vote-front ./azure-vote
	docker tag azure-vote-front:v1 $(registry).azurecr.io/azure-vote-front:v1
	docker push $(registry).azurecr.io/azure-vote-front:v1
	az aks update -n udacity-cluster -g $(group) --attach-acr $(registry)
	kubectl apply -f azure-vote-all-in-one-redis.yaml
	kubectl get service azure-vote-front --watch

aks-autoscale:
	kubectl autoscale deployment azure-vote-front --cpu-percent=30 --min=1 --max=10

clean:
	$(eval groups = $(shell az group list --query '[].name' -o tsv))
	@for group in $(groups); do \
		echo deleting group $${group}; \
		az group delete -n $${group} -y; \
	done

