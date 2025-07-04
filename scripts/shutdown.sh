#!/bin/bash
set -e

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default values
EXAMPLE="3-brokers"
STRIMZI_VERSION="0.46.0"
STOP_MINIKUBE=false

# Display banner
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                Kafka Auto-Scaling Shutdown                    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --example)
      EXAMPLE="$2"
      shift 2
      ;;
    --strimzi-version)
      STRIMZI_VERSION="$2"
      shift 2
      ;;
    --stop-minikube)
      STOP_MINIKUBE=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Check if minikube is running
if ! minikube status &> /dev/null; then
    echo -e "${YELLOW}Minikube is not running.${NC}"
    exit 0
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}kubectl is not installed. Cannot proceed with cleanup.${NC}"
    exit 1
fi

# Delete Kafka resources
if [ -d "./${EXAMPLE}" ]; then
    echo -e "${GREEN}Deleting Kafka resources from example '${EXAMPLE}'...${NC}"
    kubectl delete --kustomize ./${EXAMPLE}/ --ignore-not-found=true
else
    echo -e "${YELLOW}Example directory './${EXAMPLE}' not found. Skipping Kafka resource deletion.${NC}"
fi

# Delete Strimzi Operator templates
if [ -d "./base/strimzi-kafka-operator/${STRIMZI_VERSION}/templates" ]; then
    echo -e "${GREEN}Deleting Strimzi Operator templates...${NC}"
    kubectl delete --kustomize ./base/strimzi-kafka-operator/${STRIMZI_VERSION}/templates --ignore-not-found=true
else
    echo -e "${YELLOW}Strimzi templates directory not found. Skipping template deletion.${NC}"
fi

# Delete Strimzi Operator CRDs
if [ -d "./base/strimzi-kafka-operator/${STRIMZI_VERSION}/crds" ]; then
    echo -e "${GREEN}Deleting Strimzi Operator CRDs...${NC}"
    kubectl delete --kustomize ./base/strimzi-kafka-operator/${STRIMZI_VERSION}/crds --ignore-not-found=true
else
    echo -e "${YELLOW}Strimzi CRDs directory not found. Skipping CRD deletion.${NC}"
fi

# Stop minikube if requested
if [ "$STOP_MINIKUBE" = true ]; then
    echo -e "${GREEN}Stopping Minikube...${NC}"
    minikube stop
    echo -e "${GREEN}Minikube stopped.${NC}"
else
    echo -e "${YELLOW}Minikube is still running. Use --stop-minikube flag to stop it.${NC}"
fi

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                   Shutdown Complete!                          ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
