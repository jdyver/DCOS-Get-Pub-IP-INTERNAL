#
# SCRIPT:   get-dcos-public-agent-ip_v3.sh
#

### INTERNAL ONLY: Active Edge-LB download links are within this script
 Public version requires EdgeLB download URL

DESCRIPTION: 
To start, this works the exact same as the original script.  Get the Amazon Public IP Address for the public DCOS agent nodes.  With the MLB/ELB flag it will ensure that you have the selected LB and let you know which agent has it deployed

Latest Update: Got rid of the public node input argument.
Prior Updates: Added Marathon-LB, Edge-LB (with any HAPROXY port)
#
Arguments:

\<--mlb\>  - Default: Null; This will check for Marathon-LB and deploy if necessary

\<--elb\> \<elb-local.cfg.json location\> - Default: Null; This will check for EdgeLB and deploy with your json if necessary

#
## USAGE:    get-dcos-public-agent-ip.sh \<num-pub-agents\> \<--mlb: Marathon-LB check or add\> \<--elb: EdgeLB check or add\> \<elb-local.cfg.json location\>
- get-dcos-public-agent-ip.sh
- get-dcos-public-agent-ip.sh --mlb
- get-dcos-public-agent-ip.sh --elb /Users/username/Documents/Scripts/edgelb.cfg.json

### Expected Output

Executed Command and Out default (No LB available)

```
JD # bash get-dcos-public-agent-ip_v3.sh

Using the default number of public agent nodes (2)

Starting public-ip.json marathon app

Extracting "dcos-core-cli"...
Created deployment de66422d-bb5c-486e-bc6d-bcfb06791f31

Public agent node found:  public IP is: 54.190.20.151

Public agent node found:  public IP is: 35.160.110.93
```

Executed Command and Out default (LB(s) available)

```
JD # bash get-dcos-public-agent-ip_v3.sh

  Public-IP: Pulling IPs without adding LBs

 Starting public-ip.json marathon app


    Public agent node found:  public IP is: 34.217.72.215

    Public agent node found:  public IP is: 34.219.67.216

    Public agent node found:  public IP is: 52.42.92.86
        LB Node: http://52.42.92.86:6090/haproxy?stats

    Public agent node found:  public IP is: 54.218.238.92
        LB Node: http://54.218.238.92:9090/haproxy?stats

    Public agent node found:  public IP is: 34.218.241.180
```

Executed Command and Out w/MLB (no LB installed)

```
JD # bash get-dcos-public-agent-ip_v3.sh --mlb

 Starting public-ip.json marathon app

 Created deployment 469022bd-fefd-423a-8899-75e2328200b1

 Marathon-LB Not Found: Deploying

    Public agent node found:  public IP is: 54.190.20.151
        LB Location: http://54.190.20.151:9090/haproxy?stats
 
    Public agent node found:  public IP is: 35.160.110.93
```

Executed Command and Out w/ELB (no LB installed)

```
JD # bash get-dcos-public-agent-ip_v2.sh --elb /Users/username/Documents/Scripts/edgelb.cfg.json

 Starting public-ip.json marathon app

 Edge-LB Not Found: Deploying

    Public agent node found:  public IP is: 34.217.72.215

    Public agent node found:  public IP is: 34.219.67.216

    Public agent node found:  public IP is: 52.42.92.86
         LB Location: http://52.42.92.86:6090/haproxy?stats

    Public agent node found:  public IP is: 54.218.238.92

    Public agent node found:  public IP is: 34.218.241.180
```

## Steps
Setup dcos command line

```
JD # dcos cluster setup https://jdyckowsk-elasticl-1mdecebj9wsc5-1708719683.us-west-2.elb.amazonaws.com
 Cluster Certificate Authority:

 Issuer: CN=DC/OS Root CA 6ZZ9ERZZ-3Z9Z-4Z1Z-Z1ZZ-Z6244669ZZ9Z,O=Mesosphere\, Inc.,L=San Francisco,ST=CA,C=US

 Validity:
 From:  2019-01-25 15:13:52 +0000 UTC
 Until: 2029-01-22 15:13:52 +0000 UTC

 SHA256 fingerprint: Z8:Z8:Z0:Z5:Z5:Z0:Z6:Z0:Z5:ZD:ZB:Z0:ZD:Z0:ZF:Z1:Z8:Z6:2B:ZD:ZB:Z9:Z4:Z2:Z3:Z2:ZE:Z0:Z2:Z6:Z9:Z9

 Do you trust it? [y/n] y
 Username: bootstrapuser
 Password: *****
```

Run Command
```
JD # bash get-dcos-public-agent-ip_v3.sh

 Starting public-ip.json marathon app

    Public agent node found:  public IP is: 34.217.72.215

    Public agent node found:  public IP is: 34.219.67.216

    Public agent node found:  public IP is: 52.42.92.86
        LB Location: http://52.42.92.86:6090/haproxy?stats

    Public agent node found:  public IP is: 54.218.238.92

    Public agent node found:  public IP is: 34.218.241.180
```

## EOF
