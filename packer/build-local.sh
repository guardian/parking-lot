#!/bin/bash -x

BUILD_NAME=parking-lot

# set build info to DEV if not in TeamCity
[ -z "${BUILD_NUMBER}" ] && BUILD_NUMBER="DEV"
[ -z "${BUILD_BRANCH}" ] && BUILD_BRANCH="DEV"
[ -z "${BUILD_VCS_REF}" ] && BUILD_VCS_REF="DEV"

if [ -z "${BUILD_NAME}" ]; then
    # set BUILD_NUMBER to DEV if not in TeamCity
    BUILD_NAME=${TEAMCITY_PROJECT_NAME}-${TEAMCITY_BUILDCONF_NAME}
    [ -z "${TEAMCITY_BUILDCONF_NAME}" -o -z "${TEAMCITY_PROJECT_NAME}" ] && BUILD_NAME="unknown"
fi

# Copy AWS_DEFAULT_PROFILE to AWS_PROFILE (see https://github.com/mitchellh/goamz/blob/master/aws/aws.go)
if [ -n ${AWS_DEFAULT_PROFILE+x} ]
then
  export AWS_PROFILE=${AWS_DEFAULT_PROFILE}
fi

# Get all the account numbers of our AWS accounts
PRISM_JSON=$(curl -s "http://prism.gutools.co.uk/sources?resource=instance&origin.vendor=aws")
ACCOUNT_NUMBERS=$(echo ${PRISM_JSON} | jq '.data[].origin.accountNumber' | tr '\n' ',' | sed s/\"//g | sed s/,$//)
echo "Account numbers for AMI: $ACCOUNT_NUMBERS"

echo "Running packer with ${PACKER_FILE}" 1>&2
packer-io build \
  -var "build_number=${BUILD_NUMBER}" -var "build_name=${BUILD_NAME}" \
  -var "build_branch=${BUILD_BRANCH}" -var "account_numbers=${ACCOUNT_NUMBERS}" \
  -var "build_vcs_ref=${BUILD_VCS_REF}" \
  packer.json
