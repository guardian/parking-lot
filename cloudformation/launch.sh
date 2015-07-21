#!/bin/bash

function HELP {
>&2 cat << EOF

Usage: ${0} -a [create|update] -m ami -s [PROD|CODE]

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
    a)
      ACTION=$OPTARG
      ;;
    m)
      AMI=$OPTARG
      ;;
    s)
      STAGE=$OPTARG
      ;;
    h)  #show help
      HELP
      ;;
  esac
done
shift $((OPTIND-1))

ERROR=0
if [ -z "${ACTION}" ]; then
  echo "Must specify an action (-a). Should be create or update." >&2
  ERROR=1
fi

if [ -z "${AMI}" ]; then
  echo "Must specify an AMI ID (-m)" >&2
  ERROR=1
fi

if [ -z "${STAGE}" ]; then
  echo "Must specify a stage (-s). Should be PROD or CODE." >&2
  ERROR=1
fi

[ $ERROR -gt 0 ] && HELP

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
        ParameterKey=App,ParameterValue=server \
        ParameterKey=Capacity,ParameterValue=$capacity \
        ParameterKey=InstanceType,ParameterValue=$instance_type \
        ParameterKey=KeyName,ParameterValue=bootstrap \
        ParameterKey=PackerAMI,ParameterValue=$AMI \
        ParameterKey=PrivateVpcSubnets,ParameterValue='subnet-91ef1bc8\,subnet-cf51faaa\,subnet-75469702' \
        ParameterKey=ConfigBucket,ParameterValue=parking-lot \
        ParameterKey=Stack,ParameterValue=parking-lot \
        ParameterKey=Stage,ParameterValue=$STAGE \
        ParameterKey=VpcId,ParameterValue=vpc-1c43a579
