#!/bin/bash

set -e

verify_cf_stack_progress() {
    local _stack_name=$1

    while [[ `aws cloudformation describe-stacks --stack-name ${_stack_name} | jq  -r '.Stacks[0].StackStatus'` = 'CREATE_IN_PROGRESS' ]]
    do
        sleep 3
    done

    ecs_stack_status=`aws cloudformation describe-stacks --stack-name ${_stack_name} | jq -r '.Stacks[0].StackStatus'`

    if [[ "${ecs_stack_status}" != "CREATE_COMPLETE" &&  "${ecs_stack_status}" != "UPDATE_COMPLETE" ]]
     then
      echo "Stack creation failed: ${_stack_name}"
      exit 1
    else
        echo "Stack creation success: ${_stack_name}"
    fi
}

echo "Creating ECR Repository..."
aws ecr create-repository --repository-name vcis-todos-service

echo "Push todos-service image to ECR repo..."
cd /Users/bbjang/Documents/DemoProjects/todos-service
./docker-push-local.sh

cd -

echo "Creating CF stack: vcis-ecs-cluster-poc"
aws cloudformation create-stack --stack-name vcis-ecs-cluster-poc --template-body file:///Users/bbjang/Documents/IndustrySystemProjects/vcis-cloudformation-templates/templates/ecs/ecs-cluster.yaml --parameters file:///Users/bbjang/Documents/IndustrySystemProjects/vcis-cloudformation-templates/templates/ecs/config/poc/ecs-cluster-poc-config.json --capabilities CAPABILITY_IAM
verify_cf_stack_progress "vcis-ecs-cluster-poc"

echo "Creating CF stack: vcis-ecs-alb-poc"
aws cloudformation create-stack --stack-name vcis-ecs-alb-poc --template-body file:///Users/bbjang/Documents/IndustrySystemProjects/vcis-cloudformation-templates/templates/ecs/ecs-alb.yaml --parameters file:///Users/bbjang/Documents/IndustrySystemProjects/vcis-cloudformation-templates/templates/ecs/config/poc/ecs-alb-poc-config.json --capabilities CAPABILITY_IAM
verify_cf_stack_progress "vcis-ecs-alb-poc"

echo "Creating CF stack: vcis-ecs-srv-poc"
aws cloudformation create-stack --stack-name vcis-ecs-srv-poc --template-body file:///Users/bbjang/Documents/IndustrySystemProjects/vcis-cloudformation-templates/templates/ecs/ecs-service.yaml --parameters file:///Users/bbjang/Documents/IndustrySystemProjects/vcis-cloudformation-templates/templates/ecs/config/poc/ecs-service-poc-config.json --capabilities CAPABILITY_IAM
verify_cf_stack_progress "vcis-ecs-srv-poc"

echo "Creating CF stack: vcis-ecs-codepipeline-setup-poc"
aws cloudformation create-stack --stack-name vcis-ecs-codepipeline-setup-poc --template-body file:///Users/bbjang/Documents/IndustrySystemProjects/vcis-cloudformation-templates/templates/ecs/ecs-codepipeline-setup.yaml --parameters file:///Users/bbjang/Documents/IndustrySystemProjects/vcis-cloudformation-templates/templates/ecs/config/poc/ecs-codepipeline-setup-poc-config.json --capabilities CAPABILITY_IAM
verify_cf_stack_progress "vcis-ecs-codepipeline-setup-poc"

echo "Creating CF stack: vcis-ecs-codepipeline-poc"
aws cloudformation create-stack --stack-name vcis-ecs-codepipeline-poc --template-body file:///Users/bbjang/Documents/IndustrySystemProjects/vcis-cloudformation-templates/templates/ecs/ecs-codepipeline.yaml --parameters file:///Users/bbjang/Documents/IndustrySystemProjects/vcis-cloudformation-templates/templates/ecs/config/poc/ecs-codepipeline-poc-config.json --capabilities CAPABILITY_IAM
verify_cf_stack_progress "vcis-ecs-codepipeline-poc"

echo "ECS Cluster/CodePipeline stacks deployed successfully!!!"