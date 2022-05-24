#Get Linux AMI ID using SSM Parameter endpoint in us-east-1
data "aws_ssm_parameter" "linuxAmi_master" {
  provider = aws.region-master
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#Get Linux AMI ID using SSM Parameter endpoints in us-west-2
data "aws_ssm_parameter" "linuxAmi_worker" {
  provider = aws.region-worker
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#------

#Create key-pair for logging into EC2 in us-east-1
resource "aws_key_pair" "master_key" {
  provider   = aws.region-master
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}

#Create key-pair for logging into EC2 in us-west-2
resource "aws_key_pair" "worker_key" {
  provider   = aws.region-worker
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}

#----------


#Create and bootstrap EC2 in us-east-1
resource "aws_instance" "jenkins_master" {
  provider                    = aws.region-master
  ami                         = data.aws_ssm_parameter.linuxAmi_master.value
  instance_type               = var.instance_type
  key_name                    = aws_key_name.master_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  subnet_id                   = aws_subent.subnet_1.id

  tags = {
    "Name" = "jenkins_master_tf"
  }

  depends_on = [
    aws_main_route_table_association.set_master_default_rt_assoc
  ]
}


#Create and bootstrap EC2 in us-west-2
resource "aws_instance" "jenkins_worker" {
  provider                    = aws.region-worker
  count                       = var.workers_count
  ami                         = data.aws_ssm_parameter.linuxAmi_worker.value
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.worker_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins_sg_oregon.id]
  subnet_id                   = aws_subnet.subnet_1_oregon.id

  tags = {
    "Name" = join("-", ["jenkins_worker_tf", count.index + 1])
  }

  depends_on = [
    aws_main_route_table_association.set_worker_default_rt_assoc, aws_instance.jenkins_master
  ]
}