# https://repost.aws/knowledge-center/api-gateway-cloudwatch-logs#
# https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html#set-up-access-logging-permissions
# https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html#apigateway-cloudwatch-log-formats

# https://www.davidgarc.com/blog/api-gw-log-headers/
# https://github.com/Cloudanix/docs/blob/main/docs/aws/audit/apigatewaymonitoring/rules/apigateway_cloudwatch_logs.mdx

Create AmazonAPIGatewayPushToCloudWatchLogs with assume policy with apigateway service

In APIGateWay Setting of any APIGateWay created=>Add the CloudWatch Log Role ARN created above=Save. You can enable the logs for each APIGateway Stages=Select the Stage=>Logging/Tracing=>Enable CloudWatch Logs=>Log Level[ERROR and INFO Logs]=Log Full Requests/Response Data[Enable it](REST API or Lambda Integration Backendvor HTTP BACKEND)=>Custom Access Logging[Enable]not sure if we need the custom access logging=>Access Log Destination ARN[arn:aws:logs:eu-west-2:xxxxxxxxxx:log-group:APIGatewayAccessLogs]have to create APIGatewayAccessLogs or Kinesis Data Firehose Stream Logs

These log settings are set using MethodSetting:
DataTraceEnabled - is for "Log full requests..."
LoggingLevel is for "Log level"
MetricsEnabled is for "Enable detailed CloudWatch metrics"

# https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-logging.html - Has examples of CLF, JSON,XML & CSV Formats
Note: HTTP APIs currently support only access logging. Logging setup is different for these APIs. For more information, see Configuring logging for an HTTP API.

aws logs create-log-group --log-group-name my-log-group

aws apigatewayv2 update-stage --api-id abcdef \
    --stage-name '$default' \
    --access-log-settings '{"DestinationArn": "arn:aws:logs:region:account-id:log-group:log-group-name", "Format": "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId"}'


# Troubleshoot issues connecting to an API Gateway Private API endpoint [Forbidden Error]-https://www.youtube.com/watch?v=KqTsBi3DisE
curl -v --connect-timeout 5 https://xxxx.execute-api.us-west-1.amazonaws.com/dev/pets

Check The Resource Policy in the APIGateway Rest API if using the correct VPC or policy. Security Group rule of the VPC and also the check the Policy tab on the API-Gateway Endpoint Point to see if it allows all Principal. Now check the EC2 instance security group rules making the request[changed from HTTP 80 to HTTPs 443] and VPC Interface Endpoint Security Group rules to HTTP 443. If Ok. HTTP 200.

# If the Private DNS names enabled is set to "true" use the invoke url
curl -v https://xxxx.execute-api.us-west-1.amazonaws.com/dev/pets

# If the Private DNS names enabled is set to "false" use the DNS name of the VPC Endpoint Interface
curl -v -H 'Host: xxxx.execute-api.us-west-1.amazonaws.com' https://vpce-077xxxxx-xxx.execute-api.us-west-1.vpce.amazonaws.com/dev/pets


# For accessin a Private API from an Amazon VPC in another AWS account, do the following
1. Create an interface VPC endpoint in the other account
2. Create and attach a resource policy to your privcate API. The policy must allow incoming traffic from the other account's VPC endpoint ID or VPC ID.

# AWS API Gateway - Cloudwatch logs - Troubleshooting - https://www.youtube.com/watch?v=tUPhFd4Q_Bk&t=986s

# AWS API Gateway tutorial ( Latest) - https://www.youtube.com/watch?v=c3J5uvdfSfE&list=PLruLATXv4pNz2RPn5X6iMmqyvv69NprJS

# APIGATEWAY DEMO - FOR GET METHOD - https://github.com/CodeSam621/Demo/blob/main/AWS%20Gateway/AWS%20Gateway-1/readme.md
Step 1. Create a Lambda Function-test-hello-lambda with Python3.11

import json

def lambda_handler(event, context):
    
    print(f'event: {event}');
    
    # this users object can be fetched from database  etc.
    users =  [
                {"id": 1, "name": "john dove"}, 
                {"id": 2, "name": "michel wats"}
             ]
        
    return {
        'statusCode': 200,
        'body': json.dumps(users)
    }

Step 2. Create demo-post-users lambda function with Python3.11
import json

def lambda_handler(event, context):
    
    print(f'event: {event}')
    print(f'Posting user details')
    # save the information database
    
    return {
        'statusCode': 200,
        'body': json.dumps('User added')
    }

APIGATEWAY=>Build REST API=>New API[Demo1]=>API EndPoint Type[Regional]=>Create API=>Create Resource=>Resource Path[/]=>Resource name[users]=Create Resource.Go to[/users]=>Create Method=>Select Method Type[GET]=>Lambda Function=>Select Region[us-east-2][arn:aws:lambda:us-east-2:106878672844:function:test-hello-lambda]=>Create Method.The default timeout is 29 seconds.
Go to[/users]=>Create Method=>Select Method Type[POST]=>Lambda Function=>Select Region[us-east-2][arn:aws:lambda:us-east-2:106878672844:function:demo-post-users]=>Create Method.

If you want to create another resource=>Click on the root[/]=>Create Resource=>Resource Path[/]=>Resource name[products]=Create Resource=>[/products]=>Create Method=>Select Method Type[GET]=>Mock=>Create Method

Now Click on the top level root again[/]=>Deploy API=Stage=New Stage=>Stage name[dev]=>Deployment Description[this is the dev environment for testing]=>Create Stage.Go to Stages=>click on +dev[Opens up the /products GET and /users GET & POST to view the invoke url]https://9b27lhpdeh.execute-api.us-east-2.amazonaws.com/dev/users

Go to CloudWatch Logs to see the Logs-/aws/lambda/test-hello-lambda
/aws/lambda/demo-post-users logs shows event as {}. To have an event so go to POSTMASTER in the POST folder=Select Body=raw=>JSON=json=>Send. Then check again on the CloudWatch Logs.
{
   "id": 3,
   "name": "DEMO USER1"
}


# https://stackoverflow.com/questions/52156285/terraform-how-to-enable-api-gateway-execution-logging
# https://stackoverflow.com/questions/59051933/configuring-logging-of-aws-api-gateway - Has a SAM template to create the API Gateway CW Log.

According to this documentation (https://aws.amazon.com/premiumsupport/knowledge-center/api-gateway-cloudwatch-logs/) after creating the Role, you need to add it to the Global AWS Api Gateway Settings (when you open the Console, there is a settings menu in the left pane) as the CloudWatch log role ARN. Then it will use that role for all the gateways you create, so this is a one-time step.
