aws cloudformation update-stack \
--stack-name Lab-4-1A   \
--template-body file://Lab-4.1.7AVPC.yaml    \
--parameter file://lab4parameter1.json

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