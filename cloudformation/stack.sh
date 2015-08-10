#!/bin/bash

function HELP {
>&2 cat << EOF

Usage: ${0} -a [create|update|delete] -m ami -s [PROD|CODE]

This script creates or updates the stack using cloudformation.

  -a action     Action to perform. Either create or update.
  -m ami        The AMI ID to use.
  -s stage      Stage to launch, either PROD or CODE.
  -h            Displays this help message. No further functions are performed.

EOF
exit 1
}

# Process options
while getopts a:m:s:h FLAG; do
  case $FLAG in
    a) ACTION=$OPTARG ;;
    m) AMI=$OPTARG ;;
    s) STAGE=$OPTARG ;;
    h) HELP ;;
  esac
done
shift $((OPTIND-1))

ERROR=0
if [ -z "${ACTION}" ]; then
  echo "Must specify an action (-a). Should be create or update." >&2
  ERROR=1
fi

if [ -z "${STAGE}" ]; then
  echo "Must specify a stage (-s). Should be PROD or CODE." >&2
  ERROR=1
fi

[ $ERROR -gt 0 ] && HELP

if [ "$ACTION" == "delete" ]; then
    echo "Deleting stack..."
    aws cloudformation delete-stack --stack-name parking-lot-$STAGE
else
    if [ -z "${AMI}" ]; then
      echo "Must specify an AMI ID (-m)" >&2
      HELP
    fi

    # Params
    if [ "$STAGE" == "PROD" ]; then
        capacity=3
        instance_type=t2.small
    else
        capacity=1
        instance_type=t2.micro
    fi

    echo "Configuring stack..."
    aws cloudformation $ACTION-stack \
        --template-body file://cfn.json \
        --stack-name parking-lot-$STAGE \
        --capabilities CAPABILITY_IAM \
        --parameters \
            ParameterKey=App,ParameterValue=parking-lot \
            ParameterKey=Capacity,ParameterValue=$capacity \
            ParameterKey=InstanceType,ParameterValue=$instance_type \
            ParameterKey=KeyName,ParameterValue=bootstrap \
            ParameterKey=PackerAMI,ParameterValue=$AMI \
            ParameterKey=PublicVpcSubnets,ParameterValue='subnet-90ef1bc9\,subnet-ce51faab\,subnet-74469703' \
            ParameterKey=ConfigBucket,ParameterValue=parking-lot \
            ParameterKey=Stack,ParameterValue=infra \
            ParameterKey=Stage,ParameterValue=$STAGE \
            ParameterKey=VpcId,ParameterValue=vpc-1c43a579
            ParameterKey=AlarmSNS,ParameterValue=arn:aws:sns:eu-west-1:528313740988:parking-lot-notifications
fi
