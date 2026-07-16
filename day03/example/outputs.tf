output "instance_ids" {
  description = "IDs of all EC2 instances."
  value       = aws_instance.web[*].id
}

output "public_ips" {
  description = "Public IPs of the web servers."
  value       = aws_instance.web[*].public_ip
}

output "web_urls" {
  description = "URLs to access the web servers."
  value       = [for ip in aws_instance.web[*].public_ip : "http://${ip}"]
}

output "ami_id" {
  description = "The Amazon Linux 2023 AMI resolved via the data source."
  value       = data.aws_ami.al2023.id
}
