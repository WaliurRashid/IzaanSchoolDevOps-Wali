01. Clouformation:
 - Create Stack
 $ aws cloudformation create-stack --stack-name s3bucket --template-body file://CreateBucket.yaml


 Description: This is a simple format to create a s3 bucket
 Parameters:
   NameYourBucket:
     Description: Please enter the name of your Bucket here
     Type: String

   MyPreferredRegion:
     Description: Please enter your preferred region
     Type: String

 #  AWS::Region:
 #    Default: us-east-1
 #    Type: String

 Conditions:
   prefixAccountId: !Equals
     - !Ref AWS::Region
     - !Ref MyPreferredRegion

 #  prefixRegionName:

 Resources:
   S3BUCKET:
     Type: AWS::S3::Bucket
     Properties:
       Condition: prefixAccountId
       BucketName: !Join
         - ''
         - - !Ref AWS::AccountId
           - !Ref NameYourBucket
 #      if [prefixAccountId, !Join ["", [!Ref AWS::AccountId, !Ref NameYourBucket ]], !Join ["", [!Ref AWS::Region, !Ref NameYourBucket ]]]
