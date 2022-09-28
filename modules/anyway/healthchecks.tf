locals {
  healthchecks = {
    www_anyway_co_il = {
      fqdn = aws_route53_record.anyway_co_il["www"].fqdn
      path = "/"
    }
    www_oway_org_il = {
      fqdn = aws_route53_record.oway_org_il["www"].fqdn
      path = "/"
    }
    airflow_anyway_co_il = {
      fqdn = aws_route53_record.anyway_co_il["airflow"].fqdn
      path = "/health"
    }
    dev_airflow_anyway_co_il = {
      fqdn = aws_route53_record.anyway_co_il["dev-airflow"].fqdn
      path = "/health"
    }
  }
}

resource "aws_route53_health_check" "anyway" {
  for_each = local.healthchecks
  fqdn = each.value.fqdn
  resource_path = each.value.path
  port = 443
  type = "HTTPS"
  failure_threshold = 5
  request_interval = 30
  tags = {
    Name = "anyway-healthcheck-${each.key}"
  }
}

resource "aws_cloudwatch_metric_alarm" "anyway_healthchecks" {
  for_each = local.healthchecks
  alarm_name          = "anyway_healthcheck_${each.key}"
  namespace           = "AWS/Route53"
  metric_name         = "HealthCheckStatus"
  # raise alarm if health checks failed
  comparison_operator = "LessThanThreshold"
  threshold           = "1"
  # for 60 seconds
  evaluation_periods  = "1"
  period              = "60"
  statistic           = "Minimum"
  dimensions = {
    HealthCheckId = aws_route53_health_check.anyway[each.key].id
  }
  alarm_description   = "This metric monitors whether ${each.key} endpoint is down or not."
  alarm_actions       = [aws_sns_topic.anyway_healthchecks.id]
}

resource "aws_sns_topic" "anyway_healthchecks" {
  name = "anyway-healthchecks"
}

output "anyway_healthchecks_alarms" {
  value = "To get alarms, add subscribers to SNS topic ${aws_sns_topic.anyway_healthchecks.name}"
}
