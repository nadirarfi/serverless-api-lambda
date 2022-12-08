import boto3
import json
from botocore.exceptions import ClientError



def returnResponse(statusCode:int, body=None):
    response = {
        'statusCode': statusCode,
        'headers': {
            'Content-Type': 'application/json',
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Origin": "*"

        }
    }
    if body is not None:
        response["body"] = json.dumps(body)
    return response


def get_all_items(table_name:str, region_name="eu-north-1"):
    """
    GET all items
    """
    try:
        dynamodb = boto3.resource("dynamodb", region_name=region_name)
        table = dynamodb.Table(table_name)
        db_response = table.scan()
        items = db_response['Items']
        body = {
            "operation": "GET",
            "message": "SUCCESS",
            "items": items
        }
        return returnResponse(statusCode=200, body=body)
        
        
    except ClientError as e:
        print(e)
        return False


# CREATE
def post_item(table_name:str, item:dict, region_name="eu-north-1"):
    """
    POST item to DynamoDB
    post_item(table_name="Books", item={"book_id":"2", "Author": "Jordan Petterson"})
    """
    try:
        dynamodb = boto3.resource("dynamodb", region_name=region_name)
        table = dynamodb.Table(table_name)
        db_response = table.put_item(Item=item)
        body = {
            "operation": "CREATE",
            "message": "SUCCESS",
            "dynamodb": db_response
        }
        return returnResponse(statusCode=200, body=body)
    except ClientError as e:
        print(e)
        return False


# READ
def get_item(table_name:str, key:dict, region_name="eu-north-1"):
    """
    GET item from DynamoDB
    get_item(table_name="Books", Key={"book_id": "1"})
    """
    try:
        dynamodb = boto3.resource("dynamodb", region_name=region_name)
        table = dynamodb.Table(table_name)
        db_response = table.get_item(Key=key)
        item = db_response["Item"]
        body = {
            "operation": "READ",
            "message": "SUCCESS",
            "dynamodb": db_response,
            "item": item
        }     
        return returnResponse(statusCode=200, body=body)
    except ClientError as e:
        print(e)
        return returnResponse(statusCode=404, body={"message": "ERROR 404"})  




# UPDATE
def update_item(table_name:str, key:dict, attribute=None, value=None, region_name="eu-north-1"):
    """
    UPDATE item in DynamoDB
    update_item(table_name="Books", key={"book_id": "1"}, attribute="Author", value="Jordan Peterson")
    """
    try:
        dynamodb = boto3.resource("dynamodb", region_name=region_name)
        table = dynamodb.Table(table_name)
        if attribute and value:
            db_response = table.update_item(
                Key= key,
                UpdateExpression= f"SET {attribute} = :value",
                ExpressionAttributeValues={
                    ':value': value
                    }
                )
            body = {
                "operation": "UPDATE",
                "message": "SUCCESS",
                "dynamodb": db_response
            }
            return returnResponse(statusCode=200, body=body)

    except ClientError as e:
        print(e)
        return False


# DELETE
def delete_item(table_name:str, key:dict, region_name="eu-north-1"):
    """
    DELTE item from DynamoDB
    delete_item(table_name="Books", key={"book_id":"1"})
    """
    try:
        dynamodb = boto3.resource("dynamodb", region_name=region_name)
        table = dynamodb.Table(table_name)    
        db_response = table.delete_item(Key=key)
        body = {
            "operation": "DELETE",
            "message": "SUCCESS",
            "dynamodb": db_response
        }
        return returnResponse(statusCode=200, body=body)
    except ClientError as e:
        print(e)
        return False



