# Deploying to AWS with Terraform and Ansible

## Create an AWS Profile
````bash
aws configure --profile <nameOfProfile>
````

## Access Credentials

```bash
code ~/.aws/credentials
```
update the Access && Secret Key from the newly created Sandbox

## Test newly Created Profile
````bash
AWS_PROFILE=<nameOfProfile> aws sts get-caller-identity
`Response`: 
{
    "UserId": "****",
    "Account": "***",
    "Arn": "arn:aws:iam::****:user/<nameOfProfile>"
}
````
## Terraform State in S3 Backend
````
aws s3api create-bucket --bucket <unique S3 bucket name>
````

## Terraform Backend
````bash
terraform {
    required_version = ">=0.12.0"
    backend "s3" {
        region  = "us-east-1"
        profile = "<theCreatedProfile>
        key     = "terraformstatefile"
        bucket  = "<nameOfCreateBucket>
    }
}
````