resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "wsc-vpc"
  }
}

resource"aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "wsc-IGW"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "wsc-public-rt"
  }
}
 
resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_subnet" "public_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "wsc-public-a"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "wsc-public-c"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "private_a" {
}

resource "aws_eip" "private_c" {
}

resource "aws_nat_gateway" "private_a" {
  depends_on = [aws_internet_gateway.main]

  allocation_id = aws_eip.private_a.id
  subnet_id = aws_subnet.public_a.id

  tags = {
    Name = "wsc-NGW-a"
  }
}

resource "aws_nat_gateway" "private_c" {
  depends_on = [aws_internet_gateway.main]

  allocation_id = aws_eip.private_c.id
  subnet_id = aws_subnet.public_c.id

  tags = {
    Name = "wsc-NGW-c"
  }
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "wsc-private-a-rt"
  }
}

resource "aws_route_table" "private_c" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "wsc-private-c-rt"
  }
}

resource "aws_route" "private_a" {
  route_table_id = aws_route_table.private_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.private_a.id
}

resource "aws_route" "private_c" {
  route_table_id = aws_route_table.private_c.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.private_c.id
}

resource "aws_subnet" "private_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.10.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "wsc-private-a"
  }
}

resource "aws_subnet" "private_c" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.20.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "wsc-private-c"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_c.id
}

resource "aws_route_table" "protect" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "wsc-protect-rt"
  }
}

resource "aws_subnet" "protect_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.100.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "wsc-protect-a"
  }
}

resource "aws_subnet" "protect_c" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.200.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "wsc-protect-c"
  }
}

resource "aws_route_table_association" "protect_a" {
  subnet_id = aws_subnet.protect_a.id
  route_table_id = aws_route_table.protect.id
}

resource "aws_route_table_association" "protect_c" {
  subnet_id = aws_subnet.protect_c.id
  route_table_id = aws_route_table.protect.id
}

