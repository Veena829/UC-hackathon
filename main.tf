resource "aws_cloudtrail" "trail" {
  name                          = "${var.name_prefix}-cloudtrail"
  s3_bucket_name                = var.cloudtrail_s3_bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_role.arn
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/${var.name_prefix}"
  retention_in_days = 7
}

resource "aws_iam_role" "cloudtrail_role" {
  name = "${var.name_prefix}-cloudtrail-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "cloudtrail_policy" {
  name = "${var.name_prefix}-cloudtrail-policy"
  role = aws_iam_role.cloudtrail_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
    }]
  })
}

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

resource "aws_cloudwatch_log_metric_filter" "put_object_filter" {
  name           = "${var.name_prefix}-putobject-filter"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  pattern        = "{ ($.eventName = PutObject) }"
  metric_transformation {
    name      = "PutObjectCount"
    namespace = "S3/CloudTrail"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "delete_bucket_filter" {
  name           = "${var.name_prefix}-deletebucket-filter"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  pattern        = "{ ($.eventName = DeleteBucket) }"
  metric_transformation {
    name      = "DeleteBucketCount"
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
  alarm_description   = "Triggers when DeleteObject API is called"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "put_object_alarm" {
  alarm_name          = "${var.name_prefix}-PutObjectAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.put_object_filter.metric_transformation[0].name
  namespace           = "S3/CloudTrail"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggers when PutObject API is called"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "delete_bucket_alarm" {
  alarm_name          = "${var.name_prefix}-DeleteBucketAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.delete_bucket_filter.metric_transformation[0].name
  namespace           = "S3/CloudTrail"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggers when DeleteBucket API is called"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_sns_topic" "alerts" {
  name = "${var.name_prefix}-alerts"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}