provider "aws" {
    region = "us-west-2"  # Change to your preferred region
}

provider "tls" {
    # for generating an ssh keypair
}

resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft_secg"
  description = "Allow SSH inbound traffic"

  ingress {
        from_port = 25565
        to_port = 25565
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 25565
        to_port = 25565
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow inbound ICMP (ping) traffic
    ingress {
        from_port   = -1    # -1 means all ICMP types
        to_port     = -1    # -1 means all ICMP types
        protocol    = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Generate a new SSH Key Pair using the tls provider
resource "tls_private_key" "minecraft_key" {
    algorithm = "RSA"
    rsa_bits  = 2048
}

# Create SSH Key Pair in AWS using the generated public key
resource "aws_key_pair" "minecraft_key" {
    key_name = "minecraft_key"
    public_key = tls_private_key.minecraft_key.public_key_openssh  # Use the generated public key from tls_private_key
}

resource "aws_instance" "minecraft_instance" {
    ami           = "ami-05f9478b4deb8d173" # Amazon Linux AMI for us west 2
    instance_type = "t2.micro"
    security_groups = [aws_security_group.minecraft_sg.name]
    key_name = aws_key_pair.minecraft_key.key_name  # Associate SSH Key Pair with EC2 instance

    tags = {
        Name = "terraform-ec2-example"
    }
}



output "minecraft_instance_ip" {
    value = aws_instance.minecraft_instance.public_ip
}

output "private_key_pem" {
  value     = tls_private_key.minecraft_key.private_key_pem
  sensitive = true
}
