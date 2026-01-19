resource "aws_subnet" "public" {
  for_each = { for public_subnet in var.public_subnets : public_subnet.cidr_block => public_subnet }

  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    { "Name" = "${var.name}-${var.public_subnet_suffix}-${each.key}" },
    var.tags,
    var.public_subnet_tags,
  )
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = var.public_route_table_id
}

resource "aws_subnet" "private" {
  for_each = { for private_subnet in var.private_subnets : private_subnet.cidr_block => private_subnet }

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = merge(
    { "Name" = "${var.name}-${var.private_subnet_suffix}-${each.key}" },
    var.tags,
    var.private_subnet_tags,
  )
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = var.private_route_table_id
}
