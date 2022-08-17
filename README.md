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

## Glue Crawler

Connect to the Jumpbox VM using instance connect, and then connect to the database:

```sh
mysql -u 'etluser' -p'passw0rd' \
    -h 'aurora-mysql-instance.cq1qsu0anb1o.sa-east-1.rds.amazonaws.com' \
    -P 3306 \
    -D 'testdb'
```

Apply the [`prepare-database.sql`](./prepare-database.sql) script to generate data.

Now run the crawler from the Glue console to feed the catalog.

## Glue ETL Job

Connect to the AWS Glue Studio and go to the Jobs blade. Create a new Job:

- Source: AWS Glue Database Catalog
- Target: S3

Enter JSON for the output format, and fill it in the required information.

Save the job. File [auto-generated-script-example.py](./auto-generated-script-example.py) is reference of what Glue will generate.

Run the job.

---
### Clean-up

Delete the Glue Job, Table, S3, CloudWatch Logs.

Run `terraform destroy -auto-approve` to remove the infrastructure.
