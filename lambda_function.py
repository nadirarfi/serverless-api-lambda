import json
from methods import *



getMethod = "GET"
postMethod = "POST"
deleteMethod = "DELETE"
updateMethod = "PUT"

bookPath = "/book"
booksPath = "/books"

tableName = "Books" # DynamoDB table name





def lambda_handler(event, context):

    httpMethod = event["httpMethod"]
    path = event["path"]    
    
    # path == "/books" 
    # GET all books
    if path == booksPath and httpMethod == getMethod:
        response = get_all_items(table_name= tableName)

    # path == "/book" 
    elif path == bookPath and httpMethod == postMethod:
        # CREATE item
        requestBody = json.loads(event["body"])
        response = post_item(table_name= tableName, item= requestBody)

        # READ item
    elif path == bookPath and httpMethod == getMethod:
        """
        Query parameter e.g.    book?book_id=1
        """
        query_param = event["queryStringParameters"]
        book_id = query_param["book_id"]
        response = get_item(table_name= tableName, key={"book_id": book_id})

    # UPDATE item
    elif path == bookPath and httpMethod == updateMethod:
        """
        Request body example
            {
            "book_id": "1",
            "attribute": "Author",
            "value": "Joe Cole"
            }       
        """
        requestBody = json.loads(event["body"])
        book_id = requestBody["book_id"]
        response = update_item(
            table_name= tableName, 
            key= {"book_id": book_id},
            attribute= requestBody["attribute"],
            value= requestBody["value"]
        )


    # DELETE item
    elif path == bookPath and httpMethod == deleteMethod:
        """
        Request body example
            {
            "book_id": "1",
            }
        """
        requestBody = json.loads(event["body"])
        book_id = requestBody["book_id"]
        response = delete_item(table_name= tableName, key={"book_id": book_id})

    else:
        response = returnResponse(statusCode=404, body={"message": "ERROR 404"})

    return response
            


