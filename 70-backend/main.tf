# ec2 instance creation (backend)

module "backend" {
  source = "terraform-aws-modules/ec2-instance/aws"
  ami    = data.aws_ami.joindevops.id
  name   = local.resource_name

  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.backend_sg_id]
  subnet_id              = local.private_subnet_id

  tags = merge(
    var.common_tags,
    var.backend_tags,
    {
      Name = local.resource_name
    }
  )
}

# resource "null_resource" "backend" {
#   # Changes to any instance of the cluster requires re-provisioning
#   triggers = {
#     instance_id = 
#   }

#   # Bootstrap script can run on any instance of the cluster
#   # So we just choose the first in this case
#   connection {
#     host = element(aws_instance.cluster[*].public_ip, 0)
#   }

#   provisioner "remote-exec" {
#     # Bootstrap script called with private_ip of each node in the cluster
#     inline = [
#       "bootstrap-cluster.sh ${join(" ",
#       aws_instance.cluster[*].private_ip)}",
#     ]
#   }
# }