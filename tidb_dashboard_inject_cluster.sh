## tidb_dashboard_inject_cluster.sh

#!/bin/bash

cluster_name="$1"
dashboard_json_dir="$2"
prometheus_endpoint="$3"


## step 1：get all tidb-metric url from http://<prometheus_ip>:9090/api/v1/targets
## step 2: get all tidb-metric
function get_tidb_metrics() {
    rm -rf /tmp/tidb-metrics
    for i in `curl -s http://$prometheus_endpoint/api/v1/targets |  jq '.' | grep scrapeUrl | awk -F '"' '{print$4}' | sort | uniq`; do
        curl -s $i | awk -F '{' '{print$1}' | awk -F ' ' '{print$1}' | grep -v "#" >> /tmp/tidb-metrics
    done;
}

function inject_cluster_by_file() {
    cluster_name=$1
    dashboard_file=$2
    expr_index=0

    expr_count=`cat $dashboard_json_dir/$dashboard_file_ind | grep expr | wc -l`
    for tidb_metric_ind in `cat /tmp/tidb-metrics | sort | uniq`; do

        tmp=`cat $dashboard_file | grep $tidb_metric_ind`
        if [[ $tmp != '' ]]; then
            expr_index=$((expr_index+1))
            sed -i "s/$tidb_metric_ind/$tidb_metric_ind{cluster='${cluster_name}'}/g" $dashboard_file
#            expr_without_operation=`echo $tmp | grep "{"`
#            #echo $expr_without_operation
#            if [[ $expr_without_operation != '' ]]; then
#                #echo "-->" $tidb_metric_ind
#                sed -i "s/$tidb_metric_ind{/$tidb_metric_ind{cluster=\\\\\"${cluster_name}\\\\\",/g"  $dashboard_file
#
#               #expr_index=$((expr_index+1))
#            else
#                #echo $tidb_metric_ind
#                sed -i "s/$tidb_metric_ind/$tidb_metric_ind{cluster=\\\\\"${cluster_name}\\\\\"}/g" $dashboard_file
#               #expr_index=$((expr_index+1))
#            fi
            echo "Process for $dashboard_file $expr_index / $expr_count"


        fi
        #echo $tmp

    done
    sed -i "s#cluster='tidb-c1-v409'}{#cluster='tidb-c1-v409',#g" $dashboard_file
    echo "Process for $dashboard_file $expr_count / $expr_count"
}


get_tidb_metrics
for dashboard_file_ind in `ls $dashboard_json_dir`; do
    echo "inject cluster info for the dashboard $dashboard_json_dir/$dashboard_file_ind"
    inject_cluster_by_file $cluster_name $dashboard_json_dir/$dashboard_file_ind
done
