#!/bin/bash
set -e

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
MEMORY=30480
CPUS=6
EXAMPLE="3-brokers"
STRIMZI_VERSION="0.46.0"

# Display banner
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                Kafka Auto-Scaling Bootstrap                   ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --memory)
      MEMORY="$2"
      shift 2
      ;;
    --cpus)
      CPUS="$2"
      shift 2
      ;;
    --example)
      EXAMPLE="$2"
      shift 2
      ;;
    --strimzi-version)
      STRIMZI_VERSION="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Check if minikube is installed
if ! command -v minikube &> /dev/null; then
    echo -e "${YELLOW}Minikube is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${YELLOW}kubectl is not installed. Please install it first.${NC}"
    exit 1
fi

# Start minikube if not running
if ! minikube status &> /dev/null; then
    echo -e "${GREEN}Starting Minikube with ${MEMORY}MB memory and ${CPUS} CPUs...${NC}"
    minikube start --memory=${MEMORY} --cpus=${CPUS}
else
    echo -e "${GREEN}Minikube is already running.${NC}"
fi

# Check if the example directory exists
if [ ! -d "./${EXAMPLE}" ]; then
    echo -e "${YELLOW}Example directory './${EXAMPLE}' not found.${NC}"
    exit 1
fi

# Check if Strimzi version directory exists
if [ ! -d "./base/strimzi-kafka-operator/${STRIMZI_VERSION}" ]; then
    echo -e "${YELLOW}Strimzi version directory './base/strimzi-kafka-operator/${STRIMZI_VERSION}' not found.${NC}"
    exit 1
fi

# Deploy Strimzi Operator
echo -e "${GREEN}Deploying Strimzi Operator CRDs...${NC}"
kubectl apply --kustomize ./base/strimzi-kafka-operator/${STRIMZI_VERSION}/crds

echo -e "${GREEN}Waiting for CRDs to be established...${NC}"
kubectl wait --for=condition=Established crds --all --timeout=60s

echo -e "${GREEN}Deploying Strimzi Operator templates...${NC}"
kubectl apply --kustomize ./base/strimzi-kafka-operator/${STRIMZI_VERSION}/templates

echo -e "${GREEN}Waiting for Strimzi Operator deployment to be ready...${NC}"
kubectl wait --for=condition=Available deployment/strimzi-cluster-operator --timeout=120s

# Deploy Kafka cluster
echo -e "${GREEN}Deploying Kafka cluster from example '${EXAMPLE}'...${NC}"
kubectl apply --kustomize ./${EXAMPLE}/

echo -e "${GREEN}Waiting for Kafka resources to be created...${NC}"
sleep 5

# Display status
echo -e "${GREEN}Deployment initiated. Checking status of pods:${NC}"
kubectl get pods

echo -e "${GREEN}Checking status of Kafka resources:${NC}"
kubectl get kafka,kafkanodepool

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                   Bootstrap Complete!                         ║"
echo "║                                                               ║"
echo "║  To monitor the deployment progress, run:                     ║"
echo "║  kubectl get pods -w                                          ║"
echo "║                                                               ║"
echo "║  To access Kafka from outside Kubernetes:                     ║"
echo "║  1. Get service details:                                      ║"
echo "║     kubectl get svc -l strimzi.io/cluster=three-node-kafka    ║"
echo "║  2. Get Minikube IP:                                          ║"
echo "║     minikube ip                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
