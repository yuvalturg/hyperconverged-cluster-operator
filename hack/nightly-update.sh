#!/bin/bash -ex

cmd=$1

LATEST_KUBEVIRT=$(curl -sL https://storage.googleapis.com/kubevirt-prow/devel/nightly/release/kubevirt/kubevirt/latest)
LATEST_KUBEVIRT_IMAGE=$(curl -sL https://storage.googleapis.com/kubevirt-prow/devel/nightly/release/kubevirt/kubevirt/${LATEST_KUBEVIRT}/kubevirt-operator.yaml | grep 'OPERATOR_IMAGE' -A1 | tail -n 1 | sed 's/.*value: //g')
LATEST_KUBEVIRT_COMMIT=$(curl -sL https://storage.googleapis.com/kubevirt-prow/devel/nightly/release/kubevirt/kubevirt/${LATEST_KUBEVIRT}/commit)


vendor_modules() {
    go mod edit -require kubevirt.io/kubevirt@${LATEST_KUBEVIRT_COMMIT}
    go mod vendor
}

update_manifests() {
    CSV_GEN_IN_CLUSTER=1 \
    KUBEVIRT_IMAGE=${LATEST_KUBEVIRT_IMAGE} ./hack/build-manifests.sh
}

case $cmd in
    "vendor")
        vendor_modules
        ;;
    "manifests")
        update_manifests
        ;;
esac
