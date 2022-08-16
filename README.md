# aws-glue-etl-s3-athena



## Create the infrastructure

```sh
touch .auto.tfvars
```

Add the variables according to your preferences. Example:

```hcl
# The role to be assumed by Terraform to create the resources
assume_role_arn = "arn:aws:iam::000000000000:role/OrganizationAccountAccessRole"

# Region to create the resources
region = "sa-east-1"

# Availability Zones
availability_zones = ["sa-east-1a", "sa-east-1b", "sa-east-1c"]
```

Apply Terraform:

```sh
terraform init
terraform apply -auto-approve
```