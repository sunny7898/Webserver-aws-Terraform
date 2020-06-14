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
	
// Login into instance using ssh.
	connection {
		type     = "ssh"
		user     = "ec2-user"
		private_key = file("C:/Work/Terraform/Credentials/LinuxOs1.pem")
		host     = aws_instance.webs1.public_ip
	}
// Setting Up the httpd services in the webserver
	provisioner "remote-exec" {
		inline = [
			"sudo yum install httpd php git -y",
			"sudo systemctl restart httpd",
			"sudo systemctl enable httpd"
		]
	}
}

// Creating EBS
resource "aws_ebs_volume" "webs-ebs1" {
  availability_zone = aws_instance.webs1.availability_zone
  size              = 1
  tags = {
    Name = "Web_server1_ebs"
  }
}

// Attaching the EBS
resource "aws_volume_attachment" "webs-eb1-att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.webs-ebs1.id}"
  instance_id = "${aws_instance.webs1.id}"
  force_detach = true
}

// Mounting, And downloading the github code into the working directory
resource "null_resource" "mounting" {

	depends_on = [
		aws_volume_attachment.webs-eb1-att
	]
		
	connection {
		type     = "ssh"
		user     = "ec2-user"
		private_key = file("C:/Work/Terraform/Credentials/LinuxOs1.pem")
		host     = aws_instance.webs1.public_ip
	}
	
	provisioner "remote-exec" {
		inline = [
			"sudo mkfs.ext4 /dev/xvdh",
			"sudo mount /dev/xvdh  /var/www/html",
			"sudo rm -rf /var/www/html/*",
			"sudo git clone https://github.com/sunny7898/devopsal5.git /var/www/html/"
		]
	}
}

// Displaying the IP of the instance
output "Web_server1_IP"  {
	value = aws_instance.webs1.public_ip
} 
// Storing the IP of instance locally in a text file.
resource "null_resource" "IP" {
	provisioner "local-exec" {
		command = "echo ${aws_instance.webs1.public_ip} > public_ips.txt" 
	}
}

//Running the Webpage
resource "null_resource" "Checkserver" {
	depends_on = [
		null_resource.mounting
	]
	provisioner "local-exec" {
		command = "chrome ${aws_instance.webs1.public_ip}"
	}
}
