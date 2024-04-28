#!/bin/bash
# This script will create the create-stack-parameter.json file
cat > ~/create-stack-parameter/create-stack-parameter.json <<EOF
    [
        {
            "ParameterKey": "<parameterkey>",
            "ParameterValue": "`curl https://www.<get-id> 2>/dev/null`"

        }
    ]
EOF    

STACK_ID="<stackname>"
STACK_ID=$( aws cloudformation create-stack --stack-name $STACK_NAME --template-body file://ssm-parameter.json --capabilities CAPABILITY_IAM --parameters-overrides file://create-stack-parameter.json --tags file://tag-ssm.json | jq -r .StackId )

echo "Waiting on $STACK_ID create completion..."
aws cloudformation wait stack-create-complete --stack-name $STACK_ID
aws cloudformation describe-stacks --stack-name $STACK_ID --query "Stacks[0].Outputs[*]" --output json | jq -r 'to_entries[] | "\(.value | .OutputValue): \(.value | .OutputValue)"' > output.txt