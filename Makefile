appinsight = udacity-app-insights
user=udacityadmin

setup:
	./setup-script.sh
	az monitor app-insights component create -a $(appinsight) -l westus2 -g acdnd-c4-project
	$(eval instr_key = $(shell az monitor app-insights component show -a $(appinsight) -g acdnd-c4-project --query 'instrumentationKey' -o tsv))
	@cat azure-vote/main.py | perl -pe "s/(^APPLICATION_INSIGHTS_INTRUMENTATION_KEY = \"InstrumentationKey=).*\"/\1$(instr_key)\"/g" > tmp; mv tmp azure-vote/main.py

deploy:
	$(eval insts = $(shell az vmss list-instance-connection-info -g acdnd-c4-project -n udacity-vmss -o tsv))
	for i in $(insts); do ssh -o StrictHostKeyChecking=no $(user)@$(shell awk -F':' '{print $$1}' <<< $(i)) -p $(shell awk -F':' '{print $$2}' <<< $(i)) 'bash -s' < deploy-vote-app.sh; done;

deploy2:
	$(eval instance1 = $(shell az vmss list-instance-connection-info -g acdnd-c4-project -n udacity-vmss -o json | jq -r '."instance 1"'))
	$(eval ip1 = $(shell awk -F':' '{print $$1}' <<< $(instance1)))
	$(eval port1 = $(shell awk -F':' '{print $$2}' <<< $(instance1)))
	ssh -o StrictHostKeyChecking=no udacityadmin@$(ip1) -p $(port1) 'bash -s' < deploy-vote-app.sh
