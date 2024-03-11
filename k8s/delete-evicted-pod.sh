#!/bin/bash
#
# 清理Evicted的pod
#

kube_configfile="~/.kube/config"
# 获取所有命名空间名称（不包括排除的命名空间）
namespaces=$(/usr/local/bin/kubectl get namespaces -o=name --kubeconfig=$kube_configfile| awk -F/ '{print $2}' | grep -v kube-system|grep -v default|grep -v grep)

# 循环遍历每个命名空间
for namespace in $namespaces; do
  # 获取命名空间下的所有 Evicted状态的Pod 并delete
  /usr/local/bin/kubectl get pods -n $namespace   --kubeconfig=$kube_configfile| grep "Evicted"| awk '{print $1}'|xargs /usr/local/bin/kubectl --kubeconfig=$kube_configfile delete po -n $namespace
done
