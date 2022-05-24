output "Jenkins-Main-Node-Public-Ip" {
  value = aws_instance.jenkins_master.public_ip
}

output "Jenkins-Worker-Public-Ips" {
  value = {
    for instance in aws_instance.jenkins_worker :
    instance.id => instance.public_ip
  }
}