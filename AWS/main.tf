resource "aws_instance" "k8s-master-node" {
  ami           = "${var.ami}"
  instance_type = "${var.master_instance_type}"
  tags = {
    "name" = "master"
  }
  vpc_security_group_ids = var.vpc_sg_id
  key_name               = "${var.keypair}"
}

resource "aws_instance" "k8s-worker-node" {
  ami           = "${var.ami}"
  instance_type = "${var.worker_instance_type}"
  tags = {
    "name" = "worker"
  }
  vpc_security_group_ids = "${var.vpc_sg_id}"
  key_name               = "${var.keypair}"
}