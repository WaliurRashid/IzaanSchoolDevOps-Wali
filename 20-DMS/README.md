# Topic 20 AWS DMS 

<!-- TOC -->

- [Topic 20: AWS DMS](#topic-20-aws-AWS-DMS)
  - [Lesson 20.1: Introduction to AWS DMS](#lesson-201-introduction-to-AWS-DMS)
    - [Practice 20.1](#practice-201)
      - [Lab 20.1.1: Create an Aurora Postgresql Database Using CF](#lab-2011-create-an-aurora-postgresql-database-using-cf)
      - [Lab 20.1.2: In same CF template add Two DMS instances and below components ](#lab-2012-in-same-cf-template-add-two-dms-instances-and-below-components)
      - [Lab 20.1.3: DMS Task Recovery ](#lab-2013-dms-task-recovery)
      - [Lab 20.1.4: RDS Password Rotation using AWS SSM ](#lab-202-rds-password-rotation-using-aws-ssm-additional)
      
<!-- /TOC -->

## Lesson 20.1: Introduction to AWS DMS

*AWS Database Migration Service (AWS DMS) helps you migrate databases to AWS quickly and securely. The source database remains fully operational during the migration, minimizing downtime to applications that rely on the database. The AWS Database Migration Service can migrate your data to and from the most widely used commercial and open-source databases.*

### Practice 20.1

You will understand the AWS DMS Service and be able to provision the DMS components using cloudformation.

#### Lab 20.1.1: Create an Aurora Postgresql Database Using CF
  - Store DB service user credential in AWS Secret Manager
    - Suggested Format for SSM parameter: ProductName/AppName/Env/SecretName

#### Lab 20.1.2: In same CF template add Two DMS instances and below components 
  - 5 S3 Buckets
  - One Source End Point (Source Target is S3)
  - One Destination End Point (Destination Target is Aurora Postgresql created in lab 20.1.1). Use SSM parameters for DB credentials.
  - 5 DMS Tasks

```yaml
Description: CFN Template to create Aurora Postgesql DB
Parameters:
  EngineVersion:
    Type: String
    Default: 13.6
    AllowedValues:
      - 13.3
      - 13.4
      - 13.5
      - 13.6
      - 13.7
Resources:
  Lab20RDSCluster:
    Type: AWS::RDS::DBCluster
    Properties:
      DatabaseName: dbpostgres
      DBClusterIdentifier: dbpostgres-cluster
      AvailabilityZones:
        - us-east-1a
      Engine: aurora-postgresql
      EngineVersion: !Ref EngineVersion
      Port: 5432
      MasterUsername: '{{resolve:secretsmanager:OpenSearchCredential:SecretString:username}}'
      MasterUserPassword: '{{resolve:secretsmanager:OpenSearchCredential:SecretString:password}}'

  Lab20RDSInstance1:
    Type: AWS::RDS::DBInstance
    Properties:
      DBClusterIdentifier: !Ref Lab20RDSCluster
      Engine: aurora-postgresql
      DBInstanceClass: db.t4g.medium
      DBInstanceIdentifier: Lab20Cluster-Instance1
      PubliclyAccessible: true
      AvailabilityZone: us-east-1a

  Lab20RDSInstance2:
    Type: AWS::RDS::DBInstance
    Properties:
      DBClusterIdentifier: !Ref Lab20RDSCluster
      Engine: aurora-postgresql
      DBInstanceClass: db.t4g.medium
      DBInstanceIdentifier: Lab20Cluster-Instance2
      PubliclyAccessible: true
      AvailabilityZone: us-east-1a

  Lab20RDSInstance3:
    Type: AWS::RDS::DBInstance
    Properties:
      DBClusterIdentifier: !Ref Lab20RDSCluster
      Engine: aurora-postgresql
      DBInstanceClass: db.t4g.medium
      DBInstanceIdentifier: Lab20Cluster-Instance3
      PubliclyAccessible: true
      SourceDBInstanceIdentifier: !Ref Lab20RDSCluster.lab20cluster-instance2

  Lab20DMSInstance1:
    Type: AWS::DMS::ReplicationInstance
    Properties:
      AllocatedStorage: 5
      ReplicationInstanceClass: dms.t3.micro
      ReplicationInstanceIdentifier: dmsinstans-1
      PubliclyAccessible: true

  Lab20DMSInstance2:
    Type: AWS::DMS::ReplicationInstance
    Properties:
      AllocatedStorage: 5
      ReplicationInstanceClass: dms.t3.micro
      ReplicationInstanceIdentifier: dmsinstans-2
      PubliclyAccessible: true

  s3Bucket1:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: bucketfordms1-wali

  s3Bucket2:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: bucketfordms2-wali

  s3Bucket3:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: bucketfordms3-wali

  s3Bucket4:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: bucketfordms4-wali

  s3Bucket5:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: bucketfordms5-wali

  s3Bucket6:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: bucketfordms6-wali

  SourceEndPointForBucket1:
    Type: AWS::DMS::Endpoint
    Properties:
      EndpointIdentifier: SourceEndPointForBucket1
      EndpointType: source
      EngineName: s3
      S3Settings:
        BucketName: bucketfordms1-wali
        IgnoreHeaderRows: 1
        ServiceAccessRoleArn: !GetAtt RoleForTargetEndpoint.Arn
        ExternalTableDefinition:  >
          {
              "TableCount": "1",
              "Tables": [
                  {
                      "TableName": "employee",
                      "TablePath": "hr/employee/",
                      "TableOwner": "hr",
                      "TableColumns": [
                          {
                              "ColumnName": "Id",
                              "ColumnType": "INT8",
                              "ColumnNullable": "false",
                              "ColumnIsPk": "true"
                          },
                          {
                              "ColumnName": "LastName",
                              "ColumnType": "STRING",
                              "ColumnLength": "20"
                          },
                          {
                              "ColumnName": "FirstName",
                              "ColumnType": "STRING",
                              "ColumnLength": "30"
                          },
                          {
                              "ColumnName": "HireDate",
                              "ColumnType": "DATETIME"
                          },
                          {
                              "ColumnName": "OfficeLocation",
                              "ColumnType": "STRING",
                              "ColumnLength": "20"
                          }
                      ],
                      "TableColumnsTotal": "5"
                  }
              ]
          }

  SourceEndPointForBucket2:
    Type: AWS::DMS::Endpoint
    Properties:
      EndpointIdentifier: SourceEndPointForBucket2
      EndpointType: source
      EngineName: s3
      S3Settings:
        BucketName: bucketfordms2-wali
        ServiceAccessRoleArn: !GetAtt RoleForTargetEndpoint.Arn
        ExternalTableDefinition: >
          {
              "TableCount": "1",
              "Tables": [
                  {
                      "TableName": "employee",
                      "TablePath": "hr/employee/",
                      "TableOwner": "hr",
                      "TableColumns": [
                          {
                              "ColumnName": "Id",
                              "ColumnType": "INT8",
                              "ColumnNullable": "false",
                              "ColumnIsPk": "true"
                          },
                          {
                              "ColumnName": "LastName",
                              "ColumnType": "STRING",
                              "ColumnLength": "20"
                          },
                          {
                              "ColumnName": "FirstName",
                              "ColumnType": "STRING",
                              "ColumnLength": "30"
                          },
                          {
                              "ColumnName": "HireDate",
                              "ColumnType": "DATETIME"
                          },
                          {
                              "ColumnName": "OfficeLocation",
                              "ColumnType": "STRING",
                              "ColumnLength": "20"
                          }
                      ],
                      "TableColumnsTotal": "5"
                  }
              ]
          }
        IgnoreHeaderRows: 1

  SourceEndPointForBucket3:
    Type: AWS::DMS::Endpoint
    Properties:
      EndpointIdentifier: SourceEndPointForBucket3
      EndpointType: source
      EngineName: s3
      S3Settings:
        BucketName: bucketfordms3-wali
        ServiceAccessRoleArn: !GetAtt RoleForTargetEndpoint.Arn
        CannedAclForObjects: public-read
        ExternalTableDefinition: >
          {
              "TableCount": "1",
              "Tables": [
                  {
                      "TableName": "employee",
                      "TablePath": "hr/employee/",
                      "TableOwner": "hr",
                      "TableColumns": [
                          {
                              "ColumnName": "Id",
                              "ColumnType": "INT8",
                              "ColumnNullable": "false",
                              "ColumnIsPk": "true"
                          },
                          {
                              "ColumnName": "LastName",
                              "ColumnType": "STRING",
                              "ColumnLength": "20"
                          },
                          {
                              "ColumnName": "FirstName",
                              "ColumnType": "STRING",
                              "ColumnLength": "30"
                          },
                          {
                              "ColumnName": "HireDate",
                              "ColumnType": "DATETIME"
                          },
                          {
                              "ColumnName": "OfficeLocation",
                              "ColumnType": "STRING",
                              "ColumnLength": "20"
                          }
                      ],
                      "TableColumnsTotal": "5"
                  }
              ]
          }
        IgnoreHeaderRows: 1

  SourceEndPointForBucket4:
    Type: AWS::DMS::Endpoint
    Properties:
      EndpointIdentifier: SourceEndPointForBucket4
      EndpointType: source
      EngineName: s3
      S3Settings:
        BucketName: bucketfordms4-wali
        ServiceAccessRoleArn: !GetAtt RoleForTargetEndpoint.Arn
        ExternalTableDefinition: >
          {
              "TableCount": "1",
              "Tables": [
                  {
                      "TableName": "employee",
                      "TablePath": "hr/employee/",
                      "TableOwner": "hr",
                      "TableColumns": [
                          {
                              "ColumnName": "Id",
                              "ColumnType": "INT8",
                              "ColumnNullable": "false",
                              "ColumnIsPk": "true"
                          },
                          {
                              "ColumnName": "LastName",
                              "ColumnType": "STRING",
                              "ColumnLength": "20"
                          },
                          {
                              "ColumnName": "FirstName",
                              "ColumnType": "STRING",
                              "ColumnLength": "30"
                          },
                          {
                              "ColumnName": "HireDate",
                              "ColumnType": "DATETIME"
                          },
                          {
                              "ColumnName": "OfficeLocation",
                              "ColumnType": "STRING",
                              "ColumnLength": "20"
                          }
                      ],
                      "TableColumnsTotal": "5"
                  }
              ]
          }
        IgnoreHeaderRows: 1

  SourceEndPointForBucket5:
    Type: AWS::DMS::Endpoint
    Properties:
      EndpointIdentifier: SourceEndPointForBucket5
      EndpointType: source
      EngineName: s3
      S3Settings:
        BucketName: bucketfordms5-wali
        ServiceAccessRoleArn: !GetAtt RoleForTargetEndpoint.Arn
        ExternalTableDefinition: >
          {
              "TableCount": "1",
              "Tables": [
                  {
                      "TableName": "employee",
                      "TablePath": "hr/employee/",
                      "TableOwner": "hr",
                      "TableColumns": [
                          {
                              "ColumnName": "Id",
                              "ColumnType": "INT8",
                              "ColumnNullable": "false",
                              "ColumnIsPk": "true"
                          },
                          {
                              "ColumnName": "LastName",
                              "ColumnType": "STRING",
                              "ColumnLength": "20"
                          },
                          {
                              "ColumnName": "FirstName",
                              "ColumnType": "STRING",
                              "ColumnLength": "30"
                          },
                          {
                              "ColumnName": "HireDate",
                              "ColumnType": "DATETIME"
                          },
                          {
                              "ColumnName": "OfficeLocation",
                              "ColumnType": "STRING",
                              "ColumnLength": "20"
                          }
                      ],
                      "TableColumnsTotal": "5"
                  }
              ]
          }
        IgnoreHeaderRows: 1

  SourceEndPointForBucket6:
    Type: AWS::DMS::Endpoint
    Properties:
      EndpointIdentifier: SourceEndPointForBucket6
      EndpointType: source
      EngineName: s3
      S3Settings:
        BucketName: bucketfordms6-wali
        ServiceAccessRoleArn: !GetAtt RoleForTargetEndpoint.Arn
        ExternalTableDefinition: >
          {
              "TableCount": "1",
              "Tables": [
                  {
                      "TableName": "employee",
                      "TablePath": "hr/employee/",
                      "TableOwner": "hr",
                      "TableColumns": [
                          {
                              "ColumnName": "Id",
                              "ColumnType": "INT8",
                              "ColumnNullable": "false",
                              "ColumnIsPk": "true"
                          },
                          {
                              "ColumnName": "LastName",
                              "ColumnType": "STRING",
                              "ColumnLength": "20"
                          },
                          {
                              "ColumnName": "FirstName",
                              "ColumnType": "STRING",
                              "ColumnLength": "30"
                          },
                          {
                              "ColumnName": "HireDate",
                              "ColumnType": "DATETIME"
                          },
                          {
                              "ColumnName": "OfficeLocation",
                              "ColumnType": "STRING",
                              "ColumnLength": "20"
                          }
                      ],
                      "TableColumnsTotal": "5"
                  }
              ]
          }
        IgnoreHeaderRows: 1

  TargetEndPoint:
    Type: AWS::DMS::Endpoint
    Properties:
      DatabaseName: dbpostgres
      EndpointIdentifier: TargetEndpointForLab20
      EndpointType: target
      EngineName: aurora-postgresql
      ServerName: !GetAtt Lab20RDSCluster.Endpoint.Address
      Username: '{{resolve:secretsmanager:OpenSearchCredential:SecretString:username}}'
      Password: '{{resolve:secretsmanager:OpenSearchCredential:SecretString:password}}'
      Port: 5432

  RoleForTargetEndpoint:
    Type: AWS::IAM::Role
    Properties:
      RoleName: RoleForTargetEndpoint
      AssumeRolePolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: Allow
            Principal:
              Service: dms.us-east-1.amazonaws.com
            Action:
              - 'sts:AssumeRole'
      Policies:
        - PolicyName: PolicyforDMS
          PolicyDocument:
            Version: 2012-10-17
            Statement:
              - Effect: Allow
                Action:
                  - secretsmanager:GetRandomPassword
                  - secretsmanager:GetResourcePolicy
                  - secretsmanager:GetSecretValue
                  - secretsmanager:DescribeSecret
                  - secretsmanager:ListSecretVersionIds
                Resource: arn:aws:secretsmanager:us-east-1:928284401303:secret:OpenSearchCredential-EmwhVe
        - PolicyName: PolicyforS3
          PolicyDocument:
            Version: 2012-10-17
            Statement:
              - Effect: Allow
                Action:
                  - iam:PassRole
                  - iam:GetRole
                  - s3:Get*
                  - s3:List*
                  - s3:Put*
                Resource:
                  - arn:aws:s3:::bucketfordms2-wali
                  - arn:aws:s3:::bucketfordms2-wali
                  - arn:aws:s3:::bucketfordms3-wali
                  - arn:aws:s3:::bucketfordms4-wali
                  - arn:aws:s3:::bucketfordms5-wali
                  - arn:aws:s3:::bucketfordms6-wali

  ReplicationTask1:
    Type: AWS::DMS::ReplicationTask
    Properties:
      MigrationType: full-load
      ReplicationInstanceArn: !Ref Lab20DMSInstance1
      ReplicationTaskIdentifier: ReplicationTask1
      SourceEndpointArn: !Ref SourceEndPointForBucket1
      TargetEndpointArn: !Ref TargetEndPoint
      TableMappings: >
        {
            "rules": [
                {
                    "rule-type": "selection",
                    "rule-id": "1",
                    "rule-name": "1",
                    "object-locator": {
                        "schema-name": "%",
                        "table-name": "%"
                    },
                    "rule-action": "include"
                }
            ]
        }

  ReplicationTask2:
    Type: AWS::DMS::ReplicationTask
    Properties:
      MigrationType: full-load
      ReplicationInstanceArn: !Ref Lab20DMSInstance1
      ReplicationTaskIdentifier: ReplicationTask2
      SourceEndpointArn: !Ref SourceEndPointForBucket2
      TargetEndpointArn: !Ref TargetEndPoint
      TableMappings: >
        {
            "rules": [
                {
                    "rule-type": "selection",
                    "rule-id": "1",
                    "rule-name": "1",
                    "object-locator": {
                        "schema-name": "%",
                        "table-name": "%"
                    },
                    "rule-action": "include"
                }
            ]
        }

  ReplicationTask3:
    Type: AWS::DMS::ReplicationTask
    Properties:
      MigrationType: full-load
      ReplicationInstanceArn: !Ref Lab20DMSInstance1
      ReplicationTaskIdentifier: ReplicationTask3
      SourceEndpointArn: !Ref SourceEndPointForBucket3
      TargetEndpointArn: !Ref TargetEndPoint
      TableMappings: >
        {
            "rules": [
                {
                    "rule-type": "selection",
                    "rule-id": "1",
                    "rule-name": "1",
                    "object-locator": {
                        "schema-name": "%",
                        "table-name": "%"
                    },
                    "rule-action": "include"
                }
            ]
        }

  ReplicationTask4:
    Type: AWS::DMS::ReplicationTask
    Properties:
      MigrationType: full-load
      ReplicationInstanceArn: !Ref Lab20DMSInstance2
      ReplicationTaskIdentifier: ReplicationTask4
      SourceEndpointArn: !Ref SourceEndPointForBucket4
      TargetEndpointArn: !Ref TargetEndPoint
      TableMappings: >
        {
            "rules": [
                {
                    "rule-type": "selection",
                    "rule-id": "1",
                    "rule-name": "1",
                    "object-locator": {
                        "schema-name": "%",
                        "table-name": "%"
                    },
                    "rule-action": "include"
                }
            ]
        }

  ReplicationTask5:
    Type: AWS::DMS::ReplicationTask
    Properties:
      MigrationType: full-load
      ReplicationInstanceArn: !Ref Lab20DMSInstance2
      ReplicationTaskIdentifier: ReplicationTask5
      SourceEndpointArn: !Ref SourceEndPointForBucket5
      TargetEndpointArn: !Ref TargetEndPoint
      TableMappings: >
        {
            "rules": [
                {
                    "rule-type": "selection",
                    "rule-id": "1",
                    "rule-name": "1",
                    "object-locator": {
                        "schema-name": "%",
                        "table-name": "%"
                    },
                    "rule-action": "include"
                }
            ]
        }

  ReplicationTask6:
    Type: AWS::DMS::ReplicationTask
    Properties:
      MigrationType: full-load
      ReplicationInstanceArn: !Ref Lab20DMSInstance2
      ReplicationTaskIdentifier: ReplicationTask6
      SourceEndpointArn: !Ref SourceEndPointForBucket6
      TargetEndpointArn: !Ref TargetEndPoint
      TableMappings: >
        {
           "rules": [{
                    "rule-type": "selection",
                    "rule-id": "1",
                    "rule-name": "1",
                    "object-locator": {
                        "schema-name": "hr",
                        "table-name": "employee"
                    },
                    "rule-action": "include"
                }
             ]
        }
```

#### Lab 20.1.3: DMS Task Recovery
  - Drop a bad CSV file in source bucket. eg. have a field which is not defined in DMS task configuration.
  - This shall cause respective DMS task to fail.
  - How to recover this task?
    - Delete the file from bucket and resume the DMS task
    - Let us assume task is not recoverable. Replace the task with new DMS task. Keep it in mind data is
      is coming continuously and you shall not lose data.
Note: Submit all the associated csv, table config files and a document for future use.

### Lab 20.1.4 RDS Password Rotation using AWS SSM (Additional)
For security purpose it is recommended to change RDS password frequently. Create a process which can rotate the password every 7 days.
  - Automatic RDS password rotation using in secret manager.

## Further reading

* [Parameter Store Naming](https://routesmart-internal.atlassian.net/l/c/KUVX1oeQ)
* How Determine DMS instances size, Number of tasks required?
