provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "wildev"{
  cidr_block = "10.0.0.0/16"

  tags = {
    "key" = "wildevvpc"
  }
}
 
