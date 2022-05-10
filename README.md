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

## TODO: 
    - configure the aws profile
        -- insert lines of code to accomplish this
    - create an s3 bucket `aws s3api create-bucket --bucket terraformstatebucket`
    - create a backend.tf file
        -- input the: 
            -- required version
            -- backend "s3"
                    -- region
                    -- profile
                    -- key ~ name of file
                    -- bucket

    - initialize the file 
    
    - create a variables file
        -- profile
        -- region-master
        -- region-worker
    
    - create providers
        -- region-master
        -- region-worker
    
    - create networs
        -- create vpc in us-east-1
            -- name: "vpc_master"
            -- provider: region-master 
            -- cidr: "10.0.0.0/16"
            -- enable_dns_support: true
            -- enable_dnt_hostnames: true
            -- tags: "master-vpc-jenkins"
        -- create vpc in us-west-2
            -- name: "vpc_master_oregon
            -- provider: region-master
            -- cidr: 192.168.0.0/16
            -- enable_dns_support: true
            -- enable_dns_hostnames: true
            -- tags: "master-vpc-jenkins"
        -- create IGW in us-east-1
            -- name: "igw"
            -- provider: region-master
            -- vpc_id: point to 'vpc_master'.id
        -- create IGW in us-west-2
            -- name: "igw_oregon"
            -- provider: region-worker
            -- vpc_id: point to 'vpc_master_oregon'.id
        -- create available AZ's in VPC get
            -- name: azs
            -- provider: point to region master
            -- state" "available"
        -- create 2 subnets us-east-1
            -- name: "subnet_1" && "subnet_2"
            -- provider: point to region-master
            -- vpc_id: point to 'vpc_master'.id
            -- availability_zone: element(data.<call the above block of creted code for available azs>.names, 0&&1)
            -- cidr: 10.0.2.0/24
        -- create subnet us-west-2
            -- name: "subnet_1_oregon"
            -- provider: point to region-worker
            -- vpc_id: point to 'vpc_master_oregon'.id
            -- cidr: '192.168.1.0/24'
        -- create peering vpc connection from us-east-1
            -- name: useast1uswest2
            -- provider: point to region-master
            -- peer-vpc-id: point to 'vpc_master_oregon'.id
            -- vpc-id: point to 'vpc_master'.id
            -- peer-region: point to 'region_worker' variable
        -- create vpc peering connection acceptor from us-west-2 to us-east1
            -- name: accept_peering
            -- provider: point to 'region-worker'
            -- vpc-peering-id: point to 'useast1-uswest2'.id (created resource for peering)
            -- auto-accept: true
        -- create Route Table us-east-1
            -- name: internet-route
            -- provider: point to region-master
            -- vpc-id: point to master-vpc.id
            -- route:
                -- cidr_block: 0.0.0.0/0
                -- gateway_id: point to 'IGW' id
            -- route:
                -- cidr_block: 192.168.1.0/24
                -- vpc-peering-connection-id: point to useast1uswes2.vpc_id
            -- lifecycle:
                -- ignore-changes: all
            -- tags: 
                -- name: "master-region-rt"
        -- create main route table association
            -- name: set_master_default_rt_assoc
            -- provider: point to region-master
            -- route_table_id: poing to 'internet_route'.id
        -- create route table us-west-2
            -- name: internet-route_oregon
            -- provider: point to region-worker
            -- vpc-id: point to master_oregon.id
            -- route:
                -- cidr_block: 0.0.0.0/0
                -- gateway_id: point to 'IGW-oregon'.id
            -- route:
                -- cidr_block: 10.0.1.0/24
                -- vpc-peering-connection-id: point to useast1uswes2.id
            -- lifecycle:
                -- ignore-changes: all
            -- tags: 
                -- name: "worker-region-rt"
        -- create main route table association
            -- name: set_worker_default_rt_assoc
            -- provider: point to region-worker
            -- route_table_id: poing to 'internet_route_oregon'.id