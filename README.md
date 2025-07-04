# Kafka Auto-Scaling Example

An example of how to use Strimzi Operator and tiered storage to dynamically scale Kafka brokers.

## Overview

This repository demonstrates how to set up a Kafka cluster using Strimzi Operator with the ability to dynamically scale brokers. It includes examples for different broker configurations and showcases the use of KRaft mode and node pools.

## Prerequisites

- [Minikube](https://minikube.sigs.k8s.io/docs/start/) (or any Kubernetes cluster)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/)

## Getting Started

### Quick Start with Bootstrap Script

Use the provided bootstrap script to quickly set up the environment:

```bash
./scripts/bootstrap.sh
```

The script accepts the following optional parameters:

- `--memory`: Memory allocation for Minikube in MB (default: 30480)
- `--cpus`: Number of CPUs for Minikube (default: 6)
- `--example`: Example directory to deploy (default: 3-brokers)
- `--strimzi-version`: Strimzi version to use (default: 0.46.0)

Example with custom parameters:

```bash
./scripts/bootstrap.sh --memory 40960 --cpus 8 --example 3-brokers --strimzi-version 0.46.0
```

### Manual Setup

#### 1. Start Minikube

Start Minikube with sufficient resources for running Kafka:

```bash
minikube start --memory=30480 --cpus=6
```

#### 2. Deploy Strimzi Operator

Deploy the Strimzi Custom Resource Definitions (CRDs) first, then the operator templates:

```bash
kubectl apply --kustomize ./base/strimzi-kafka-operator/0.46.0/crds && \
kubectl wait --for=condition=Established crds --all && \
kubectl apply --kustomize ./base/strimzi-kafka-operator/0.46.0/templates
```

#### 3. Deploy Kafka Cluster

Choose one of the available examples and deploy it:

```bash
export EXAMPLE=3-brokers && kubectl apply --kustomize ./$EXAMPLE/
```

### 4. Verify Deployment

Check that all pods are running:

```bash
kubectl get pods -w
```

Check the Kafka custom resources:

```bash
kubectl get kafka,kafkanodepool
```

## Available Examples

- **3-brokers**: A Kafka cluster with 3 brokers and 3 controllers using KRaft mode

## Monitoring and Management

To access the Kafka cluster from outside the Kubernetes cluster:

```bash
# Get the NodePort service details
kubectl get svc -l strimzi.io/cluster=three-node-kafka

# Get Minikube IP
minikube ip
```

Connect to Kafka using the Minikube IP and the NodePort exposed by the service.

## Scaling

To scale the number of brokers:

```bash
kubectl edit kafkanodepool broker
```

Change the `spec.replicas` value to the desired number of brokers.

## Cleanup

### Quick Cleanup with Shutdown Script

Use the provided shutdown script to quickly clean up the environment:

```bash
./scripts/shutdown.sh
```

The script accepts the following optional parameters:

- `--example`: Example directory to clean up (default: 3-brokers)
- `--strimzi-version`: Strimzi version to clean up (default: 0.46.0)
- `--stop-minikube`: Also stop Minikube (default: false)

Example with custom parameters:

```bash
./scripts/shutdown.sh --example 3-brokers --strimzi-version 0.46.0 --stop-minikube
```

### Manual Cleanup

To remove the deployed resources:

```bash
kubectl delete --kustomize ./$EXAMPLE/
kubectl delete --kustomize ./base/strimzi-kafka-operator/0.46.0/templates
kubectl delete --kustomize ./base/strimzi-kafka-operator/0.46.0/crds
```

To stop Minikube:

```bash
minikube stop
```
