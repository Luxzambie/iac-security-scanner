provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "new_new_test" {
  bucket = "my-insecure-bucket-12345"
  acl    = "public-read"           # 1. Public read access (bad practice)
  force_destroy = true             # 2. Dangerous: bucket can be destroyed with objects inside
}

resource "aws_security_group" "bad_sg" {
  name        = "bad_sg"
  description = "Security group with wide open ingress"
  vpc_id      = "vpc-12345678"

  ingress {
    description = "Allow all traffic"
    from_port   = 0                # 3. Allow all ports
    to_port     = 65535
    protocol    = "-1"             # 4. All protocols
    cidr_blocks = ["0.0.0.0/0"]   # 5. From anywhere (public)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_user" "bad_user" {
  name = "bad_user"
  force_destroy = true             # 6. User deletion forced even with active credentials (risky)
}

resource "aws_db_instance" "bad_db" {
  allocated_storage    = 10
  engine               = "mysql"
  instance_class       = "db.t2.micro"
  name                 = "bad_db"
  username             = "admin"
  password             = "password123"     # 7. Hardcoded plaintext password (very risky)
  publicly_accessible  = true               # 8. Publicly accessible database
  skip_final_snapshot  = true               # 9. Skipping final snapshot (bad for recovery)
}

resource "aws_s3_bucket_public_access_block" "new_new_test" {
  bucket = aws_s3_bucket.new_new_test.id

  block_public_acls       = false            # 10. Not blocking public ACLs (bad)
  block_public_policy     = false            # 11. Not blocking public bucket policies
  ignore_public_acls      = false
  restrict_public_buckets = false
}
