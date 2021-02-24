# Terraform-AWS

A terraform template to integrate custom webhooks to send alarm notifications with AWS SNS and Lambda services.

In this hands on, we will use Terraform to provision AWS Cloudwatch alarm, AWS SNS topic and subscription and AWS Lambda. You’ll need terraform to be installed on your system and an active AWS subscription. We’ll utilise AWS Lambda functionality to send custom notifications to MS teams channel.

Steps:

1. Clone this repo in your project folder.
2. Provide your access keys and secret in main.tf files.
3. Provide your MS team webhook url in python script {workfall.py,line 45}.
4. Run the following commands:
    terraform init
    terraform plan
    terraform apply --auto-approve


To test the function:

Use aws cli to trigger alarm manually. Use the following command:
    aws cloudwatch set-alarm-state --alarm-name "alarmname" --state-value ALARM --state-reason "We are testing the integration service"


Contact:  contact@workfall.com
