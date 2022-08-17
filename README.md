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
main_az            = "sa-east-1a"

# RDS Aurora credentials
master_username = "etluser"
master_password = "passw0rd"
```

Apply Terraform:

```sh
terraform init
terraform apply -auto-approve
```

Once ready, enter the Glue Studio and test the connector to the RDS database.

## Glue

Connect to the Jumpbox VM using SSM and apply the [`prepare-database.sql`](./prepare-database.sql) file to generate the data.

```sh
mysql -u 'etluser' -p'passw0rd' \
    -h 'aurora-mysql-instance.cq1qsu0anb1o.sa-east-1.rds.amazonaws.com' \
    -P 3306 \
    -D 'testdb'
```

Run the Crawler from the Glue console to feed the catalog.

