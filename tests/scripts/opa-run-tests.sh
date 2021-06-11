#!/usr/bin/env bash
set -e

#
# Shell Script
# - OPA Run Tests
#
# # Parameters
TF_PLAN_JSON="terraform-plan-$TF_VERSION-$TF_AZ_VERSION"

echo "==> Load planned values..."
cd "$PIPELINE_WORKSPACE/s/tests/opa/policy" &&
    sed -e 's:root-id-1:'"${TF_ROOT_ID_1}"':g' \
        -e's:root-id-2:'"${TF_ROOT_ID_2}"':g' \
        -e 's:root-id-3:'"${TF_ROOT_ID_3}"':g' \
        -e 's:root-name:'"ES-${TF_VERSION}-${TF_AZ_VERSION}"':g' \
        -e's:eastus:'"${DEFAULT_LOCATION}"':g' planned_values_template.yml |
    tee "$TF_PLAN_JSON"_planned_values.yml

echo "==> List all planned values to yaml..."
cd "$PIPELINE_WORKSPACE/s/tests/opa/policy" && find . -name "*.yml"

echo "==> Test Conftest..."
which conftest
echo
conftest

echo "==> Running conftest..."
cd "$PIPELINE_WORKSPACE/s/tests/deployment"
conftest test "$TF_PLAN_JSON".json -p ../opa/policy -d ../opa/policy/"$TF_PLAN_JSON"_planned_values.yml