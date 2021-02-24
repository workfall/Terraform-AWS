provider "aws" {
  region     = "us-east-1"
  access_key = ""  
  secret_key = ""  
}
#create cloud watch alarm
resource "aws_cloudwatch_metric_alarm" "HTTPCode_ELB_4XX_Count" {
  alarm_name          = "WORKFALL-Cloudwatch-alarm-alb"
   comparison_operator = "GreaterThanThreshold"
   evaluation_periods  = "1"
   metric_name         = "HTTPCode_ELB_4XX"
   namespace           = "AWS/ApplicationELB"
   period              = "60"
   statistic           = "Sum"
   threshold           = "1"
   treat_missing_data  = "notBreaching"
   alarm_description   = "The number of 4xx HTTP response for ALB"
   alarm_actions       =  [ aws_sns_topic.WORKFALL_sns_topic.id ]
   ok_actions          =   [ aws_sns_topic.WORKFALL_sns_topic.id ]
   insufficient_data_actions =   [ aws_sns_topic.WORKFALL_sns_topic.id ]
    dimensions = {
  "LoadBalancer" = "WorkFall-ALB"  
   }
  }


  ## Create SNS topic 
  resource "aws_sns_topic" "WORKFALL_sns_topic" {
  name = "WORKFALL_sns_topic"
  }

  ##Create SNS subscription

  resource "aws_sns_topic_subscription" "WORKFALL_lambda_target" {
  topic_arn = aws_sns_topic.WORKFALL_sns_topic.id
  protocol  = "lambda"
  endpoint  = aws_lambda_function.WORKFALL_Lambda.arn
}

##Create AWS Lambda to integrate with MS Teams and SNS

resource "aws_lambda_function" "WORKFALL_Lambda" {
  filename      = "${path.module}/output/workfall.zip"
  function_name = "workfall"
  role          = aws_iam_role.iam_WORKFALL_Lambda.arn
  handler       = "workfall.lambda_handler"
  runtime = "python3.6"
  

}





resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.WORKFALL_Lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.WORKFALL_sns_topic.id
}

resource "aws_iam_role" "iam_WORKFALL_Lambda" {
  name = "iam_WORKFALL_Lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}



data "archive_file" "zipit" {

  type        = "zip"

  source_file = "${path.module}/workfall.py"

  output_path = "${path.module}/output/workfall.zip"

}

