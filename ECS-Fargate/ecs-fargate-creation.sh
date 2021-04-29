#!/bin/bash

set -x

#aws cloudformation create-stack --stack-name vcis-ecs-cluster-poc --template-body file:///Users/bbjang/Documents/IndustrySystemProjects/vcis-cloudformation-templates/templates/ecs/ecs-cluster.yaml --parameters file:///Users/bbjang/Documents/IndustrySystemProjects/vcis-cloudformation-templates/templates/ecs/config/poc/ecs-cluster-poc-config.json --capabilities CAPABILITY_IAM

while [[ $(aws cloudformation describe-stacks --stack-name vcis-ecs-cluster-poc | jq  '.Stacks[0].StackStatus') = 'CREATE_IN_PROGRESS' ]]
do
    sleep 3
done

if [[ ($(aws cloudformation describe-stacks --stack-name vcis-ecs-cluster-poc | jq  '.Stacks[0].StackStatus') != 'CREATE_COMPLETE') && ( $(aws cloudformation describe-stacks --stack-name vcis-ecs-cluster-poc | jq  '.Stacks[0].StackStatus') != 'UPDATE_COMPLETE') ]]; then
  echo 'Stack creation failed: vcis-ecs-cluster-poc'
  exit 1
else
    echo 'Success'
fi  

