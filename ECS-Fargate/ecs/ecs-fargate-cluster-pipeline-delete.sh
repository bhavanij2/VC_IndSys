#!/bin/bash

set -e

verify_cf_stack_deleted() {
    set +e
    local _stack_name=$1

    aws cloudformation describe-stacks --stack-name ${_stack_name} &>/dev/null
    while [[ $? -eq 0 ]]; do
     aws cloudformation describe-stacks --stack-name ${_stack_name} &> /dev/null
    done
    set -e
    echo "Stack deletion success: ${_stack_name}"
}

echo "Deleting CF Stack: vcis-ecs-codepipeline-poc"
aws cloudformation delete-stack --stack-name vcis-ecs-codepipeline-poc
verify_cf_stack_deleted "vcis-ecs-codepipeline-poc"

echo "Deleting CF Stack: vcis-ecs-codepipeline-setup-poc"
aws cloudformation delete-stack --stack-name vcis-ecs-codepipeline-setup-poc
verify_cf_stack_deleted "vcis-ecs-codepipeline-setup-poc"

echo "Deleting CF Stack: vcis-ecs-srv-poc"
aws cloudformation delete-stack --stack-name vcis-ecs-srv-poc
verify_cf_stack_deleted "vcis-ecs-srv-poc"

echo "Deleting CF Stack: vcis-ecs-alb-poc"
aws cloudformation delete-stack --stack-name vcis-ecs-alb-poc
verify_cf_stack_deleted "vcis-ecs-alb-poc"

echo "Deleting CF Stack: vcis-ecs-cluster-poc"
aws cloudformation delete-stack --stack-name vcis-ecs-cluster-poc
verify_cf_stack_deleted "vcis-ecs-cluster-poc"

echo "Deleting ECR Repo: vcis-todos-service"
aws ecr delete-repository --repository-name vcis-todos-service > /dev/null

set +e
aws ecr describe-repositories | grep 'vcis-todos-service' &> /dev/null
while [[ $? -eq 0 ]]; do
    sleep 3
    aws ecr describe-repositories | grep 'vcis-todos-service' &> /dev/null
done
set -e
echo "ECR Repository deleted: vcis-todos-service"

echo "ECS Cluster/CodePipeline Stacks deleted successfully!!!"




