# 1.Azure Vote App

See `./azure-vote/main.py` which is the version for the AKS cluster.

See also `https://github.com/thduerr/nd081-c4-azure-performance-project-starter` for 
both branches `Deploy_to_VMSS` and `Deploy_to_AKS`.


# 2. Screenshots for the Application Insights

The metrics from the VM Scale Set instance:

* submission-screenshots/application-insights/vmss-insights-cpu-memory.png
* submission-screenshots/application-insights/vmss-insights-byte-rates.png
* submission-screenshots/application-insights/vmss-insights-disk-space.png
* submission-screenshots/application-insights/vmss-metrics-cpu.png
* submission-screenshots/application-insights/vmss-metrics-memory.png


Application Insight Events which show the results of clicking 'vote' for each 'Dogs' & 'Cats':

* submission-screenshots/application-insights/application-insights-events-chart.png


The output of the traces query in Azure Log Analytics:

* submission-screenshots/application-insights/log-analytics-traces.png


The chart created from the output of the traces query:

* submission-screenshots/application-insights/log-analytics-traces-chart.png


# 3. Screenshots for the kubernetes cluster

The output of the Horizontal Pod Autoscaler, showing an increase in the number of pods:

* submission-screenshots/kubernetes-cluster/XXX


The Application Insights metrics which show the increase in the number of pods:

* submission-screenshots/kubernetes-cluster/XXX


The email you received from the alert when the pod count increased:

* submission-screenshots/kubernetes-cluster/XXX



# 4. Screenshots for the Autoscaling of the VM Scale Set

The conditions for which autoscaling will be triggered:

* submission-screenshots/autoscaling-vmss/XXX


The Activity log of the VM scale set which shows that it scaled up with timestamp:

* submission-screenshots/autoscaling-vmss/XXX


The new instances being created:

* submission-screenshots/autoscaling-vmss/XXX


The metrics which show the load increasing, then decreasing once scaled up with timestamp:

* submission-screenshots/autoscaling-vmss/XXX


# 5. Screenshots for the Azure Runbook

The alert configuration in Azure Monitor which shows the resource, condition, action group (this should
include a reference to your Runbook), and alert rule details:

* submission-screenshots/runbook/XXX


The email you received from the alert when the Runbook was executed:

* submission-screenshots/runbook/XXX


The summary of the alert which shows 'why did this alert fire?', timestamps, and the criterion in which it
fired:

* submission-screenshots/runbook/XXX


