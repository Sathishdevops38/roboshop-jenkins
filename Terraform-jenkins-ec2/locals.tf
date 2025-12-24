locals {
  common_name_suffix = "${var.project_name}-${var.environment}"
  ami_id = data.aws_ami.custom.id
  vpc_id = data.aws_vpc.default_vpc.id
  public_subnet_id = data.aws_subnet.default_subnet.id
  security_group_id = data.aws_security_group.default_sg.id
  common_tags ={
    Terraform = true
    app = "jenkins"
  }
}

