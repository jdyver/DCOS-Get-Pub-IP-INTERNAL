#
# SCRIPT:   get-dcos-public-agent-ip.sh
#
DESCRIPTION: 
To start, this works the exact same as the original script.  Get the Amazon Public IP Address for the public DCOS agent nodes.  If no arguments are supplied then it will attempt to start on 2 pubic agent nodes.  With the MLB flag it will ensure that you have MLB and let you know which agent has it deployed
#
Arguments:

\<NUMBER\> - Default: 2;    This should be the number of public agents that you want to check for

\<--mlb\>  - Default: Null; This will check for MLB and deploy if necessary
#
## USAGE:    get-dcos-public-agent-ip.sh \<num-pub-agents\> \<--mlb: Marathon-LB check or add\>

### Executed Command and Out default (No LB available)

```
JD # bash get-dcos-public-agent-ip_v1.sh

Using the default number of public agent nodes (2)

Starting public-ip.json marathon app

Extracting "dcos-core-cli"...
Created deployment de66422d-bb5c-486e-bc6d-bcfb06791f31


Public agent node found:  public IP is: 54.190.20.151 | http://54.190.20.151:9090/haproxy?stats


Public agent node found:  public IP is: 35.160.110.93 | http://35.160.110.93:9090/haproxy?stats
```

### Executed Command and Out default (LB available)

```
JD # bash get-dcos-public-agent-ip_v1.sh

Using the default number of public agent nodes (2)

Starting public-ip.json marathon app

Created deployment 075c6e86-ffb6-4f7d-9b95-465efd9e2fc2


Public agent node found:  public IP is: 54.190.20.151 | http://54.190.20.151:9090/haproxy?stats
LB Location: http://54.190.20.151:9090/haproxy?stats

Public agent node found:  public IP is: 35.160.110.93 | http://35.160.110.93:9090/haproxy?stats
```

### Executed Command and Out w/MLB (no LB installed)

```
JD # bash get-dcos-public-agent-ip_v1.sh --mlb

Using the default number of public agent nodes (2) with Marathon-LB

Starting public-ip.json marathon app

Created deployment 469022bd-fefd-423a-8899-75e2328200b1

Marathon-LB Not Found: Deploying


Public agent node found:  public IP is: 54.190.20.151 | http://54.190.20.151:9090/haproxy?stats
LB Location: http://54.190.20.151:9090/haproxy?stats

Public agent node found:  public IP is: 35.160.110.93 | http://35.160.110.93:9090/haproxy?stats
```

## Steps
Setup dcos command line

```
JD # dcos cluster setup https://jdyckowsk-elasticl-1mdecebj9wsc5-1708719683.us-west-2.elb.amazonaws.com
Cluster Certificate Authority:

Issuer: CN=DC/OS Root CA 6ee7b6ce-3f97-4614-911a-e6244669de9f,O=Mesosphere\, Inc.,L=San Francisco,ST=CA,C=US

Validity:
From:  2019-01-25 15:13:52 +0000 UTC
Until: 2029-01-22 15:13:52 +0000 UTC

SHA256 fingerprint: Z8:Z8:Z0:Z5:Z5:Z0:Z6:Z0:Z5:ZD:ZB:Z0:ZD:Z0:ZF:Z1:Z8:Z6:2B:ZD:ZB:Z9:Z4:Z2:Z3:Z2:ZE:Z0:Z2:Z6:Z9:Z9

Do you trust it? [y/n] y
Username: bootstrapuser
Password: *****
```

## EOF
