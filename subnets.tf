locals {
    cluster_name = "${var.cluster_name}"
}


resource "aws_subnet" "eks-public" {
    count = "${length(var.public_subnets)}"
    vpc_id = "${var.eks_vpc_id}"
    cidr_block = "${var.public_subnets[count.index]}"
    availability_zone = "${element(var.azs, count.index)}"
    map_public_ip_on_launch = "${var.map_public_ip_on_launch}"
    lifecycle {
        ignore_changes = ["tags"]
    }

    tags {
        "Name" = "${format("eks-public%.1d-%.1s", count.index + 1, substr(element(var.azs, count.index), length(element(var.azs, count.index)) - 1, 1))}"
        "provisioned" = "terraform"
        "environment" = "${var.tag_environment}"
        "type" = "public"
        "kubernetes.io/role/elb" = 1
        "kubernetes.io/cluster/${var.cluster_name}-${var.tag_service}-${var.tag_environment}" = "shared"
    }
}

resource "aws_subnet" "eks-private" {
    count = "${length(var.private_subnets)}"
    vpc_id = "${var.eks_vpc_id}"
    cidr_block = "${var.private_subnets[count.index]}"
    availability_zone = "${element(var.azs, count.index)}"
    lifecycle {
        ignore_changes = ["tags"]
    }
    
    tags {
        "Name" = "${format("eks-private%.1d-%.1s", count.index + 1, substr(element(var.azs, count.index), length(element(var.azs, count.index)) - 1, 1))}"
        "zone" = "${format("%.1s%.1s%s", element(split("-", element(var.azs, count.index)), 0), element(split("-", element(var.azs, count.index)), 1), element(split("-", element(var.azs, count.index)), 2))}"
        "provisioned" = "terraform"
        "environment" = "${var.tag_environment}"
        "kubernetes.io/role/internal-elb" = 1
        "kubernetes.io/cluster/${var.cluster_name}-${var.tag_service}-${var.tag_environment}" = "shared"
    }
}

resource "aws_route_table" "eks-public-rt" {
    vpc_id = "${var.eks_vpc_id}"
    count = "${length(var.public_subnets)}"
    tags {
        "Name" = "${format("eks-rt-public-%.1s", substr(element(var.azs, count.index), length(element(var.azs, count.index)) - 1, 1))}"
        "provisioned" = "terraform"
        "environment" = "${var.tag_environment}"
    }
}

resource "aws_route_table" "eks-private-rt" {
    vpc_id = "${var.eks_vpc_id}"
    count = "${length(var.private_subnets)}"
    tags {
        "Name" = "${format("eks-rt-private-%.1s", substr(element(var.azs, count.index), length(element(var.azs, count.index)) - 1, 1))}"
        "provisioned" = "terraform"
        "environment" = "${var.tag_environment}"
    }
}

resource "aws_route" "public_internet_gateway" {
    count = "${length(var.public_subnets)}"
    route_table_id = "${element(aws_route_table.eks-public-rt.*.id, count.index)}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${var.eks_vpc_igw_id}"
}

resource "aws_route" "private_nat_gateway" {
    route_table_id = "${element(aws_route_table.eks-private-rt.*.id, count.index)}"
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${element(var.eks_ngw_id, count.index)}"
    count = "${length(var.private_subnets) * lookup(map(var.enable_nat_gateway, 1), "true ", 0)}"
}

resource "aws_route_table_association" "public" {
    count = "${length(var.public_subnets)}"
    subnet_id = "${element(aws_subnet.eks-public.*.id, count.index)}"
    route_table_id = "${element(aws_route_table.eks-public-rt.*.id, count.index)}"
}

resource "aws_route_table_association" "private" {
    count = "${length(var.private_subnets)}"
    subnet_id = "${element(aws_subnet.eks-private.*.id, count.index)}"
    route_table_id = "${element(aws_route_table.eks-private-rt.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "eks-worker-s3-endpoint-assoc" {
    count = "${length(var.private_subnets)}"
    route_table_id = "${element(aws_route_table.eks-private-rt.*.id, count.index)}"
    vpc_endpoint_id = "${var.s3_vpc_endpoint_id}"
}