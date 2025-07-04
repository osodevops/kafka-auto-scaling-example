#!/bin/bash
export STRIMZI_VERSION=0.46.0
#export STRIMZI_VERSION=0.45.0
#export STRIMZI_VERSION=0.44.0
#export STRIMZI_VERSION=0.43.0
#export STRIMZI_VERSION=0.42.0
#export STRIMZI_VERSION=0.41.0
#export STRIMZI_VERSION=0.40.0
#export STRIMZI_VERSION=0.39.0
#export STRIMZI_VERSION=0.38.0
#export STRIMZI_VERSION=0.37.0
#export STRIMZI_VERSION=0.36.0
#export STRIMZI_VERSION=0.35.0

helm repo add strimzi https://strimzi.io/charts/
helm repo update
helm search repo strimzi --versions
helm template strimzi/strimzi-kafka-operator --version $STRIMZI_VERSION --include-crds --output-dir .

mkdir -p ../base/strimzi-kafka-operator/$STRIMZI_VERSION/crds
mkdir -p ../base/strimzi-kafka-operator/$STRIMZI_VERSION/templates

# Remove old symlink before creating new one
rm -f ../base/strimzi-kafka-operator/latest && ln -s ./$STRIMZI_VERSION ../base/strimzi-kafka-operator/latest

mv strimzi-kafka-operator/crds/* ../base/strimzi-kafka-operator/$STRIMZI_VERSION/crds
mv strimzi-kafka-operator/templates/* ../base/strimzi-kafka-operator/$STRIMZI_VERSION/templates
rm -R strimzi-kafka-operator

# Create kustomization files
cat > ../base/strimzi-kafka-operator/$STRIMZI_VERSION/crds/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - 04A-Crd-kafkanodepool.yaml
  - 040-Crd-kafka.yaml
  - 041-Crd-kafkaconnect.yaml
  - 042-Crd-strimzipodset.yaml
  - 043-Crd-kafkatopic.yaml
  - 044-Crd-kafkauser.yaml
  - 045-Crd-kafkamirrormaker.yaml
  - 046-Crd-kafkabridge.yaml
  - 047-Crd-kafkaconnector.yaml
  - 048-Crd-kafkamirrormaker2.yaml
  - 049-Crd-kafkarebalance.yaml
EOF

cat > ../base/strimzi-kafka-operator/$STRIMZI_VERSION/templates/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - 04A-Crd-kafkanodepool.yaml
  - 040-Crd-kafka.yaml
  - 041-Crd-kafkaconnect.yaml
  - 042-Crd-strimzipodset.yaml
  - 043-Crd-kafkatopic.yaml
  - 044-Crd-kafkauser.yaml
  - 045-Crd-kafkamirrormaker.yaml
  - 046-Crd-kafkabridge.yaml
  - 047-Crd-kafkaconnector.yaml
  - 048-Crd-kafkamirrormaker2.yaml
  - 049-Crd-kafkarebalance.yaml
EOF

echo "Strimzi Kafka Operator version $STRIMZI_VERSION has been updated successfully."
