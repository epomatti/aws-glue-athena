# ### Key Pair ###
# resource "aws_key_pair" "jumpbox" {
#   key_name   = "rds-jumpbox"
#   public_key = file("${path.module}/id_rsa.pub")
# }

# ### EC2 ###

# resource "aws_network_interface" "jumpbox" {
#   subnet_id       = aws_subnet.public.id
#   security_groups = [aws_security_group.main.id]
# }

# resource "aws_iam_instance_profile" "jumpbox" {
#   name = "rds-jumpbox-profile"
#   role = aws_iam_role.jumpbox.id
# }

# resource "aws_instance" "jumpbox" {
#   ami           = "ami-08ae71fd7f1449df1"
#   instance_type = "t2.micro"

#   iam_instance_profile = aws_iam_instance_profile.jumpbox.id
#   key_name             = aws_key_pair.jumpbox.key_name

#   # Detailed monitoring enabled
#   monitoring = true

#   # Install MySQL
#   user_data = file("${path.module}/mysql.sh")

#   network_interface {
#     network_interface_id = aws_network_interface.jumpbox.id
#     device_index         = 0
#   }

#   tags = {
#     Name = "rds-jumpbox"
#   }

# }
