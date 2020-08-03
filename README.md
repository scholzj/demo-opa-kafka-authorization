# Strimzi with Open Policy Agent used for Kafka authorization

This repository contains the example files for using Open Policy Agent (OPA) for Apache Kafka authorization.
This demo is related to the blog post published on [Strimzi website](https://strimzi.io).

## Prerequisites

### Namespace

Create a namespace `myproject` and set it as default.
If you use different namespace, change the `.metadata.namespace` field in the YAML files in this repository

### Install Strimzi 0.19.0

Install Strimzi 0.19.0 and make sure it is watching the `myproject` namespace.
You can use any of the available methods.

## Deploy OPA

The OPA policies used for both examples mentioned int he blog post are deployed using a ConfigMap [`opa-policies.yaml`](./opa-policies.yaml).
You can create them using `kubectl`:

```
kubectl apply -f opa-policies.yaml
```

The [`opa-deployment.yaml`](./opa-deployment.yaml) contains the deployment of the OPA server.
This is just example deployment which is not production ready.
You can install it using `kubectl`:

```
kubectl apply -f opa-deployment.yaml
```

## Basic example

The basic example had the groups hardcoded inside the OPA policy.
Any changes to the groups (adding or removing users) would require change fo the policy.

### Deploy Kafka cluster

Deploy the Kafka cluster from the [`basic-example-kafka.yaml`](./basic-example-kafka.yaml) file.
This example is also configured to use the basic example policy.

```
kubectl apply -f basic-example-kafka.yaml
```

### Deploy allowed clients

In the file [`basic-example-clients-allowed.yaml`](./basic-example-clients-allowed.yaml) you can find example consumer and producer which are using users allowed to produce and consumer messages.

```
kubectl apply -f ./basic-example-clients-allowed.yaml
```

When you deploy them, you should see that the are allowed to run.

### Deploy not allowed clients

In the file [`basic-example-clients-denied.yaml`](./basic-example-clients-denied.yaml) you can find example consumer and producer which are using users not allowed to produce and consumer messages.

```
kubectl apply -f ./basic-example-clients-denied.yaml
```

When you deploy them, you should see that the are allowed to use the Kafka cluster.

## Advanced example

The advanced example is using groups configured as annotations on the `KafkaTopic` and `KafkaUser` resources.
The resources are loaded into OPA using the kube-mgmt sidecar and are used by the policy.
That way, changing the rights, adding or removing users etc. can be done without any changes to the policy.

### Deploy Kafka cluster

Deploy the Kafka cluster from the [`advanced-example-kafka.yaml`](./advanced-example-kafka.yaml) file.
This example is also configured to use the basic example policy.

```
kubectl apply -f advanced-example-kafka.yaml
```

### Deploy allowed clients

In the file [`advanced-example-clients-allowed.yaml`](./advanced-example-clients-allowed.yaml) you can find example consumer and producer which are using users allowed to produce and consumer messages.

```
kubectl apply -f ./advanced-example-clients-allowed.yaml
```

When you deploy them, you should see that the are allowed to run.

### Deploy not allowed clients

In the file [`advanced-example-clients-denied.yaml`](./advanced-example-clients-denied.yaml) you can find example consumer and producer which are using users not allowed to produce and consumer messages.

```
kubectl apply -f ./advanced-example-clients-denied.yaml
```

When you deploy them, you should see that the are allowed to use the Kafka cluster.