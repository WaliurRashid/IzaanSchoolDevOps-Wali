# Topic 19 OpenSearch 

<!-- TOC -->

- [Topic 19: AWS OpenSearch](#topic-19-aws-opensearch)
  - [Lesson 19.1: Introduction to OpenSearch](#lesson-191-introduction-to-opensearch)
    - [Principle 19.1](#principle-191)
    - [Practice 19.1](#practice-191)
      - [Lab 19.1.1: Create an OpenSearch Cluster](#lab-1911-create-an-opnesearch-cluster)
      - [Lab 19.1.1: After Provisioning cluster do following](#after-provi-cluster-do-following)
      
<!-- /TOC -->

## Lesson 19.1: Introduction to OpenSearch

### Principle 19.1

*OpenSearch is a distributed, open-source search and analytics suite used for a broad set of use cases like real-time application monitoring, log analytics, and website search. OpenSearch provides a highly scalable system for providing fast access and response to large volumes of data with an integrated visualization tool, OpenSearch Dashboards, that makes it easy for users to explore their data. Like Elasticsearch and Apache Solr, OpenSearch is powered by the Apache Lucene search library. OpenSearch and OpenSearch Dashboards were originally derived from Elasticsearch 7.10.2 and Kibana 7.10.2..*

### Practice 19.1

You will understand the OpenSearch Service and be able to provision the cluster using cloudformation.

#### Lab 19.1.1: Create an OpenSearch Cluster

Create a CFN Template that
[creates a OpenSearch CLuster](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/gsgcreate-domain.html):

- Create a domain with following configuration using CloudFormation
  - 3 Data Nodes
  - 3 Master Nodes
  - 2 Ultra Warm Nodes
  - Public Access Enabled
  - Create Master User and Password 
  - Note your domain endpoint

```yaml
Description: This template is to create a OpenSearch Cluster

Parameters:
  MasterNodeType:
    Type: String
    AllowedValues:
      - c5.large.search
      - r5.large.search

  DataNodeType:
    Type: String
    AllowedValues:
      - c5.large.search
      - r5.large.search

  WarmNodeType:
    Type: String
    AllowedValues:
      - ultrawarm1.medium.search

  EBSVolumeSize:
    Type: Number

  EBSVolumeType:
    Type: String
    AllowedValues:
      - gp2
      - gp3

Resources:
  OpenSearchCluster:
    Type: AWS::OpenSearchService::Domain
    Properties:
      DomainName: search-wali
      AdvancedSecurityOptions:
        Enabled: True
        InternalUserDatabaseEnabled: True
        MasterUserOptions:
          MasterUserName: '{{resolve:secretsmanager:OpenSearchCredential:SecretString:username}}'
          MasterUserPassword: '{{resolve:secretsmanager:OpenSearchCredential:SecretString:password}}'
      ClusterConfig:
        DedicatedMasterCount: 3
        DedicatedMasterEnabled: True
        DedicatedMasterType: !Ref MasterNodeType
        InstanceCount: 3
        InstanceType: !Ref DataNodeType
        WarmCount: 2
        WarmEnabled: True
        WarmType: !Ref WarmNodeType

      EBSOptions:
        EBSEnabled: True
        VolumeSize: !Ref EBSVolumeSize
        VolumeType: !Ref EBSVolumeType
      DomainEndpointOptions:
        EnforceHTTPS: True
      NodeToNodeEncryptionOptions:
        Enabled: True
      EncryptionAtRestOptions:
        Enabled: True
      AccessPolicies:
        Statement:
          - Effect: Allow
            Principal:
              AWS: '*'
            Action: 'es:ESHttp*'
      Tags:
        - Key: Name
          Value: Search-Wali

Outputs:
  DomainEndPoint:
    Description: This is the output of domain end point of the cluster created
    Export:
      Name: Output-DomainEndPoint-OpenSearch-Cluster
    Value: !GetAtt OpenSearchCluster.DomainEndpoint
```
> Lab19Parameter.json

```json
[
  {
    "ParameterKey": "MasterNodeType",
    "ParameterValue": "c5.large.search"
  },
  {
    "ParameterKey": "DataNodeType",
    "ParameterValue": "c5.large.search"
  },
  {
    "ParameterKey": "WarmNodeType",
    "ParameterValue": "ultrawarm1.medium.search"
  },
  {
    "ParameterKey": "EBSVolumeSize",
    "ParameterValue": "30"
  },
  {
    "ParameterKey": "EBSVolumeType",
    "ParameterValue": "gp2"
  }
]
```
  
#### Lab 19.1.2: After Provisioning cluster do following

  - Understand Shards
  - Index
  - Index Template
  - Index Policy / Managed Policy
  - How to use DevTolls in OpenSearch Dashboard
  - Create a readonly user using OpenSearch API
  - Create an alert using OpenSearch Dashboard
  - Learn what is integration endpont in Alerting feature in OpenSearch Dashboard
