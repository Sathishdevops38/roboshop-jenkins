
resource "aws_instance" "master" {
  ami = local.ami_id
  security_groups = [local.security_group_id]
  instance_type = var.instance_type
  subnet_id = local.public_subnet_id
  iam_instance_profile = aws_iam_instance_profile.jenkins.name
    # need more for terraform
  root_block_device {
    volume_size           = 50             # Custom volume size in GiB
    volume_type           = "gp3"          # Custom volume type (e.g., gp2, gp3, io1, io2, standard)
    delete_on_termination = true           # Whether to delete the volume when the instance is terminated
    encrypted             = true           # Whether to encrypt the volume
    # iops                  = 3000         # Required for io1/io2 volume types
    # kms_key_id            = "..."        # The KMS key to use for encryption
    # tags = {                             # Tags for the volume itself
    #   Name = "RootVolume"
}
  user_data = file("master.sh")
  tags= merge(
    var.tags,
    local.common_tags,{
      Name =  "${var.project_name}-${var.environment}-master"
    }
  )  
}

resource "aws_route53_record" "master" {
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 1
  records = [aws_instance.master.private_ip]
  allow_overwrite = true
}

resource "aws_instance" "agent" {
  ami = local.ami_id
  security_groups = [local.security_group_id]
  instance_type = var.instance_type
  subnet_id = local.public_subnet_id
  iam_instance_profile = aws_iam_instance_profile.jenkins.name
    # need more for terraform
  root_block_device {
    volume_size           = 50             # Custom volume size in GiB
    volume_type           = "gp3"          # Custom volume type (e.g., gp2, gp3, io1, io2, standard)
    delete_on_termination = true           # Whether to delete the volume when the instance is terminated
    encrypted             = true           # Whether to encrypt the volume
    # iops                  = 3000         # Required for io1/io2 volume types
    # kms_key_id            = "..."        # The KMS key to use for encryption
    # tags = {                             # Tags for the volume itself
    #   Name = "RootVolume"
}
  user_data = file("agent.sh")
  tags= merge(
    var.tags,
    local.common_tags,{
      Name =  "${var.project_name}-${var.environment}-agent"
    }
  )  

}

resource "aws_route53_record" "agent" {
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 1
  records = [aws_instance.agent.private_ip]
  allow_overwrite = true
}


resource "aws_iam_instance_profile" "jenkins" {
  name = "jenkins"
  role = "BastionTerraformAdmin"
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_ingress" {
  ip_protocol       = "-1"
  from_port         = 0
  to_port           = 0
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = local.security_group_id
}