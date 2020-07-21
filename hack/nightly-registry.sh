#!/bin/bash -x

HCO_SRC_DIR="/hyperconverged-cluster-operator"

export CSV_MERGER_BIN="${HCO_SRC_DIR}/tools/csv-merger/csv-merger"
export MANIFEST_TEMPLATOR_BIN="${HCO_SRC_DIR}/tools/manifest-templator/manifest-templator"
export OPERATOR_IMAGE=registry.svc.ci.openshift.org/${OPENSHIFT_BUILD_NAMESPACE}/stable:hyperconverged-cluster-operator-nightly

(cd ${HCO_SRC_DIR}; ./hack/nightly-update.sh manifests)

cp -a ${HCO_SRC_DIR}/deploy/olm-catalog/* /registry

find /registry/kubevirt-hyperconverged/ -type f -exec sed -E -i 's|^(\s*)- name: KVM_EMULATION$|\1- name: KVM_EMULATION\n\1  value: "true"|' {} \; || :
cat /registry/kubevirt-hyperconverged/kubevirt-hyperconverged.package.yaml

# Initialize the database
initializer --manifests /registry/kubevirt-hyperconverged --output bundles.db
exec registry-server --database bundles.db
