appinsight = udacity-app-insights

setup:
	./setup-script.sh
	az monitor app-insights component create -a $(appinsight) -l westus2 -g acdnd-c4-project
	$(eval instr_key = $(shell az monitor app-insights component show -a $(appinsight) -g acdnd-c4-project --query 'instrumentationKey' -o tsv))
	@cat azure-vote/main.py | perl -pe "s/(^APPLICATION_INSIGHTS_INTRUMENTATION_KEY = \"InstrumentationKey=).*\"/\1$(instr_key)\"/g" > tmp; mv tmp azure-vote/main.py
