#/bin/bash

REPOSITORY_NAME='vct/todo-service'

aws ecr describe-repositories | grep ${REPOSITORY_NAME}

if [[ $? != 0 ]]; then
    aws ecr create-repository --repository-name ${REPOSITORY_NAME}
fi    

docker tag ${REPOSITORY_NAME} 019181870962.dkr.ecr.us-east-1.amazonaws.com/${REPOSITORY_NAME}

eval $(aws ecr get-login --no-include-email)

docker push 019181870962.dkr.ecr.us-east-1.amazonaws.com/${REPOSITORY_NAME}

docker logout






