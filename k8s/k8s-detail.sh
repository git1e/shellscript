#!/bin/bash
namespaces=`kubectl get ns|awk '{print $1}'|grep kube-system`
jsonFile='deploy.json'
cpuSum="0"
memSum=0
podSum=0
for  ns in $namespaces
do
  kubectl -n $ns get deploy -o json>$jsonFile
  podReplics=`jq .items[0].spec.replicas $jsonFile`
  cpuLimits=`jq .items[0].spec.template.spec.containers[0].resources.limits.cpu $jsonFile`
  memLimits=`jq .items[0].spec.template.spec.containers[0].resources.limits.memory $jsonFile`
  echo "name=$ns,cpuLimits=$cpuLimits,memLimits=$memLimits,podReplics=$podReplics"
  year=`expr $y`
  cpu=`expr $cpuLimits`
  echo $cpu
  echo $cpuLimits
  icpuSum=$(($cpuSum+$cpu))
#  memSum=$(($memSum + $memLimits))
done

#echo "cpuSum=$cpuSum,memSum=$memSum"