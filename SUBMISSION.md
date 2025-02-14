# 1.Azure Vote App

See `./azure-vote/main.py` which is the version for the AKS cluster.

See also `https://github.com/thduerr/nd081-c4-azure-performance-project-starter` for 
both branches `Deploy_to_VMSS` and `Deploy_to_AKS`.


# 2. Screenshots for the Application Insights

* submission-screenshots/application-insights/resource-group.png
* submission-screenshots/application-insights/resource-group-cluster.png


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

* submission-screenshots/kubernetes-cluster/kubernetes-hpa.png


The Application Insights metrics which show the increase in the number of pods:

* submission-screenshots/kubernetes-cluster/cluster-insights.png
* submission-screenshots/kubernetes-cluster/cluster-insights-container.png
* submission-screenshots/kubernetes-cluster/cluster-metrics-podcount.png


The email you received from the alert when the pod count increased:

* submission-screenshots/kubernetes-cluster/email-pod-count-increase-top.png
* submission-screenshots/kubernetes-cluster/email-pod-count-increase-bottom.png



# 4. Screenshots for the Autoscaling of the VM Scale Set

The conditions for which autoscaling will be triggered:

* submission-screenshots/autoscaling-vmss/autoscaling-conditions-trigger.png


The Activity log of the VM scale set which shows that it scaled up with timestamp:

* submission-screenshots/autoscaling-vmss/vmss-activity-log.png


The new instances being created:

* submission-screenshots/autoscaling-vmss/vmss-new-instances-1.png
* submission-screenshots/autoscaling-vmss/vmss-new-instances-2.png
* submission-screenshots/autoscaling-vmss/vmss-new-instances-3.png


The metrics which show the load increasing, then decreasing once scaled up with timestamp:

* submission-screenshots/autoscaling-vmss/vmss-load-cpu-memory.png
* submission-screenshots/autoscaling-vmss/vmss-load-byte-rates.png


# 5. Screenshots for the Azure Runbook

* submission-screenshots/runbook/resource-group-runbook.png


The alert configuration in Azure Monitor which shows the resource, condition, action group (this should
include a reference to your Runbook), and alert rule details:

* submission-screenshots/runbook/runbook-alert-action-group.png
* submission-screenshots/runbook/runbook-alert-config-scope-conditions.png
* submission-screenshots/runbook/runbook-alert-config-action-details.png


The email you received from the alert when the Runbook was executed:

* submission-screenshots/runbook/alert-email-runbook-top.png
* submission-screenshots/runbook/alert-email-runbook-bottom.png
* submission-screenshots/runbook/alert-email-runbook-resolved.png


The summary of the alert which shows 'why did this alert fire?', timestamps, and the criterion in which it
fired:

* submission-screenshots/runbook/runbook-alert-overview.png
* submission-screenshots/runbook/runbook-alert-summary.png
* submission-screenshots/runbook/runbook-alert-history.png
* submission-screenshots/runbook/runbook-output.png
* submission-screenshots/runbook/runbook-all-logs.png


