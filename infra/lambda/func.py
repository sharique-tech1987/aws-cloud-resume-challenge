import json
import boto3

# Fetch views from DynamoDB and return it
# Increase views count by 1
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('cloudresume')
def handler(event, context):
    response = table.get_item(Key={
        'id':'0'
    })
    views = response['Item']['views']
    views = views + 1
    print(views)
    response = table.put_item(Item={
            'id':'0',
            'views': views
    })

    return views