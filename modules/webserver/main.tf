resource "aws_default_security_group" "default-sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }
  
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

    tags = {
    Name: "${var.env_prefix}-sg"
  }

}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = [var.image_name]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}  

resource "aws_key_pair" "ssh-key" {
  key_name ="server-key"
  public_key = var.public_key
 }

resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  user_data = file("entry-script.sh")

  /*
  The connection type for the provisioner should be specified
    connection {
      type = "ssh"
      host = self.public_ip
      user = "ec2-user"
      private_key = file(var.private_key_location)
    }

  This helps to copy file from directories from local to newly created resource
    provisioner "file" {
      source = "entry-script.sh"
      destination = "/home/ec2-user/Filename_preferred.sh"
    }

  This block is used to execute commands remotely in a server. It invokes script on a remote resource after it is created.
   provisioner "remote-exec" {
    inline = [ 
      "export ENV=dev"
      "mkdir newdir"
      script = file("Filename_preferred.sh")
     ]
  }

    provisioner "local-exec" {
      command = "echo ${self.public_ip} > output.txt"
    }
*/

  tags = {
    Name: "${var.env_prefix}-server"
  }

}