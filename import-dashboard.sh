export grafana_url="192.168.12.34:3000"                                 # Changed in your env
export grafana_user_passwd="admin:admin"                                # Changed in your env
export grafana_dashboard_dir="/root/dashboards"                         # Changed in your env

cd $grafana_dashboard_dir && mkdir -p dashboard-trans

for i_dashboard in `ls | grep json`; do 

    echo "transform dashboard - $i_dashboard"
    v_dashboard_item=`echo $i_dashboard | sed "s/\.json//g" `
    echo $v_dashboard_item

    vuuid=`uuidgen` && cat $i_dashboard | \
        sed  "s#\"uid\".*#\"uid\" : \"$vuuid\",#g" | \
        sed '1i {"dashboard": ' | sed '$a }'  \
        > dashboard-trans/$v_dashboard_item-trans.json



    echo "debug # $grafana_user_passwd"
    echo "debug # http://$grafana_url/api/dashboards/db"
    echo "debug # $grafana_dashboard_dir/dashboard-trans/$v_dashboard_item-trans.json"
    curl -i -X POST \
        --user $grafana_user_passwd \
        -H "Accept: application/json" -H "Content-Type: application/json" -k -v  http://$grafana_url/api/dashboards/db \
        -d @$grafana_dashboard_dir/dashboard-trans/$v_dashboard_item-trans.json
done
