variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "public_lambda_arn" {
  type = string
}

variable "public_lambda_name" {
  type = string
}

variable "private_lambda_arn" {
  type = string
}

variable "private_lambda_name" {
  type = string
}

variable "vpn_server_ip" {
  type        = string
  description = "Public IP of the VPN server to allow access to private lambda"
}

variable "project_name" {
  type = string
}

resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_lb_target_group" "public_lambda" {
  name        = "${var.project_name}-pub-tg"
  target_type = "lambda"
  vpc_id      = var.vpc_id
}

resource "aws_lb_target_group" "private_lambda" {
  name        = "${var.project_name}-priv-tg"
  target_type = "lambda"
  vpc_id      = var.vpc_id
}

resource "aws_lb_target_group_attachment" "public_lambda" {
  target_group_arn = aws_lb_target_group.public_lambda.arn
  target_id        = var.public_lambda_arn
  depends_on       = [aws_lambda_permission.public]
}

resource "aws_lb_target_group_attachment" "private_lambda" {
  target_group_arn = aws_lb_target_group.private_lambda.arn
  target_id        = var.private_lambda_arn
  depends_on       = [aws_lambda_permission.private]
}

resource "aws_lambda_permission" "public" {
  statement_id  = "AllowExecutionFromALB"
  action        = "lambda:InvokeFunction"
  function_name = var.public_lambda_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.public_lambda.arn
}

resource "aws_lambda_permission" "private" {
  statement_id  = "AllowExecutionFromALB"
  action        = "lambda:InvokeFunction"
  function_name = var.private_lambda_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.private_lambda.arn
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "public" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_lambda.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

resource "aws_lb_listener_rule" "private" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private_lambda.arn
  }

  condition {
    path_pattern {
      values = ["/private"]
    }
  }

  condition {
    source_ip {
      values = ["${var.vpn_server_ip}/32"]
    }
  }
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

