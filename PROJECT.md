# Project

The project setup is based on a Makefile and several shell- and init-scripts:

* setup-script.sh (by Udacity):    create VMSS and install dependencies (via cloud-init.txt)
* deploy-vote-app:                 deploy the vote app on an VMSS instance
* create-vmss-load.sh:             create load on a VMSS instance using the `stress` tool
* create-cluster.sh (by Udacity):  create an AKS cluster


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

1. when the average CPU load is greater than 70% over a 5-minute period, then the number of VM instances is increased to three.
2. when the average CPU load drops below 30% over a 5-minute period, then the number of VM instances is one.

We trigger some load for 10 minutes (see 'create-vmss-load.sh' script) on both instances.


## Step 5: Deploy to AKS

Create AKS cluster, build & upload image to ACR and deploy pods:

    git checkout Deploy_to_AKS
    make aks


## Step 6: Autoscaling AKS Cluster

Create an autoscaler object with rule:
if average CPU utilization across all pods exceeds 30% of their requested usage, increase the pods from a minimum of 1 instance up to a maximum of 10 instances

    make aks-autoscale

Then create load eihter by externally calling the app using e.g. `ab`:

    ab -c 50 -n 10000 https://<ip>/

or by internally calling using the service name:

    kubectl run -it load-test --rm --image=busybox --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://azure-vote-front; done"



## Step 7: Runbook

"Setup an Azure Automation account and create a RunBook to automate the resolution of performance issues"

Scale up the VMs using Automation Runbooks aSVM metrics



