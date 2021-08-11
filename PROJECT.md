# Project

The project setup is based on a Makefile and several shell- and init-scripts


## Step 1: Create an Azure VMSS

    make vmss


## Step 2: Application Insights & Log Analytics

In the Azure portal, enable VM Insights monitoring for the VM Scale Set.


## Step 3: Deploy to VMSS

The file azure-vote/main.py was updated with logging, metrics, tracing and requests.

    make deploy

Get public IP from the Azure portal and open in a browser.

Then open the Application Insights dashboard, and do the following:
Navigate to the Usage → Events service. Create a query to view the event telemetry.
Navigate to the Monitoring → Logs service. Create a chart from the query showing when 'Dogs' or 'Cats' is clicked.


## Step 4: Autoscaling VMSS

Setup autoscaling and two rules and create some load on the VMs:

    make vmss-autoscale

The two autoscale rules are:

1. when the average CPU load is greater than 70% over a 5-minute period, then the number of VM instances is increased to three. As we start with 2 instances, the number of instances will be 2 * 3 = 6
2. when the average CPU load drops below 30% over a 5-minute period, then the number of VM instances is one. This means we end up again with 2 instances.

We create some load for 7 minutes (see 'create-vmss-load.sh' script) on both instances.


## Step 5: Deploy to AKS

## Step 6: Autoscaling AKS Cluster

## Step 7: Runbook
