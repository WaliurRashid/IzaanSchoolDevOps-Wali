#!/bin/bash

aws cloudformation update-stack --stack-name ec2lauchtemplate2 --template-body file://Lab-5.1.2.EC2.yaml

aws cloudformation wait stack-update-complete --stack-name ec2lauchtemplate2