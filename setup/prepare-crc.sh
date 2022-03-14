#!/bin/bash
#This script configures CRC for running app-studio in it
#It cofigures the CRC to have better memory and CPUs 
#It also configures CRC to have required addons.

CRCBINARY=$(readlink -f ~/.crc/bin/crc)

echo $CRCBINARY
#Get CRC VMs configured in local machine
$CRCBINARY setup
#Set memory and CPU allowance for CRC
$CRCBINARY config set memory 16384
$CRCBINARY config set cpus 6
#enable netmetrices addons, to make sure member cluster has proper resources
$CRCBINARY config set enable-cluster-monitoring true
#Delete existing CRC cluster to apply the config updates
$CRCBINARY delete 
#TODO: Check the return value of delete command and go forward accordingly
#And inform the users for the next steps in case user choose not to delete the 
#existing cluster

#Start CRC with modified configs
$CRCBINARY start

#Point local environment clients (kubectl and oc) to the CRC cluster
eval $($CRCBINARY oc-env)
kubectl config use-context crc-admin

#Reduce cpu resource request for each AppStudio Application
#TODO: Set the file path properly
./hack/reduce-gitops-cpu-requests.sh