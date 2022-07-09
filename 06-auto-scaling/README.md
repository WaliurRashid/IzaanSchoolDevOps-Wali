# Topic 6: Auto Scaling

<!-- TOC -->

- [Topic 6: Auto Scaling](#topic-6-auto-scaling)
  - [Guidance](#guidance)
  - [Lesson 6.1: Introduction to EC2 ASGs](#lesson-61-introduction-to-ec2-asgs)
    - [Principle 6.1](#principle-61)
    - [Practice 6.1](#practice-61)
      - [Lab 6.1.1: ASG from Instance](#lab-611-asg-from-instance)
        - [Question: Resources](#question-resources)
        - [Question: Parameters](#question-parameters)
      - [Lab 6.1.2: Launch Config and ASG in CFN](#lab-612-launch-config-and-asg-in-cfn)
        - [Question: ASG From Existing Instance](#question-asg-from-existing-instance)
      - [Lab 6.1.3: Launch Config Changes](#lab-613-launch-config-changes)
        - [Question: Stack Updates](#question-stack-updates)
        - [Question: Replacement Instance](#question-replacement-instance)
      - [Lab 6.1.4: ASG Update Policy](#lab-614-asg-update-policy)
        - [Question: Instance Updating](#question-instance-updating)
        - [Question: Launch Config](#question-launch-config)
      - [Lab 6.1.5: Launch Template](#lab-615-launch-template)
        - [Question: Required Info](#question-required-info)
      - [Lab 6.1.6: Cleanup](#lab-616-cleanup)
        - [Question: Stack Tear Down](#question-stack-tear-down)
    - [Retrospective 6.1](#retrospective-61)
  - [Lesson 6.2: Health Checks](#lesson-62-health-checks)
    - [Principle 6.2](#principle-62)
    - [Practice 6.2](#practice-62)
      - [Lab 6.2.1: Use awscli to Describe an ASG](#lab-621-use-awscli-to-describe-an-asg)
        - [Question: Filtering Output](#question-filtering-output)
        - [Question: Instance Timing](#question-instance-timing)
      - [Lab 6.2.2: Scale Out](#lab-622-scale-out)
        - [Question: Desired Count](#question-desired-count)
        - [Question: Update Delay](#question-update-delay)
      - [Lab 6.2.3: Manual Interference](#lab-623-manual-interference)
      - [Lab 6.2.4: Troubleshooting Features](#lab-624-troubleshooting-features)
    - [Retrospective 6.2](#retrospective-62)
      - [Question: CloudWatch](#question-cloudwatch)
  - [Lesson 6.3: Instance Metrics](#lesson-63-instance-metrics)
    - [Principle 6.3](#principle-63)
    - [Practice 6.3](#practice-63)
      - [Lab 6.3.1: Simple Scale-Out](#lab-631-simple-scale-out)
        - [Question: Scaling Interval](#question-scaling-interval)
        - [Question: Scale-In](#question-scale-in)
      - [Lab 6.3.2: Simple Scale-In](#lab-632-simple-scale-in)
        - [Question: Instance Count](#question-instance-count)
        - [Question: Termination Order](#question-termination-order)
        - [Question: Termination Policy](#question-termination-policy)
      - [Lab 6.3.3: Target Tracking policy](#lab-633-target-tracking-policy)
        - [Question: Configuration Complexity](#question-configuration-complexity)
        - [Question: Scale-Out Delay](#question-scale-out-delay)
        - [Question: Scale-In Delay](#question-scale-in-delay)
      - [Lab 6.3.4: Target Tracking Scale-In](#lab-634-target-tracking-scale-in)
        - [Question: Changing Delay](#question-changing-delay)
    - [Retrospective 6.3](#retrospective-63)
  - [Further Reading](#further-reading)

<!-- /TOC -->

## Guidance

- Explore the official docs! See the EC2 Auto Scaling [User Guide](https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html),
  [API Reference](https://docs.aws.amazon.com/autoscaling/ec2/APIReference/),
  [CLI Reference](http://docs.aws.amazon.com/cli/latest/reference/autoscaling/index.html),
  and
  [CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-as-group.html)
  docs.

- Avoid using other sites like stackoverflow.com for answers \-- part
  of the skill set you're building is finding answers straight from
  the source, AWS.

- Explore your curiosity. Try to understand why things work the way
  they do. Read more of the documentation than just what you need to
  find the answers.

## Lesson 6.1: Introduction to EC2 ASGs

### Principle 6.1

*EC2 Auto Scaling lets you simplify infrastructure code by applying the
same configuration to many instances.*

### Practice 6.1

This section gets you familiar with EC2 Auto Scaling, Amazon's original
scaling service and still one of its most useful. The User Guide's
[introduction](https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html)
is a great place to get familiar with the basic components.

#### Lab 6.1.1: ASG from Instance

In Topic 5, you created CloudFormation templates that launched EC2
instances. Let's do the simplest thing we can to create an Auto Scaling
Group (ASG): [ask Amazon to create one for us from a running instance](https://docs.aws.amazon.com/autoscaling/ec2/userguide/create-asg-from-instance.html).

- Copy one of your templates from the EC2 lessons and modify it to
  launch a t2.micro Debian instance.

```yaml
Description: CFN template to create Debian based EC2 using Launch Template resource

Resources:
  AutoScalingLaunchTemplate:
    Type: AWS::EC2::LaunchTemplate
    Properties:
      LaunchTemplateName:  ASLaunchTemplate
      LaunchTemplateData:
        InstanceType: t2.micro
        KeyName: vpclab-key-pair

  DebianInstance:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-09a41e26df464c548
      LaunchTemplate:
        LaunchTemplateId: !Ref AutoScalingLaunchTemplate
        Version: !GetAtt AutoScalingLaunchTemplate.LatestVersionNumber
      Tags:
        - Key: Name
          Value: DebianInsByLT

Outputs:
  InstanceId:
    Description: Instance ID
    Export:
      Name: Output-Debian-Instance-Id
    Value: !Ref DebianInstance
```

- Launch the stack and get the instance ID.

> $ aws cloudformation create-stack --stack-name Lab-6-1 --template-body file://Lab-6-1.yaml

- Use the AWS CLI to create an Auto Scaling Group from that instance
  ID.

- Limit the ASG to a single instance at all times.

> $ aws autoscaling create-auto-scaling-group --auto-scaling-group-name Lab-6-asg --instance-id i-091298ec67fbf758a --min-size 1 --max-size 1

##### Question: Resources

_What was created in addition to the new Auto Scaling Group?_

> Ans: In addition to the new Auto Scaling group, a new instance is created for the new auto scaling group. 

##### Question: Parameters

_What parameters did Amazon record in the resources it created for you?_

> Ans: Amazon recorded the following parameters:
> - VPC
> - Subnet
> - Security Group
> - AMI Id
> - Instance Type

#### Lab 6.1.2: Launch Config and ASG in CFN

Modify your template to explicitly create a [Launch Configuration](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-as-launchconfig.html)
and [Auto Scaling Group](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-as-group.html).
Then update the stack.

- Keep all the same parameters you kept before: same instance type,
  same limits, etc.

- Specify only the information or extra resources that you must; keep
  your template as simple as possible for these exercises. For
  example, don't add parameters to the LaunchConfiguration if
  they're just defaults; don't create other resources to associate
  with the config or ASG if the resources don't require it.

```yaml
Description: CFN template to create Auto Scaling Group using Launch Configuration

Resources:
  ASGLaunchConfig:
    Type: AWS::AutoScaling::LaunchConfiguration
    Properties:
      ImageId: ami-09a41e26df464c548
      InstanceType: t2.micro
      KeyName: vpclab-key-pair
  
  ASGforWali:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      AvailabilityZones:
        - us-east-1b
      AutoScalingGroupName: Lab-6-1-asg
      LaunchConfigurationName: !Ref ASGLaunchConfig
      MaxSize: 1
      MinSize: 1
```

Your Launch Config will look a little different than the one Amazon
created for you in Lab 6.1.1.

> Ans: Following differences was observed within two Launch config:
>   - No Security group was attached in this launch Config
>   - The IP address was found default, where ip address type was public in aws built launch config

##### Question: ASG From Existing Instance

_What config info or resources did you have to create explicitly that Amazon
created for you when launching an ASG from an existing instance?_

> Ans: I have used a running instance id, minimum & maximum size of the ASG to create explicitly that Amazon created ASG.

#### Lab 6.1.3: Launch Config Changes

Modify your launch config by increasing your instances from t2.micro to
t2.small. Update your stack.

```yaml
Description: CFN template to create Auto Scaling Group using Launch Configuration

Resources:
  ASGLaunchConfig:
    Type: AWS::AutoScaling::LaunchConfiguration
    Properties:
      ImageId: ami-09a41e26df464c548
      InstanceType: t2.small
      KeyName: vpclab-key-pair

  ASGforWali:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      AvailabilityZones:
        - us-east-1b
      AutoScalingGroupName: Lab-6-1-asg
      LaunchConfigurationName: !Ref ASGLaunchConfig
      MaxSize: 1
      MinSize: 1
```

##### Question: Stack Updates

_After updating your stack, did your running instance get replaced or resized?_

> Ans: No, after updating, my running instance were not replaced or resized.

Terminate the instance in your ASG.

##### Question: Replacement Instance

_Is the replacement instance the new size or the old?_

> Ans: The replacement instance is created with new size (t2.small).

#### Lab 6.1.4: ASG Update Policy

Change the
[UpdatePolicy](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-attribute-updatepolicy.html)
in your ASGs template so that the instance will be replaced on change,
then modify your launch config again, this time changing your instance
type to t2.medium. Update your stack.

```yaml
Description: CFN template to create Auto Scaling Group using Launch Configuration

Resources:
  ASGLaunchConfig:
    Type: AWS::AutoScaling::LaunchConfiguration
    Properties:
      ImageId: ami-09a41e26df464c548
      InstanceType: t2.medium
      KeyName: vpclab-key-pair

  ASGforWali:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      AvailabilityZones:
        - us-east-1b
      AutoScalingGroupName: Lab-6-1-1-asg
      LaunchConfigurationName: !Ref ASGLaunchConfig
      MaxSize: 1
      MinSize: 1
    UpdatePolicy:
      AutoScalingReplacingUpdate:
        WillReplace: true
```

##### Question: Instance Updating

_After updating, what did you see change? Did your running instance get
replaced this time?_

> Ans: Yes, the running instance get replaced with medium type this time. Only one thing to be remembered that the AutoScaling GroupName need to be changed.

##### Question: Launch Config

_Did the launch config change or was it replaced?_

> Ans: The launch config was replaced.

#### Lab 6.1.5: Launch Template

Finally, replace your launch config with a [Launch Template](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-launchtemplate.html),
then update your stack again. Specify only the minimum number of
parameters you need to.

```yaml
Description: CFN template to create Auto Scaling Group using Launch Configuration

Resources:
  AutoScalingLaunchTemplate:
    Type: AWS::EC2::LaunchTemplate
    Properties:
      LaunchTemplateName:  ASLaunchTemplate
      LaunchTemplateData:
        ImageId: ami-09a41e26df464c548
        InstanceType: t2.micro
        KeyName: vpclab-key-pair

  ASGforWali:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      AvailabilityZones:
        - us-east-1b
      LaunchTemplate:
        LaunchTemplateId: !Ref AutoScalingLaunchTemplate
        Version: !GetAtt AutoScalingLaunchTemplate.LatestVersionNumber
      MaxSize: 1
      MinSize: 1
    UpdatePolicy:
      AutoScalingReplacingUpdate:
        WillReplace: true
```

##### Question: Required Info

_What config info or resources do you have to provide in addition to what
Launch Configurations require?_

> Ans: There was no difference.

You'll see both launch configs and launch templates in your client
engagements. Templates were [introduced in Nov 2017](https://aws.amazon.com/about-aws/whats-new/2017/11/introducing-launch-templates-for-amazon-ec2-instances/)
and should start to become more common as time goes by. They're more
flexible: Templates can be applied to more instance classes (EC2, Spot,
Reserved), they can specify more information than Configurations, and
they are versioned instead of replaced with each change.

#### Lab 6.1.6: Cleanup

Trace out all the resources created by your stack, and the resources
associated with those. Then tear your stack down.

##### Question: Stack Tear Down

_After you tear down the stack, do all the associated resources go away?
What's left?_

> Ans: Nothing was left. Everything created by this stack was deleted.

### Retrospective 6.1

Read more about the [benefits and when to use](https://docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-benefits.html)
an ASG.

## Lesson 6.2: Health Checks

### Principle 6.2

*Auto Scaling is a high-availability solution that ensures only healthy
instances are running.*

### Practice 6.2

By default, Auto Scaling [watches VM instance health](https://docs.aws.amazon.com/autoscaling/ec2/userguide/healthcheck.html)
to know when to replace an instance. It can also use the health checks
that load balancers monitor to know whether or not applications are
healthy, but we'll cover that in a future lesson.

#### Lab 6.2.1: Use awscli to Describe an ASG

Use the AWS CLI for this process. As you work, compare what you see in
the CLI with what you see in the console, but effect all your changes
using the CLI.

Re-launch your stack, then [describe the resources](https://docs.aws.amazon.com/cli/latest/reference/cloudformation/describe-stack-resources.html).
From that output, find the name of your ASG.

```
$ aws cloudformation create-stack --stack-name Lab-6 --template-body file://Lab-6-1-4.yaml

$ aws cloudformation describe-stack-resources --stack-name Lab-6

"StackResources": [
        {
            "StackName": "Lab-6", 
            "StackId": "arn:aws:cloudformation:us-east-1:928284401303:stack/Lab-6/b9216500-fed7-11ec-abef-0ee32f6407e1",
            "LogicalResourceId": "ASGforWali",
            "PhysicalResourceId": "Lab-6-ASGforWali-1TE1GOO25ZQPV",
            "ResourceType": "AWS::AutoScaling::AutoScalingGroup",
            "Timestamp": "2022-07-08T16:06:45.636000+00:00",
            "ResourceStatus": "CREATE_COMPLETE",
            "ResourceStatus": "CREATE_COMPLETE",
            "DriftInformation": {
                "StackResourceDriftStatus": "NOT_CHECKED"
            }
        }
    ]

```

##### Question: Filtering Output

_Can you filter your output with "\--query" to print only your ASGs
resource ID? Given that name, [describe your ASG](https://docs.aws.amazon.com/cli/latest/reference/autoscaling/describe-auto-scaling-groups.html).
Find the Instance ID. Can you filter the output to print only the Instance ID
value?_

> $  aws cloudformation describe-stack-resources --stack-name Lab-6 --query "StackResources[0].PhysicalResourceId"
>
>"Lab-6-ASGforWali-1TE1GOO25ZQPV"


> $ aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name Lab-6-ASGforWali-1TE1GOO25ZQPV --query "AutoScalingGroups[0].Instances[0].InstanceId"
>
> "i-01995bc467bf88660"


(You can use the `--query` option, but you can also use
[jq](https://stedolan.github.io/jq/). Both are useful in different scenarios.)

[Kill that instance](https://docs.aws.amazon.com/cli/latest/reference/ec2/terminate-instances.html).
Describe your ASG again. Run the awscli command repeatedly until you see
the new instance launch.

```
$ aws ec2 terminate-instances --instance-ids i-01995bc467bf88660
{
    "TerminatingInstances": [
        {
            "CurrentState": {
                "Code": 32,
                "Name": "shutting-down"
            },
            "InstanceId": "i-01995bc467bf88660",
            "PreviousState": {
                "Code": 16,
                "Name": "running"
            }
        }
    ]
}

$ aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name Lab-6-ASGforWali-1TE1GOO25ZQPV --query "AutoScalingGroups[0].Instances[0].InstanceId"

"i-0dfe004f257a1b052"

```

##### Question: Instance Timing

_How long did it take for the new instance to spin up? How long before it was
marked as healthy?_

> Ans: 2 to 3 minutes

#### Lab 6.2.2: Scale Out

Watch your stack and your ASG in the web console as you do this lab.

Modify your stack template to increase the desired number of instances,
then update the stack.

##### Question: Desired Count

_Did it work? If it didn't, what else do you have to increase?_

> Ans: No, it did not work. I have to increase the MaxSize also.

```yaml
Description: CFN template to create Auto Scaling Group using Launch Configuration

Resources:
  AutoScalingLaunchTemplate:
    Type: AWS::EC2::LaunchTemplate
    Properties:
      LaunchTemplateName:  ASLaunchTemplate
      LaunchTemplateData:
        ImageId: ami-09a41e26df464c548
        InstanceType: t2.micro
        KeyName: vpclab-key-pair

  ASGforWali:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      AvailabilityZones:
        - us-east-1b
      LaunchTemplate:
        LaunchTemplateId: !Ref AutoScalingLaunchTemplate
        Version: !GetAtt AutoScalingLaunchTemplate.LatestVersionNumber
      MaxSize: 2
      MinSize: 1
      DesiredCapacity: 2
    UpdatePolicy:
      AutoScalingReplacingUpdate:
        WillReplace: true
``` 

##### Question: Update Delay

_How quickly after your stack update did you see the ASG change?_

> It was very fast. Around 10 t0 15 sec.

#### Lab 6.2.3: Manual Interference

Take one of your instances [out of your ASG manually](http://docs.aws.amazon.com/cli/latest/reference/autoscaling/set-instance-health.html)
using the CLI. Observe Auto Scaling as it launches a replacement
instance. Take note of what it does with the instance you marked
unhealthy.

> Ans: The instance which was marked unhealthy was automatically terminated once the replacement instance created. 

#### Lab 6.2.4: Troubleshooting Features

Simply killing a failing server feels like an easy remedy when all your
infrastructure is code and your systems are
[immutable](https://stelligent.com/glossary/).
It's usually helpful to know why something failed, though, and when you
have to do some debugging, the ASG system offers a few options,
including [placing a server on standby](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-enter-exit-standby.html#standby-instance-health-status)
or [suspending auto-scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-suspend-resume-processes.html).

Standby allows you to take an instance out of action without changing
anything else: no new instance is created, the standby one isn't
terminated, even its health check remains as it was before standby.
Manually put an instance on standby [using the CLI](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-enter-exit-standby.html#standby-state-aws-cli).
Observe your ASG in the console and see for yourself that the health
check status doesn't change and the scaled group hasn't changed. Put the
instance back in action. Note the commands you used and the change to
the lifecycle state of the instance after each change.

```
$ aws autoscaling describe-auto-scaling-instances

$ aws autoscaling enter-standby --instance-ids i-0ce62c96c60123824 --auto-scaling-group-name Lab-6-ASGforWali-1TE1GOO25ZQPV --should-decrement-desired-capacity

{
    "Activities": [
        {
            "ActivityId": "1936077e-a199-c1f8-e27a-910ac29fff90",
            "AutoScalingGroupName": "Lab-6-ASGforWali-1TE1GOO25ZQPV",
            "Description": "Moving EC2 instance to Standby: i-0ce62c96c60123824",
            "Cause": "At 2022-07-08T21:12:44Z instance i-0ce62c96c60123824 was moved to standby in response to a user request, shrinking the capacity from 2 to 1.",   
            "StartTime": "2022-07-08T21:12:44.400000+00:00",
            "StatusCode": "InProgress",
            "Progress": 50,
            "Details": "{\"Availability Zone\":\"us-east-1b\"}"
        }
    ]
}

$ aws autoscaling describe-auto-scaling-instances

{                                               
    "AutoScalingInstances": [                   
        {                                       
            "InstanceId": "i-0ce62c96c60123824",
            "InstanceType": "t2.micro",         
            "AutoScalingGroupName": "Lab-6-ASGforWali-1TE1GOO25ZQPV",
            "AvailabilityZone": "us-east-1b",
            "LifecycleState": "Standby",
            "HealthStatus": "HEALTHY",
            "LaunchTemplate": {
                "LaunchTemplateId": "lt-0c264df3e90194fab",
                "LaunchTemplateName": "ASLaunchTemplate",
                "Version": "1"
            },
            "ProtectedFromScaleIn": false

$ aws autoscaling exit-standby --instance-ids i-0ce62c96c60123824 --auto-scaling-group-name Lab-6-ASGforWali-1TE1GOO25ZQPV
```


Read through the [Scaling Processes](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-suspend-resume-processes.html#process-types)
section in the suspending auto-scaling doc. It gives you a lot of
flexibility. For example, if you have a problematic deployment, you may
want to disable AddToLoadBalancer, launch a new instance by [[increasing the desired
size]](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-manual-scaling.html#as-manual-scaling-console)
of the ASG, and then running some tests on the live infrastructure while
it's deployed to the sidelines. We're not using a load balancer right
now, so we can't exercise AddToLoadBalancer, but let's take a look at
another. Disable Launch, then put an instance on standby and back in
action again. Note the process you have to go through, including any
commands you run.

```
$ aws autoscaling suspend-processes --auto-scaling-group-name Lab-6-ASGforWali-1TE1GOO25ZQPV --scaling-processes Launch

After suspension, I have terminated one of the instances from my ASG. It was found that no instance is replacing.

$ aws autoscaling resume-processes --auto-scaling-group-name Lab-6-ASGforWali-1TE1GOO25ZQPV --scaling-processes Launch

After resuming the state, the replacement instance was started creating within no time.
```

### Retrospective 6.2

#### Question: CloudWatch

_How would you use AWS CloudWatch to help monitor your ASG?_

You can read more [here](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-instance-monitoring.html)
about CloudWatch monitoring with ASGs.

## Lesson 6.3: Instance Metrics

### Principle 6.3

*Auto Scaling ensures you always maintain resources that match your
performance & cost needs.*

### Practice 6.3

In this lesson, we'll work with [CloudWatch Alarms](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-cw-alarm.html)
to scale our ASG in our out according to load. This is part of the
original scaling method Amazon offered for EC2, now called [[Simple Scaling
Policies]](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-simple-step.html).

#### Lab 6.3.1: Simple Scale-Out

Add a CloudWatch Alarm to your template and associate it with your ASG.

- Watch for CPU utilization above 60% over a period of 2 minutes and
  [scale the group](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-as-policy.html)
  out (or "up").

- Ensure that your desired number of instances is lower than your max
  number.

Update your stack, then ssh to one of the instances. Do something that
will consume a lot of CPU on that instance and let it run for 2 minutes.
(For example, on Debian/Ubuntu, "apt-get install
[stress](https://people.seas.harvard.edu/~apw/stress/)"
and use that command to spike the load.)

##### Question: Scaling Interval

_After the scaling interval, do you see a new instance created?_

Stop the CPU-consuming process.

##### Question: Scale-In

_After the load has been low for a few minutes, do you see any instances terminated?_

#### Lab 6.3.2: Simple Scale-In

Add another alarm, this time to allow the group to scale back in (or
"down"):

- Watch for CPU utilization below 40% over a period of 2 minutes and
  scale in.

Update your stack.

##### Question: Instance Count

_Do you see more instances than the configured "desired capacity"?_

##### Question: Termination Order

_If an instance is automatically terminated, which is it, the last one created
or the first?_

##### Question: Termination Policy

_Can you change your policies to alter which instance gets terminated first?_

#### Lab 6.3.3: Target Tracking policy

Replace your simple scale-out policy with the more modern [[target tracking scaling
policy]](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-target-tracking.html):

- Use a [predefined metric](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-autoscaling-scalingpolicy-targettrackingconfiguration.html)
  to modify CPU utilization.

- Disable scaling in so that your original simple scale-in policy is
  the only one used to reduce the size of the group.

*NOTE: If you get an error from CloudFormation saying you can't modify
the policy, do it in 2 separate steps: first delete your scale-out
policy and update your stack, then add your target tracking policy and
update your stack again.*

##### Question: Configuration Complexity

_Is your resulting configuration more or less complicated than the one that
uses a simple policy?_

Consume CPU the way you did in lab 1, then stop.

##### Question: Scale-Out Delay

_How long do you have to let it run before you see the group scale out?_

##### Question: Scale-In Delay

_How much time passes after you stop before it scales back in?_

#### Lab 6.3.4: Target Tracking Scale-In

Now eliminate your simple scale-in policy and enable scale-in on your
target tracking policy. Update your stack, then consume CPU again until
an instance is added.

##### Question: Changing Delay

_After you stop consuming CPU, how long does it take now before scale-in?_

### Retrospective 6.3

In addition to configuring things yourself, you can integrate
[Elastic Load Balancing](https://docs.aws.amazon.com/autoscaling/ec2/userguide/autoscaling-load-balancer.html)
with your ASG.

## Further Reading

- Make sure you're familiar with the issues brought up in the [EC2 Auto Scaling FAQ](https://aws.amazon.com/ec2/autoscaling/faqs/).

- AWS Auto Scaling:

  - A generic service [introduced in Jan 2018](https://aws.amazon.com/about-aws/whats-new/2018/01/introducing-aws-auto-scaling/).
    It works with a variety of resources beyond EC2.

  - See the [AWS Auto Scaling Overview](https://aws.amazon.com/autoscaling/)
    for a nice summary. In particular, this sheds some light: "If
    you're already using Amazon EC2 Auto Scaling to dynamically
    scale your Amazon EC2 instances, you can now combine it with
    AWS Auto Scaling to scale additional resources for other AWS
    services."

  - AWS Auto Scaling service works with stacks or [resource tags](https://aws.amazon.com/about-aws/whats-new/2018/04/announcing-enhancements-to-aws-auto-scaling/),
    a significant difference from the way EC2 ASGs scale out their
    resources.
