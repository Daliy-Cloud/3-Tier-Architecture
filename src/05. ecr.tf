resource "aws_ecr_repository" "ecr" {
  name = "wsc-ecr"

  image_scanning_configuration {
    scan_on_push = true
    }

    tags = {
        Name = "wsc-ecr"
    } 
}