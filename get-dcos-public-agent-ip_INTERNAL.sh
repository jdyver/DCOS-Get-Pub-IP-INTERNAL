#!/bin/bash
#
# SCRIPT:   get-dcos-public-agent-ip_v3_INTERNAL.sh
#
# INTERNAL VERSION - NO need for EdgeLB repo URL
#
# DESCR:    Get the Public IP Address for all of the public DCOS agent nodes.
#
# USAGE:    get-dcos-public-agent-ip.sh <--mlb: Marathon-LB check or add> <--elb: Edge-LB check or add> <elb-local.cfg.json location>
#
# - get-dcos-public-agent-ip.sh
# - get-dcos-public-agent-ip.sh --mlb
# - get-dcos-public-agent-ip.sh --elb /Users/username/Documents/Scripts/edgelb.cfg.json
#

###### Usage Check #############################################################
echo
if [ "$1" == "" ]
then
    echo "  Public-IP: Pulling IPs without adding LBs"
    mlb_enabled=0
    elb_enabled=0
    elb_cfg_file=0
elif [ $1 == "--mlb" ]
then
    mlb_enabled=1
    elb_enabled=0
    elb_cfg_file=0
    echo " Public-IP: Checking for Marathon-LB"
elif [ $1 == "--elb" ]
then
    elb_enabled=1
    if [ "$2" == "" ]
    then
	echo " get-dcos-public-agent-ip.sh fail: --elb requires a json "
	exit 1;
    else
        elb_cfg_file=$2
    fi
    mlb_enabled=0
    echo " Public-IP: Checking for Edge-LB:$2"
else
    echo " Public-IP: Pulling IPs without adding LBs"
    echo " - Argument warning: Public count is no longer a valid input"
    mlb_enabled=0
    elb_enabled=0
    elb_cfg_file=0
fi

# End of Usage Check ##############################################################

###### Add Public node count ####################################################

dcos_pub_out=`dcos node --json | grep public_ip`
# echo $dcos_pub_out

num_pub_agents=`echo $dcos_pub_out | wc -w`
# echo $num_pub_agents

num_pub_agents=`echo $((num_pub_agents / 2))`
# echo "Public Agent Count: $num_pub_agents"

# End of Adding Public Node Count ###############################################
 
###### Get the public IP of the public node if unset #############################
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
dcos marathon app add /tmp/get-public-agent-ip.json &> /dev/null

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
    elif [[ $marathon == *edgelb-proxy* ]]
    then
	echo " EDGE-LB is already deployed so not deploying Marathon"
    else
        echo 
        echo " Marathon-LB Not Found: Deploying"
        echo
        dcos package install --yes marathon-lb &> /dev/null
        sleep 15
    fi
#else
#    echo
fi

# End of M-LB Check ##############################################

###### EDGE-LB ###################################################
# --elb flag #####################################################

if [ "$elb_enabled" == "1" ]
then
    marathon=`dcos marathon app list`

               # JD # dcos marathon app list
               # ID                               MEM   CPUS  TASKS  HEALTH  DEPLOYMENT  WAITING  CONTAINER  CMD
               # /dcos-edgelb/api                 1024   1     1/1    1/1       ---      False      MESOS    cp -vR /dcosfilestmp/*...
               # /dcos-edgelb/pools/edgelb-proxy  2048   1     1/1    1/1       ---      False      MESOS    export...

    if [[ $marathon == *edgelb-proxy* ]]
    then
        echo
    elif [[ $marathon == *marathon-lb* ]]
    then
        echo " Marathon-LB is already deployed so not deploying EdgeLB"
    else
        echo
        echo " Edge-LB Not Found: Deploying"
        echo
 	
	# Check if EdgeLB is added to the DCOS repo
	repo_list=`dcos package repo list`

               ### Expected Output - NOT having EdgeLB ######################################
               # JD # dcos package repo list
               # Universe: https://universe.mesosphere.com/repo
               # Bootstrap Registry: https://registry.component.thisdcos.directory/repo

	if [[ $repo_list != *edgelb* ]]
	then
        	echo
		dcos package repo add --index=0 edgelb https://downloads.mesosphere.com/edgelb/v1.2.3/assets/stub-universe-edgelb.json
		dcos package repo add --index=0 edgelb-pool https://downloads.mesosphere.com/edgelb-pool/v1.2.3/assets/stub-universe-edgelb-pool.json
		sleep 5
	fi
	dcos package install --yes edgelb &> /dev/null
        sleep 15
	dcos edgelb create $elb_cfg_file &> /dev/null
	sleep 20
    fi
#else
#    echo
fi

# End of EDGE-LB Check ################################################

###### Pull public IPs and check for LB ###############################################
task_list=`dcos task get-public-agent-ip | grep get-public-agent-ip | awk '{print $5}'`

for task_id in $task_list;
do
    public_ip=`dcos task log $task_id stdout | tail -1`

    echo
    echo "    Public agent node found:  public IP is: $public_ip"
    haproxy=`curl -Is http://$public_ip:9090/haproxy?stats | head -1`

            # Expected - Positive Output #####################
            # HTTP/1.1 200 OK

    if [[ $haproxy == *OK* ]]
    then
        echo "        LB Node: http://$public_ip:9090/haproxy?stats"
    elif [[ $haproxy == *Service*Unavailable* ]]
    then
	elb_port_num=$(echo `dcos edgelb show edgelb-proxy | grep STATSPORT` | tr -dc '0-9')
               
	       # Expected Output ########################################
               # JD # dcos edgelb show edgelb-proxy | grep STATSPORT
               #  STATSPORT    6090

        haproxy=`curl -Is http://$public_ip:$elb_port_num/haproxy?stats | head -1`

	if [[ $haproxy == *OK* ]]
    	then
        	echo "        LB Node: http://$public_ip:$elb_port_num/haproxy?stats"
    	else
        	echo
	fi
    fi

done
sleep 2

dcos marathon app remove get-public-agent-ip &> /dev/null

rm /tmp/get-public-agent-ip.json

echo

# end of script
