resource "aws_cloudwatch_log_metric_filter" "delete_object_filter" {
  name           = "${var.name_prefix}-deleteobject-filter"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  pattern        = "{ ($.eventName = DeleteObject) }"

  metric_transformation {
    name      = "DeleteObjectCount"
    namespace = "S3/CloudTrail"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "delete_object_alarm" {
  alarm_name          = "${var.name_prefix}-DeleteObjectAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.delete_object_filter.metric_transformation[0].name
  namespace           = "S3/CloudTrail"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when DeleteObject API is called"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
