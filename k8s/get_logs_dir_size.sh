#!/bin/bash

# 需要预先设置的变量
dir_to_check="/data/logs" # 需要检查的目录
dir_size_threshold="10240" # 目录大小阈值（以 MB 为单位）
days_to_delete="2" # 需要删除的天数
wechat_webhook_url="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=" # 企业微信 Webhook URL
kube_configfile="/root/.kube/config-prod"
# 获取所有命名空间名称（不包括排除的命名空间）
namespaces=$(kubectl get namespaces -o=name --kubeconfig=$kube_configfile| awk -F/ '{print $2}' | grep -v kube-system|grep -v default|grep -v grep)

# 循环遍历每个命名空间
for namespace in $namespaces; do
  # 获取命名空间下的所有 Pod 名称
  pods=$(kubectl get pods -n $namespace -o=name --kubeconfig=$kube_configfile| awk -F/ '{print $2}')

  # 循环遍历每个 Pod
  for pod in $pods; do
    # 获取目录大小信息（以 MB 为单位）
    dir_size=$(kubectl exec $pod -n $namespace --kubeconfig=$kube_configfile -- du -sm $dir_to_check 2>/dev/null | awk '{print $1}')

    mytime=`date`
    # 判断目录大小是否大于目录大小阈值
    if [ -n "$dir_size" ] && [ $dir_size -gt $dir_size_threshold ]; then
      # 如果目录大小大于阈值，则打印 Pod 名称和目录大小信息
      echo "$mytime Namespace: $namespace, Pod: $pod, Directory size: ${dir_size}MB,开始清理日志" >>/var/log/pod_logs_size.log

      # 删除指定天数之前的文件（以秒为单位）
      delete_before=$(date -d "-${days_to_delete} days" +%s)
      kubectl exec $pod -n $namespace --kubeconfig=$kube_configfile -- find $dir_to_check -type f -name "*log*" -mtime +$days_to_delete -exec rm {} \;

      # 发送企业微信告警
      message="{\"msgtype\":\"text\",\"text\":{\"content\":\"[告警]\n Pod: $pod\n 目录 $dir_to_check\n size: ${dir_size}MB 大小超过 ${dir_size_threshold}MB\n 已经清理${days_to_delete}天前logs！\"}}"
      curl -H "Content-Type: application/json" -X POST -d "$message" "$wechat_webhook_url"
    else
        echo "$mytime Namespace: $namespace, Pod: $pod, Directory size: ${dir_size}MB,/data/logs目录小于10G,忽略" >>/var/log/pod_logs_size.log
    fi
  done
done
