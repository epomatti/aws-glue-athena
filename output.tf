# output "instance_ip" {
#   value = aws_instance.jumpbox.public_ip
# }

# output "aurora_endpoint" {
#   value = aws_rds_cluster_instance.aurora_instances[0].endpoint
# }

output "rds_address" {
  value = module.rds.rds_address
}
