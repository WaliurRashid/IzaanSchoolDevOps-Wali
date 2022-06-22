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
  
#### Lab 19.1.2: After Provisioning cluster do following

  - Understand Shards
  - Index
  - Index Template
  - Index Policy / Managed Policy
  - How to use DevTolls in OpenSearch Dashboard
  - Create a readonly user using OpenSearch API
  - Create an alert using OpenSearch Dashboard
  - Learn what is integration endpont in Alerting feature in OpenSearch Dashboard
