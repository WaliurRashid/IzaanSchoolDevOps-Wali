#!/bin/bash

aws cloudformation create-stack --stack-name ec2lauchtemplate2 --template-body file://Lab-5.1.2.EC2.yaml

aws cloudformation wait stack-create-complete --stack-name ec2lauchtemplate2
