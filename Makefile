appinsight = udacity-app-insights
group = acdnd-c4-project
user = udacityadmin
analyticsworkspace = udacityworkspace
autoscale = udacityas

vmss:
	./setup-script.sh
	az monitor log-analytics workspace create -g $(group) -n $(analyticsworkspace)
	az monitor app-insights component create -a $(appinsight) -l westus2 -g $(group) --workspace $(analyticsworkspace)
	az monitor autoscale create -g $(group) -n $(autoscale) --resource udacity-vmss --min-count 2 --max-count 10 --count 2 --resource-type Microsoft.Compute/virtualMachineScaleSets
	az monitor autoscale rule create -g $(group) --autoscale-name $(autoscale) --condition "Percentage CPU > 70 avg 5m" --scale out 3
	az monitor autoscale rule create -g $(group) --autoscale-name $(autoscale) --condition "Percentage CPU < 30 avg 5m" --scale in 1

vmss-deploy:
	$(eval instrkey = $(shell az monitor app-insights component show -a $(appinsight) -g $(group) --query 'instrumentationKey' -o tsv))
	echo $(instrkey)
	cat azure-vote/main.py | perl -pe "s/^(APPLICATION_INSIGHTS_INTRUMENTATION_KEY = \"InstrumentationKey)=.*\"/\1=$(instrkey)\"/g" > tmp; mv tmp azure-vote/main.py
	cat azure-vote/main.py | perl -pe 's/^    (app\.run.+local)/    # \1/g' > tmp; mv tmp azure-vote/main.py
	cat azure-vote/main.py | perl -pe 's/^    # (app\.run.+remote)/    \1/g' > tmp; mv tmp azure-vote/main.py

vmss-deploy-2:
	git checkout Deploy_to_VMSS
	git add .
	git ci -m "update instrumentation key"
	git push

vmss-deploy-3:
	$(eval instances = $(shell az vmss list-instance-connection-info -g $(group) -n udacity-vmss -o tsv))
	for instance in $(instances); do \
		ssh -o StrictHostKeyChecking=no $(user)@$${instance%%:*} -p $${instance##*:} 'bash -s' < deploy-vote-app.sh; \
	done

vmss-load:
	$(eval instances = $(shell az vmss list-instance-connection-info -g $(group) -n udacity-vmss -o tsv))
	for instance in $(instances); do \
		ssh -o StrictHostKeyChecking=no $(user)@$${instance%%:*} -p $${instance##*:} 'bash -s' < create-vmss-load.sh; \
	done
	watch az vmss list-instances -g $(group) -n udacity-vmss -o table

clean:
	$(eval groups = $(shell az group list --query '[].name' -o tsv))
	@for group in $(groups); do \
		echo deleting group $${group}; \
		az group delete -n $${group} -y; \
	done

