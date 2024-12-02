resource "aws_security_group" "db" {
  name        = "wsc-RDS-SG"
  description = "wsc-RDS-SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    from_port   = 4000
    to_port     = 4000
  }

  egress {
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "wsc-RDS-SG"
  }
}

resource "aws_db_subnet_group" "db" {
  name       = "wsc-rds-sg"
  subnet_ids = [
    aws_subnet.protect_a.id,
    aws_subnet.protect_c.id
  ]

  tags = {
    Name = "wsc-rds-sg"
  }
}

resource "aws_rds_cluster_parameter_group" "db" {
  name        = "wsc-rds-cpg"
  description = "wsc-rds-cpg"
  family      = "aurora-mysql8.0"

  parameter {
    name  = "time_zone"
    value = "Asia/Seoul"
  }

  tags = {
    Name = "wsc-rds-cpg"
  }
}

resource "aws_db_parameter_group" "db" {
  name        = "wsc-rds-pg"
  description = "wsc-rds-pg"
  family      = "aurora-mysql8.0"

  tags = {
    Name = "wsc-rds-pg"
  }
}

resource "aws_kms_key" "rds" {
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7

  tags = {
    Name = "rds-kms"
  }
}

resource "aws_kms_alias" "rds" {
  target_key_id = aws_kms_key.rds.key_id
  name          = "alias/rds-kms"
}

resource "aws_rds_cluster" "db" {
  cluster_identifier             = "wsc-db-cluster"
  database_name                  = "wsc_db"
  availability_zones             = ["ap-northeast-2a", "ap-northeast-2c"]
  db_subnet_group_name           = aws_db_subnet_group.db.name
  vpc_security_group_ids         = [aws_security_group.db.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.db.name
  kms_key_id                     = aws_kms_key.rds.arn
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  engine                         = "aurora-mysql"
  master_username                = "admin"
  master_password                = "Skill53##"
  skip_final_snapshot            = true
  storage_encrypted              = true
  port                           = 4000

  tags = {
    Name = "wsc-db-cluster"
  }
}

resource "aws_rds_cluster_instance" "db" {
  count                   = 1
  cluster_identifier      = aws_rds_cluster.db.id
  db_subnet_group_name    = aws_db_subnet_group.db.name
  db_parameter_group_name = aws_db_parameter_group.db.name
  instance_class          = "db.t3.medium"
  identifier              = "wsc-db-instance"
  engine                  = "aurora-mysql"

  tags = {
    Name = "wsc-db-instance"
  }
}

resource "aws_secretsmanager_secret" "db" {
  name                   = "rds-secrets"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    "username"            = aws_rds_cluster.db.master_username,
    "password"            = aws_rds_cluster.db.master_password,
    "engine"              = aws_rds_cluster.db.engine,
    "host"                = aws_rds_cluster.db.endpoint,
    "port"                = aws_rds_cluster.db.port,
    "dbClusterIdentifier" = aws_rds_cluster.db.cluster_identifier,
    "dbname"              = aws_rds_cluster.db.database_name
  })
}
