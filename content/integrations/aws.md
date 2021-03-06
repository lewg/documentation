---
title: Datadog-AWS Cloudwatch Integration
kind: documentation
sidebar:
  nav:
    - header: AWS integration
    - text: Configure CloudWatch
      href: "#cloudwatch"
    - text: Configure CloudTrail
      href: "#cloudtrail"
    - text: Troubleshooting
      href: "#troubleshooting"
    - header: Integrations
    - text: Back to Overview
      href: "/integrations/"
---


### Configure CloudWatch
{: #cloudwatch} 

The recommended way to configure Cloudwatch in Datadog is to create a
new user via the [IAM Console][1] and grant that user (or group of users) a set of permissions. 

At the very least, you need to grant **Amazon EC2, Cloudwatch *read-only* access**.

These can be set via policy templates in the console or using Amazon's API.

If you are using RDS, SES, SNS, or other AWS features, you will need to grant the user additional permissions. Here is the current list of permissions
required to take full advantage of the Datadog AWS integration. As we add other components to the integration, these permissions may change.

    {
      "Statement": [
        {
          "Action": [
            "cloudtrail:DescribeTrails"
            "cloudtrail:GetTrailStatus"
            "cloudwatch:Describe*"
            "cloudwatch:Get*"
            "cloudwatch:List*"
            "ec2:Describe*"
            "elasticloadbalancing:Describe*"
            "iam:Get*"
            "iam:List*"
            "rds:Describe*"
            "rds:List*"
            "ses:Get*"
            "ses:List*"
            "sns:Get*"
            "sns:List*"
            "sqs:GetQueueAttributes"
            "sqs:ListQueues"
            "sqs:ReceiveMessage"
          ],
          "Effect": "Allow",
          "Resource": "*"
        }
      ]
    }

Once these credentials are configured within AWS, go into the [AWS integration tile][2] within Datadog to pull this data in. 



### CloudTrail integration
{: #cloudtrail}

AWS CloudTrail records AWS API calls for your account in log files. Datadog can read these files and create events in your stream. Here is an example of a CloudTrail event:

![](/static/images/cloudtrail_event.png)


#### How to configure CloudTrail?
{: #config-cloudtrail}

First make sure that you have configured CloudWatch and that the user you created for Datadog has the **AWS CloudTrail read-only access**. See above explanation. Besides the instructions below you will also have to configure the separate [Cloudtrail integration tile][3] within Datadog. 

CloudTrail has to be configured on a per-region basis. Make sure you complete the two steps below for **all regions** that you want Datadog to collect CloudTrail data from. 


1. [Go to your CloudTrail console][4] to enable it. Then select the S3 bucket you wish to use as follows: 
![](/static/images/cloudtrail_config.png) 
2. Your user must have access to the S3 bucket you have selected. To grant your user read-only access to your bucket, you would paste the following policy in the IAM console: 

        { "Statement": [ 
          { 
            "Action": [ 
              "s3:ListBucket", 
              "s3:GetBucketLocation", 
              "s3:GetObject" 
            ], 
            "Effect": "Allow", 
            "Resource": [ 
              "arn:aws:s3:::your-s3-bucket-name", 
              "arn:aws:s3:::your-s3-bucket-name/*" 
            ] 
          } ] 
        }


#### What events are collected?

Below is the list of events that Datadog will collect from CloudTrail and display in your event stream. If you would like to see other events that are not mentionned here, please reach out to [our support team][5].


**EC2 Actions**  
AttachVolume  
AuthorizeSecurityGroup  
CreateSecurityGroup  
CreateVolume  
CreateTags  
DeleteVolume  
DeleteTags  
DetachVolume  
RebootInstances  
RevokeSecurityGroupEgress  
RevokeSecurityGroupIngress  
RunInstances  
StartInstances  
StopInstances  
TerminateInstances

**RDS Actions**  
CreateDBInstance  
RebootDBInstance  
ModifyDBInstance  
DeleteDBInstance  

**IAM Actions**  
AddRoleToInstanceProfile  
AddUserToGroup  
ChangePassword  
CreateAccessKey  
CreateAccountAlias  
CreateGroup  
CreateInstanceProfile  
CreateLoginProfile  
CreateRole  
CreateSAMLProvider  
CreateUser  
CreateVirtualMFADevice  
DeleteAccessKey  
DeleteAccountAlias  
DeleteAccountPasswordPolicy  
DeleteGroup  
DeleteGroupPolicy  
DeleteInstanceProfile  
DeleteLoginProfile  
DeleteRole  
DeleteRolePolicy  
DeleteSAMLProvider  
DeleteServerCertificate  
DeleteSigningCertificate  
DeleteUser  
DeleteUserPolicy  
DeleteVirtualMFADevice  
PutGroupPolicy  
PutRolePolicy  
PutUserPolicy  
RemoveRoleFromInstanceProfile  
RemoveUserFromGroup  
UpdateAccessKey  
UpdateAccountPasswordPolicy  
UpdateAssumeRolePolicy  
UpdateGroup  
UpdateLoginProfile  
UpdateSAMLProvider  
UpdateServerCertificate  
UpdateSigningCertificate  
UpdateUser  
UpdateServerCertificate  
UpdateSigningCertificate  

**VPC Actions**  
AssociateDhcpOptions  
AssociateRouteTable  
AttachVpnGateway  
CreateCustomerGateway  
CreateDhcpOptions  
CreateRouteTable  
CreateVpnConnection  
CreateVpnConnectionRoute  
CreateVpnGateway  
DeleteCustomerGateway  
DeleteDhcpOptions  
DeleteRouteTable  
DeleteVpnConnection  
DeleteVpnConnectionRoute  
DeleteVpnGateway  
DetachVpnGateway  
DisassociateRouteTable  
ReplaceRouteTableAssociation  

**ELB Actions**  
ApplySecurityGroupsToLoadBalancer  
AttachLoadBalancerToSubnets  
ConfigureHealthCheck  
CreateAppCookieStickinessPolicy  
CreateLBCookieStickinessPolicy  
CreateLoadBalancer  
CreateLoadBalancerListeners  
CreateLoadBalancerPolicy  
DeleteLoadBalancer  
DeleteLoadBalancerListeners  
DeleteLoadBalancerPolicy  
DeregisterInstancesFromLoadBalancer  
DetachLoadBalancerFromSubnets  
DisableAvailabilityZonesForLoadBalancer  
EnableAvailabilityZonesForLoadBalancer  
ModifyLoadBalancerAttributes  
RegisterInstancesWithLoadBalancer  
SetLoadBalancerListenerSSLCertificate  
SetLoadBalancerPoliciesForBackendServer  
SetLoadBalancerPoliciesOfListener  





### Troubleshooting
{: #troubleshooting}

#### Do you believe you're seeing a discrepancy between your data in Cloudwatch and Datadog?

There are two important distinctions to be aware of:

  1. In AWS for counters, a graph that is set to 'sum' '1minute' shows the total number of occurrences in one minute leading up to that point, i.e. the rate per 1 minute. Datadog is displaying the raw data from AWS normalized to per second values, regardless of the timeframe selected in AWS, which is why you will probably see our value as lower.
  2. Overall, min/max/avg have a different meaning within AWS than in Datadog. In AWS, average latency, minimum latency, and maximum latency are three distinct metrics that AWS collects. When Datadog pulls metrics from AWS Cloudwatch, we only get the average latency as a single time series per ELB. Within Datadog, when you are selecting 'min', 'max', or 'avg', you are controlling how multiple time series will be combined. For example, requesting `system.cpu.idle` without any filter would return one series for each host that reports that metric and those series need to be combined to be graphed. On the other hand, if you requested `system.cpu.idle` from a single host, no aggregation would be necessary and switching between average and max would yield the same result.




#### Metrics delayed?

When using the AWS integration, we're pulling in metrics via the Cloudwatch API. You may see a slight delay in metrics from AWS due to some constraints that exist for their API.

To begin, the Cloudwatch API only offers a metric-by-metric crawl to pull data. The Cloudwatch APIs have a rate limit that varies based on the combination of authentication credentials, region, and service. Metrics are made available by AWS dependent on the account level. For example, if you are paying for "detailed metrics" within AWS, they are available more quickly. This level of service for detailed metrics also applies to granularity, with some metrics being available per minute and others per five minutes.

On the Datadog side, we do have the ability to prioritize certain metrics within an account to pull them in faster, depending on the circumstances. Please contact [support@datadoghq.com][6] for more info on this.

To obtain metrics with virtually zero delay, we recommend installing the Datadog Agent on those hosts. We’ve 
written a bit about this [here][7],  especially in relation to CloudWatch.

   [1]: https://console.aws.amazon.com/iam/home#s=Home
   [2]: https://app.datadoghq.com/account/settings#integrations/amazon_web_services
   [3]: https://app.datadoghq.com/account/settings#integrations/cloudtrail
   [4]: https://console.aws.amazon.com/cloudtrail
   [5]: /help
   [6]: mailto:support@datadoghq.com
   [7]: http://www.datadoghq.com/2013/10/dont-fear-the-agent
