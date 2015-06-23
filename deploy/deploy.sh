#! /bin/bash

SHA1=$1
EB_BUCKET=ps-metrics
APPLICATION_NAME=PS_METRICS
ENVIRONMENT_NAME=ps-metrics-env
if [ -e Dockerrun.aws.json.template ]; then
  DOCKERRUN_TEMPLATE=Dockerrun.aws.json.template
else
  DOCKERRUN_TEMPLATE=deploy/Dockerrun.aws.json.template
fi
DOCKERRUN_FILE=Dockerrun.aws.json
DOCKER_ZIP=$SHA1.zip

# Deploy image to Docker Hub
docker push paperspace/ps_metrics:$SHA1
if [ $? -ne 0]; then
  exit 1;
fi

# Create new Elastic Beanstalk version
sed -e "s/<TAG>/$SHA1/" < $DOCKERRUN_TEMPLATE > $DOCKERRUN_FILE
cp -a deploy/ebextensions .ebextensions
zip -r $DOCKER_ZIP $DOCKERRUN_FILE .ebextensions
aws s3 cp $DOCKER_ZIP s3://$EB_BUCKET/$DOCKER_ZIP
if [ $? -ne 0]; then
  exit 1;
fi

aws elasticbeanstalk create-application-version \
    --application-name $APPLICATION_NAME \
    --version-label    $SHA1 \
    --source-bundle S3Bucket=$EB_BUCKET,S3Key=$DOCKER_ZIP
if [ $? -ne 0]; then
  exit 1;
fi

# Update Elastic Beanstalk environment to new version
aws elasticbeanstalk update-environment \
    --environment-name $ENVIRONMENT_NAME \
    --version-label $SHA1
if [ $? -ne 0]; then
  exit 1;
fi
