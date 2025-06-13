#!/bin/bash
set -euo pipefail
# usage
# sh scale-all-pods.sh get-pod-count 获取当前所有namespace下deployment和pod数量
# sh scale-all-pods.sh all-scale-down 将所有服务副本数缩为0
# sh scale-all-pods.sh all-scale-up 将所有服务副本数扩容为原来的数量

# Get current deployment and pod count for each namespace
if [[ "$1" == "get-pod-count" ]]; then
# 判断文件是否存在，存在则退出
if [  -f replicas-pod.txt ]; then
    echo "replicas-pod.txt 文件已经存在"
    exit 1
fi

namespaces=$(kubectl get namespaces -o=name | awk -F/ '{print $2}'|grep -v grep |grep -v kube-system|grep -v default)
for namespace in $namespaces; do
  echo "Namespace: $namespace"
  deployments=$(kubectl get deployments -n $namespace -o=name |awk -F"/"  '{print $2}')
  # 遍历当前名称空间下每个deployment和deployment的pod数
  for deploy in $deployments; do
    echo  "Deployment: $deploy"
    pods=$(kubectl get deployment  $deploy -n $namespace -o=json | jq -r '.spec.replicas')
    echo "Namespace: $namespace,Deployment: $deploy,Pods: $pods"
    echo "$namespace $deploy $pods" >> replicas-pod.txt
  done
done
fi


# Scale all deployments in all namespaces to 0
if [[ "$1" == "all-scale-down" ]]; then
  # 判断文件是否存在，不存在则退出
  if [ ! -f replicas-pod.txt ]; then
      echo "replicas-pod.txt 文件不存在，请先执行 get-replicas-pod.sh 获取信息"
      exit 1
  fi
  while read namespace deployments pods; do
    echo "Scaling all deployments in namespace $namespace to 0"
#    kubectl scale deployments $deployments -n $namespace --replicas=0 
  done < replicas-pod.txt
  echo "All deployments scaled down to 0"
fi

# Scale all deployments in all namespaces to original pod count
if [[ "$1" == "all-scale-up" ]]; then
  # 判断文件是否存在，不存在则退出
  if [ ! -f replicas-pod.txt ]; then
      echo "replicas-pod.txt 文件不存在，请先执行 get-replicas-pod.sh 获取信息"
      exit 1
  fi

  while read namespace deployments pods; do
    echo "Scaling all deployments in namespace $namespace to $pods"
#    kubectl scale deployments $deployments -n $namespace --replicas=$pods
  done < replicas-pod.txt
  echo "All deployments scaled up to original pod count"
fi

# Cleanup
# rm -f replicas-pod.txt


if [[ "$1" == "restart-deploy" ]]; then
  # 判断文件是否存在，不存在则退出
  if [ ! -f replicas-pod.txt ]; then
      echo "replicas-pod.txt 文件不存在，请先执行 get-replicas-pod.sh 获取信息"
      exit 1
  fi
  num=0
  while read namespace deployments pods; do
    echo "restart  $namespace deploy $deployments ..."
  #   kubectl rollout restart deployment $deployments -n $namespace
    let num=num+1
    if [ $num -ge 5 ];then  
      echo "has restart 5 app,sleep"  
      sleep 30
      num=0
    fi  
  done < replicas-pod.txt
  echo "all app has restarted!"

fi
