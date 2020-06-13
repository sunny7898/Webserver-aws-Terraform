// Telling the Provider
provider "aws" {
	region = "ap-south-1"
	profile = "tf-user1"
}

// Creating an instance
resource "aws_instance" "webs1" {
	ami = "ami-0447a12f28fddb066"
	instance_type = "t2.micro"
	key_name = "LinuxOs1"
	security_groups = [ "launch-wizard-2" ] 
	
	tags = {
		Name = "Web-server1" 
	}
	

	connection {
		type     = "ssh"
		user     = "ec2-user"
		private_key = file("C:/Work/Terraform/Credentials/LinuxOs1.pem")
		host     = aws_instance.webs1.public_ip
	}
	
// Setting Up the Webserver in the remote Instance
	provisioner "remote-exec" {
		inline = [
			"sudo yum install httpd php git -y",
			"sudo systemctl restart httpd",
			"sudo systemctl enable httpd",
			"sudo git clone https://github.com/sunny7898/devopsal5.git /var/www/html/"
		]
	}
}

output "Web_server1_IP"  {
	value = aws_instance.webs1.public_ip
}

resource "null_resource" "IP" {
	provisioner "local-exec" {
		command = "echo ${aws_instance.webs1.public_ip} > public_ips.txt" 
	}
}
	


