terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}

/*
 * @dev    Create VPC with two public subnets assuming current region contains at least two availability zones
 * @dev    Create new internet gateway for public subnets initially
 */
module "vpc" {
  source = "../../modules/vpc"
  env    = var.env

  cidr_block = "10.0.0.0/16"
  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
  availability_zones = [
    "${var.aws_region}a",
    "${var.aws_region}b"
  ]
}

/*
 * @dev    Create new route table to attach new subnets to the internet gateway
 */
resource "aws_route_table_association" "public" {
  count = length(module.vpc.public_subnets_ids)

  subnet_id      = module.vpc.public_subnets_ids[count.index]
  route_table_id = module.vpc.public_rt
}

data "aws_route_tables" "default" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }

  filter {
    name   = "association.main"
    values = ["true"]
  }
}

/*
 * @dev    Rename default routing table 
 */
resource "aws_default_route_table" "default" {
  default_route_table_id = data.aws_route_tables.default.ids[0]

  tags = {
    Name = "${var.env}-default-rt"
  }
}

/*
 * @dev     Create security group that is going to be applied to load balancer
 * @param   Allows ingress TCP traffic on port 443
 * @param   Allows egress all traffic on all ports range
 */
resource "aws_security_group" "alb_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-alb-sg"
  }
}

resource "aws_ecr_repository" "backend" {
  name                 = "${var.env}-backend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = var.env
  }
}


/*
 * @dev     Attach ALB public subnets inside VPC
 */
module "alb" {
  source = "../../modules/alb"

  env               = var.env
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnets_ids
  security_groups   = [aws_security_group.alb_sg.id]
  certificate_arn   = var.backend_certificate_arn
}

/*
 * @dev     Create security group that is going to be applied to all EC2 instances
 * @param   Allows ingress TCP traffic on port 8080
 * @param   Allows ingress TCP traffic on port 22 on admins IP
 * @param   Allows egress all traffic on all ports range
 */
resource "aws_security_group" "ec2_sg" {
  name   = "${var.env}-ec2-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-ec2-sg"
  }
}

/*
 * @dev     Search for exact Linux machine AMI
 */
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "asg" {
  source = "../../modules/asg"

  ami_id           = data.aws_ami.amazon_linux.id
  instance_type    = "t3.micro"
  security_group   = aws_security_group.ec2_sg.id
  subnet_ids       = module.vpc.public_subnets_ids
  lb_arn           = module.alb.lb_arn
  env              = var.env
  target_group_arn = module.alb.target_group_arn
  access_key       = var.access_key
  secret_key       = var.secret_key
  region           = var.aws_region
  account_id       = var.account_id
}

module "s3_document_bucket" {
  source      = "../../modules/s3-bucket"
  bucket_name = "migdal-document-bucket"

  env = var.env
}

/*
 * @dev     Create security group for RDS PostgreSQL to allow connections from EC2 instances
 * @param   Allows ingress TCP traffic on port 5432 from EC2 security group
 * @param   Allows egress all traffic on all ports range
 */
resource "aws_security_group" "rds_sg" {
  name   = "${var.env}-rds-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-rds-sg"
  }
}

module "rds-core" {
  source             = "../../modules/rds"
  env                = var.env
  vpc_id             = module.vpc.vpc_id
  db_subnet_ids      = module.vpc.public_subnets_ids
  security_group_ids = [aws_security_group.rds_sg.id]

  engine            = "postgres"
  engine_version    = "16.3"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  username          = var.db_username
  password          = var.db_password
  db_name           = "core"
}

module "rds-third-party" {
  source             = "../../modules/rds"
  env                = var.env
  vpc_id             = module.vpc.vpc_id
  db_subnet_ids      = module.vpc.public_subnets_ids
  security_group_ids = [aws_security_group.rds_sg.id]

  engine            = "postgres"
  engine_version    = "16.3"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  username          = var.db_username
  password          = var.db_password
  db_name           = "core"
}

module "s3_admin" {
  source      = "../../modules/s3-website"
  env         = var.env
  bucket_name = "${var.env}-migdal-admin-website"
  aws_region  = var.aws_region
}

module "cloudfront_admin" {
  source                         = "../../modules/cloudfront"
  env                            = var.env
  acm_certificate_arn            = var.admin_certificate_arn
  aliases                        = [var.admin_domain]
  index_document                 = "index.html"
  s3_bucket_regional_domain_name = module.s3_admin.bucket_regional_domain_name
}

module "gateway_admin" {
  source     = "../../modules/gateway"
  env        = var.env
  stage_name = var.env
}

module "s3_client" {
  source      = "../../modules/s3-website"
  env         = var.env
  bucket_name = "${var.env}-migdal-client-website"
  aws_region  = var.aws_region
}

module "cloudfront_client" {
  source                         = "../../modules/cloudfront"
  env                            = var.env
  acm_certificate_arn            = var.client_certificate_arn
  aliases                        = [var.client_domain]
  index_document                 = "index.html"
  s3_bucket_regional_domain_name = module.s3_client.bucket_regional_domain_name
}

module "gateway_client" {
  source     = "../../modules/gateway"
  env        = var.env
  stage_name = var.env
}