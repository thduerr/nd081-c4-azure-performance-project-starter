# Project

The project setup is based on a Makefile and several shell- and init-scripts


## Step 1: Create an Azure VMSS

    git checkout Deploy_to_VMSS
    make vmss


## Step 2: Application Insights & Log Analytics

In the Azure portal, enable VM Insights monitoring for the VM Scale Set using the 
created Analytics Workspace. This can take 5-10 minutes.


## Step 3: Deploy to VMSS

The file azure-vote/main.py was updated with logging, metrics, tracing and requests.

    make deploy

Get public IP from the Azure portal and open in a browser.


## Step 4: Autoscaling VMSS

Setup autoscaling and two rules and create some load on the VMs:

    make vmss-autoscale

The two autoscale rules are based on metrics:

1. when the average CPU load is greater than 70% over a 5-minute period, then the number of VM instances is increased to three. As we start with 2 instances, the number of instances will be 2 * 3 = 6
2. when the average CPU load drops below 30% over a 5-minute period, then the number of VM instances is one. This means we end up again with 2 instances.

We trigger some load for 10 minutes (see 'create-vmss-load.sh' script) on both instances.


## Step 5: Deploy to AKS

## Step 6: Autoscaling AKS Cluster

## Step 7: Runbook
