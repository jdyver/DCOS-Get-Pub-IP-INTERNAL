#!/bin/bash
#
# SCRIPT:   get-dcos-public-agent-ip.sh
#
# DESCR:    Get the Amazon Public IP Address for the public DCOS agent nodes. If
#           no arguments are supplied it will attempt to start on 2 pubic agent nodes.
#
# USAGE:    get-dcos-public-agent-ip.sh <num-pub-agents> <--mlb: Marathon-LB check or add>
#

echo
if [ "$1" == "" ]
then
    num_pub_agents=2
    echo " Using the default number of public agent nodes (2)"
    mlb_enabled=0
elif [ $1 == "--mlb" ]
then
    mlb_enabled=1
    num_pub_agents=2
    echo " Using the default number of public agent nodes (2) with Marathon-LB"
elif [ "$2" == "--mlb" ]
then
    mlb_enabled=1
    num_pub_agents=$1
    echo " Using $num_pub_agents public agent node(s) with Marathon-LB"
else
    num_pub_agents=$1
    echo " Using $num_pub_agents public agent node(s)"
    mlb_enabled=0
fi

# get the public IP of the public node if unset
cat <<EOF > /tmp/get-public-agent-ip.json
{
  "id": "/get-public-agent-ip",
  "cmd": "curl http://169.254.169.254/latest/meta-data/public-ipv4 && sleep 3600",
  "cpus": 0.25,
  "mem": 32,
  "instances": $num_pub_agents,
  "acceptedResourceRoles": [
    "slave_public"
  ],
  "constraints": [
    [
      "hostname",
      "UNIQUE"
    ]
  ]
}
EOF

echo
echo ' Starting public-ip.json marathon app'
echo
dcos marathon app add /tmp/get-public-agent-ip.json

sleep 10

###### Add check for M-LB and add if not already enabled #########
# --mlb flag #####################################################

if [ "$mlb_enabled" == "1" ]
then
    marathon=`dcos marathon app list`

	       # Expected - Positive Output #################################################
               # bash-mbp:BSH $ dcos marathon app list
               # ID            MEM   CPUS  TASKS  HEALTH  DEPLOYMENT  WAITING  CONTAINER  CMD
               # /marathon-lb  1024   2     1/1    1/1       ---      False      DOCKER   N/A

    if [[ $marathon == *marathon-lb* ]]
    then
        echo
    else
        echo 
        echo " Marathon-LB Not Found: Deploying"
        echo
        dcos package install --yes marathon-lb &> /dev/null
        sleep 15
    fi
else
    echo
fi

# End of M-LB Check #################################################################

task_list=`dcos task get-public-agent-ip | grep get-public-agent-ip | awk '{print $5}'`

for task_id in $task_list;
do
    public_ip=`dcos task log $task_id stdout | tail -1`

    echo
    echo " Public agent node found:  public IP is: $public_ip | http://$public_ip:9090/haproxy?stats"
    haproxy=`curl -Is http://$public_ip:9090/haproxy?stats | head -1`

            # Expected - Positive Output #####################
            # HTTP/1.1 200 OK

    if [[ $haproxy == *OK* ]]
    then
        echo " Marathon-LB Location: http://$public_ip:9090/haproxy?stats"
    else
        echo
    fi

done
sleep 2

dcos marathon app remove get-public-agent-ip

rm /tmp/get-public-agent-ip.json
echo

# end of script
