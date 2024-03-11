#!/bin/bash

kubeconfig=~/.kube/config-prod

ns=`kubectl get namespaces -o custom-columns=NAME:.metadata.name --no-headers --kubeconfig=${kubeconfig}|grep -vE "kube-system|defaults|mysql|redis|mongo"`
echo "name,namespace,replicas,creationTimestamp,generation,SW_AGENT_OPTS,JDWP_OPTS,JACOCO_OPTS,livenessProbe,readinessProbe,startupProbe,menLimit,menRequests,cpuLimit,cpuRequests,image,imagePullPolicy"

for namespace in $ns;do
    # get all deploy in this namespace
    deploys=$(kubectl get deploy -n ${namespace} --no-headers -o custom-columns=NAME:.metadata.name  --kubeconfig=${kubeconfig})
    for deploy in ${deploys};
    do
        echo "开始获取:${namespace}/${deploy}"
        kubectl -n ${namespace}  get deployment ${deploy} --kubeconfig=${kubeconfig}  >/dev/null 2>&1
        if [ $? -ne 0 ];then
            echo "k8s namespace:${namespace}下面, 不存在deployment,请检查!"
        else
            kubectl  -n "${namespace}" get deploy "${deploy}" --kubeconfig=${kubeconfig} -o json >deploy.json
            if [ ! -f deploy.json ];then
                echo "deploy json not exist!"
                exit 1
            fi

            name=$(jq -r '.metadata.name' deploy.json)
            namespace=$(jq -r '.metadata.namespace' deploy.json)
            replicas=$(jq -r '.spec.replicas' deploy.json)
            creationTimestamp=$(jq -r '.metadata.creationTimestamp' deploy.json)
            generation=$(jq -r '.metadata.generation' deploy.json)

            # env
            SW_AGENT_OPTS=$(jq -r '.spec.template.spec.containers[0].env[] | select(.name == "SW_AGENT_OPTS") | .value' deploy.json)
            JDWP_OPTS=$(jq -r '.spec.template.spec.containers[0].env[] | select(.name == "JDWP_OPTS") | .value' deploy.json)
            JACOCO_OPTS=$(jq -r '.spec.template.spec.containers[0].env[] | select(.name == "JACOCO_OPTS") | .value' deploy.json)

            # probe
            livenessProbe=$(jq -r '.spec.template.spec.containers[0].livenessProbe.httpGet.port' deploy.json)
            readinessProbe=$(jq -r '.spec.template.spec.containers[0].readinessProbe.httpGet.port' deploy.json)
            startupProbe=$(jq -r '.spec.template.spec.containers[0].startupProbe.httpGet.port' deploy.json)

            # limit
            menLimit=$(jq -r '.spec.template.spec.containers[0].resources.limits.memory' deploy.json)
            menRequests=$(jq -r '.spec.template.spec.containers[0].resources.requests.memory' deploy.json)
            # 提取可能存在的 "cpuLimit" 字段
            if jq -e '.spec.template.spec.containers[0].resources.limits.cpu' deploy.json > /dev/null; then
                cpuLimit=$(jq -r '.spec.template.spec.containers[0].resources.limits.cpu' deploy.json)
            else
                cpuLimit="N/A"
            fi
            if jq -e '.spec.template.spec.containers[0].resources.limits.cpu' deploy.json > /dev/null; then
                cpuRequests=$(jq -r '.spec.template.spec.containers[0].resources.requests.cpu' deploy.json)
            else
                cpuRequests="N/A"
            fi

            # image
            image=$(jq -r '.spec.template.spec.containers[0].image' deploy.json)
            imagePullPolicy=$(jq -r '.spec.template.spec.containers[0].imagePullPolicy' deploy.json)


            echo "$name,$namespace,$replicas,$creationTimestamp,$generation,$SW_AGENT_OPTS,$JDWP_OPTS,$JACOCO_OPTS,$livenessProbe,$readinessProbe,$startupProbe,$menLimit,$menRequests,$cpuLimit,$cpuRequests,$image,$imagePullPolicy"
        fi

    done



done
