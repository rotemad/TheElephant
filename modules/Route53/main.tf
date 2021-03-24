resource "aws_route53_zone" "elephant-internal" {
  name = "elephant.internal"

  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "consul" {
  count = "3"
  zone_id = aws_route53_zone.elephant-internal.zone_id
  name    = format("consul-server%d", count.index +1)
  type    = "A"
  ttl     = "300"
  records = [var.consul[count.index]]
}

resource "aws_route53_record" "prom-grafana" {
  zone_id = aws_route53_zone.elephant-internal.zone_id
  name    = "prom-grafana"
  type    = "A"
  ttl     = "300"
  records = [join(",", var.prom-grafana)]
}

resource "aws_route53_record" "jenkins-master" {
  zone_id = aws_route53_zone.elephant-internal.zone_id
  name    = "jenkins-master"
  type    = "A"
  ttl     = "300"
  records = [join(",", var.jenkins-master)]
}

resource "aws_route53_record" "jenkins-worker" {
  count = "2"
  zone_id = aws_route53_zone.elephant-internal.zone_id
  name    = format("jenkins-worker%d", count.index +1)
  type    = "A"
  ttl     = "300"
  records = [var.jenkins-worker[count.index]]
}

resource "aws_route53_record" "elk" {
  zone_id = aws_route53_zone.elephant-internal.zone_id
  name    = "elk"
  type    = "A"
  ttl     = "300"
  records = [join(",", var.elk)]
}

resource "aws_route53_record" "mysql" {
  zone_id = aws_route53_zone.elephant-internal.zone_id
  name    = "mysql"
  type    = "A"
  ttl     = "300"
  records = [join(",", var.mysql)]
}

