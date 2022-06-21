

aws cloudformation create-stack \
--stack-name Lab-4-1B   \
--template-body file://Lab-4.1.7A.EC2.yaml    \
--parameter file://lab4parameter2.json

aws cloudformation update-stack \
--stack-name Lab-4-1A   \
--template-body file://Lab-4.1.2.yaml    \
--parameter file://lab4parameter1.json

aws cloudformation update-stack \
--stack-name Lab-4-1B   \
--template-body file://Lab-4.1.5.yaml    \
--parameter file://lab4parameter2.json

aws cloudformation create-stack \
--stack-name Lab-4-1A   \
--template-body file://Lab-4.1.2.yaml    \
--parameter file://lab4parameter1.json

aws cloudformation create-stack \
--stack-name Lab-4-2A   \
--template-body file://Lab-4.2.1.vpc.yaml    \
--parameter file://lab4parameter3.json

aws cloudformation create-stack \
--stack-name Lab-4-2B   \
--template-body file://Lab-4.2.1.peer.yaml

aws cloudformation update-stack \
--stack-name Lab-4-2C   \
--template-body file://Lab-4.2.2.EC2.yaml    \
--parameter file://lab4parameter2.json

aws cloudformation update-stack \
--stack-name Lab-4-1A   \
--template-body file://Lab-4.1.2.yaml    \
--parameter file://lab4parameter1.json

1. VPC A

aws cloudformation create-stack \
--stack-name Lab-4-2A   \
--template-body file://Lab-4.1.2.yaml    \
--parameter file://lab4parameter1.json

2. VPC B rejion us-west-1

aws cloudformation create-stack \
--stack-name Lab-4-2B   \
--template-body file://Lab-4.2.1.vpc.yaml    \
--parameter file://lab4parameter3.json  \
--region us-west-1

3. Peer

aws cloudformation create-stack \
--stack-name Lab-4-2C   \
--template-body file://Lab-4.2.1.peer.yaml  \
--parameter file://lab4parameterpeer.json

4. EC 2

aws cloudformation create-stack \
--stack-name Lab-4-2D   \
--template-body file://Lab-4.2.2.EC2.yaml    \
--parameter file://lab4parameter2.json

