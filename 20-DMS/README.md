# Topic 20 AWS DMS 

<!-- TOC -->

- [Topic 20: AWS DMS](#topic-20-aws-AWS-DMS)
  - [Lesson 20.1: Introduction to AWS DMS](#lesson-201-introduction-to-AWS-DMS)
    - [Practice 20.1](#practice-201)
      - [Lab 20.1.1: Create an Aurora Postgresql Database Using CF](#lab-2011-create-an-aurora-postgresql-database-using-cf)
      - [Lab 20.1.2: In same CF template add Two DMS instances and below components ](#lab-2012-in-same-cf-template-add-two-dms-instances-and-below-components)
      - [Lab 20.1.3: RDS Password Rotation using AWS SSM ](#lab-202-rds-password-rotation-using-aws-ssm-additional)
      
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

Note: Submit all the associated csv, table config files and a document for future use.

### Lab 20.1.3 RDS Password Rotation using AWS SSM (Additional)
For security purpose it is recommended to change RDS password frequently. Create a process which can rotate the password every 7 days.
  - Automatic RDS password rotation using in secret manager.

## Further reading

* [Parameter Store Naming](https://routesmart-internal.atlassian.net/l/c/KUVX1oeQ)
* How Determine DMS instances size, Number of tasks required?