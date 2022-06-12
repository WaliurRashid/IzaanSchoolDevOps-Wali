01. Clouformation:
 - Create Stack
 $ aws cloudformation create-stack --stack-name s3bucket --template-body file://CreateBucket.yaml
 - Update Stack
 $ aws cloudformation uodate-stack --stack-name s3bucket --template-body file://CreateBucket.yaml

 - Termination Protection enabling
 aws cloudformation update-termination-protection \
     --stack-name s3BucketCreation \
     --enable-termination-protection

 -delete stack

 aws cloudformation delete-stack --stack-name s3BucketCreation

  - Termination Protection enabling
  aws cloudformation update-termination-protection \
      --stack-name s3BucketCreation \
      --no-enable-termination-protection




