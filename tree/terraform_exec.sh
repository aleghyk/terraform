#/usr/bin/env bash

HELP="\n\t-a: apply
\n\t-D: delete
\n\t-e: environement to be used, default to \"dev\"\n\t"

# set default action to apply
apply=1
destroy=

while getopts "aDe:h" opt; do
    case $opt in
        a)
            apply=1
            ;;
        D)
            apply=
            destroy=1
            ;;
        e)
            ENV=$OPTARG
            ;;
        h)
            echo -e $HELP
            exit 0
            ;;
        ?)
            echo -e $HELP && exit 1
            ;;
 esac
done

# global vars
[[ -z $ENV ]] && ENV="dev"
AWS_PROFILE="jenkins-ci-provisioning"
AWS_REGION="eu-west-1"
CLUSTER_NAME="jenkins-ci-$ENV"

# monitoring peering data
MON_PROD_VPC_ID="vpc-51e8b639"
MON_PROD_REGION="us-east-2"
MON_PROD_VPC_CIDR="10.0.1.0/24"

# terraform backend vars
TF_BE_S3_BUCKET="terraform-$CLUSTER_NAME"
TF_BE_S3_STATE_KEY="$TF_BE_S3_BUCKET.tfstate"

echo -e "\nENV=$ENV
AWS CLI profile: $AWS_PROFILE
AWS region: $AWS_REGION
Application cluster name: $CLUSTER_NAME
Terraform backend S3 bucket name: $TF_BE_S3_BUCKET
Terraform backend key filename: $TF_BE_S3_STATE_KEY
"

read -p "Are you sure to proceed? [y/n] " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# load modules
terraform get

# setup backend
terraform_config () {

    terraform init \
        -backend-config="bucket=$TF_BE_S3_BUCKET" \
        -backend-config="key=$TF_BE_S3_STATE_KEY" \
        -backend-config="region=$AWS_REGION" \
        -backend-config="profile=$AWS_PROFILE"
}


terraform_plan () {

    terraform plan \
        -var env=$ENV \
        -var aws-region=$AWS_REGION \
        -var aws-profile=$AWS_PROFILE \
        -var cluster-name=$CLUSTER_NAME \
        -var monitoring-prod-vpc-id=$MON_PROD_VPC_ID \
        -var monitoring-prod-region=$MON_PROD_REGION \
        -var monitoring-prod-vpc-cidr=$MON_PROD_VPC_CIDR
}

terraform_apply () {

    terraform apply \
        -var env=$ENV \
        -var aws-region=$AWS_REGION \
        -var aws-profile=$AWS_PROFILE \
        -var cluster-name=$CLUSTER_NAME \
        -var monitoring-prod-vpc-id=$MON_PROD_VPC_ID \
        -var monitoring-prod-region=$MON_PROD_REGION \
        -var monitoring-prod-vpc-cidr=$MON_PROD_VPC_CIDR

}

terraform_destroy () {

    terraform plan -destroy \
        -var env=$ENV \
        -var aws-region=$AWS_REGION \
        -var aws-profile=$AWS_PROFILE \
        -var cluster-name=$CLUSTER_NAME \
        -var monitoring-prod-vpc-id=$MON_PROD_VPC_ID \
        -var monitoring-prod-region=$MON_PROD_REGION \
        -var monitoring-prod-vpc-cidr=$MON_PROD_VPC_CIDR

    echo
    read -p "Plan complete. Are you sure to proceed? [y/n] " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi

    terraform destroy \
        -var env=$ENV \
        -var aws-region=$AWS_REGION \
        -var aws-profile=$AWS_PROFILE \
        -var cluster-name=$CLUSTER_NAME \
        -var monitoring-prod-vpc-id=$MON_PROD_VPC_ID \
        -var monitoring-prod-region=$MON_PROD_REGION \
        -var monitoring-prod-vpc-cidr=$MON_PROD_VPC_CIDR
}

apply () {

    terraform_config || exit 1
    terraform_plan || exit 1

    read -p "Plan complete. Are you sure to proceed? [y/n] " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi

    echo
    terraform_apply || exit 1
}

if [[ $apply == 1 ]]; then
    echo -e "\nRunning Apply action..."
    apply
elif [[ $destroy == 1 ]]; then
    echo -e "\nRunning Destroy action..."
    terraform_destroy
else
    echo -e "\nERROR: action does not set, exitting."
    exit 1
fi