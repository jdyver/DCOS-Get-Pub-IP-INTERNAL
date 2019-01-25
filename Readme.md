#
# SCRIPT:   get-dcos-public-agent-ip.sh
#
DESCRIPTION: 
To start, this works the exact same as the original script.  Get the Amazon Public IP Address for the public DCOS agent nodes.  If no arguments are supplied it will attempt to start on 2 pubic agent nodes.
#
Arguments:

\<NUMBER\> - Default: 2;    This should be the number of public agents that you want to check for

\<--mlb\>  - Default: Null; This will check for MLB and deploy if necessary
#
## USAGE:    get-dcos-public-agent-ip.sh <num-pub-agents> <--mlb: Marathon-LB check or add>

![Executed Command and Out default (No LB)](https://github.com/jdyver/DCOS-Get-Pub-IP/blob/master/img/CMD1.png)
![Executed Command and Out default (LB)](https://github.com/jdyver/DCOS-Get-Pub-IP/blob/master/img/CMD2.png)
![Executed Command and Out w/MLB](https://github.com/jdyver/DCOS-Get-Pub-IP/blob/master/img/CMD3.png)
