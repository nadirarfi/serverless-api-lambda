terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

variable "accountId" {
  description = "My personal account ID"
  type = string

}

variable "tag" {
  description = "My personal tag to group resources"
  type = string

}

variable "region" {
  description = "My current region"
  type = string

}

# Configure the AWS Provider
provider "aws" {
  shared_config_files      = ["C:/Users/arfin/.aws/config"]
  shared_credentials_files = ["C:/Users/arfin/.aws/credentials"]
  region = var.region
}


        


# Configure IAM Role for lambda function
resource "aws_iam_role" "lambda-role" {
  name = "lambda-role"
  assume_role_policy = file("./iam_role/lambda_assume_role.json")
  tags = {
    Name = var.tag
  }
}

# Configure IAM Role Policy to provide access to DynamoDB and CloudWatch Logs
resource "aws_iam_role_policy" "lambda-role-policy" {
  name = "lambda-role-policy"
  role = aws_iam_role.lambda-role.id
  policy = file("./iam_role/lambda_policy.json")

}

# Create a Log group for CloudWatch
resource "aws_cloudwatch_log_group" "lambda-api-log-group" {
  name = "lambda-api-log-group"

  tags = {
    Name = var.tag

  }
}

resource "aws_dynamodb_table" "Books" {
  name             = "Books" # Make sure to keep the same name resource as in the lambda policy
  hash_key         = "book_id"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  attribute {
    name = "book_id"
    type = "S"
  }
}


####################################### Additional

resource "aws_api_gateway_rest_api" "myRestAPI" {
  name        = "myRestAPI"
  description = "Books API Gateway"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


# Books API Resource
resource "aws_api_gateway_resource" "books_resource" {
  rest_api_id = aws_api_gateway_rest_api.myRestAPI.id
  parent_id   = aws_api_gateway_rest_api.myRestAPI.root_resource_id
  path_part   = "books"
}

# Book API Resource
resource "aws_api_gateway_resource" "book_resource" {
  rest_api_id = aws_api_gateway_rest_api.myRestAPI.id
  parent_id   = aws_api_gateway_rest_api.myRestAPI.root_resource_id
  path_part   = "book"
}


#############################################################################################
#############################################################################################
# Define GET method for "/book" + Integration 
resource "aws_api_gateway_method" "get-all-books" {
  rest_api_id   = aws_api_gateway_rest_api.myRestAPI.id # ID of the rest API gateway
  resource_id   = aws_api_gateway_resource.books_resource.id # ID of the created resource books
  http_method   = "GET"
  authorization = "None"
}

resource "aws_api_gateway_integration" "myRestAPI-get-all-books" {
  rest_api_id             = aws_api_gateway_rest_api.myRestAPI.id
  resource_id             = aws_api_gateway_resource.books_resource.id # ID of the created resource books
  http_method             = aws_api_gateway_method.get-all-books.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.myLambdaFunction.invoke_arn

}

#############################################################################################
resource "aws_api_gateway_method" "get-book" {
  rest_api_id   = aws_api_gateway_rest_api.myRestAPI.id # ID of the rest API gateway
  resource_id   = aws_api_gateway_resource.book_resource.id # ID of the created resource books
  http_method   = "GET"
  authorization = "None"
}

resource "aws_api_gateway_integration" "myRestAPI-get-book" {
  rest_api_id             = aws_api_gateway_rest_api.myRestAPI.id
  resource_id             = aws_api_gateway_resource.book_resource.id # ID of the created resource books
  http_method             = aws_api_gateway_method.get-book.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.myLambdaFunction.invoke_arn

}


#############################################################################################
resource "aws_api_gateway_method" "delete-book" {
  rest_api_id   = aws_api_gateway_rest_api.myRestAPI.id # ID of the rest API gateway
  resource_id   = aws_api_gateway_resource.book_resource.id # ID of the created resource books
  http_method   = "DELETE"
  authorization = "None"
}

resource "aws_api_gateway_integration" "myRestAPI-delete-book" {
  rest_api_id             = aws_api_gateway_rest_api.myRestAPI.id
  resource_id             = aws_api_gateway_resource.book_resource.id # ID of the created resource books
  http_method             = aws_api_gateway_method.delete-book.http_method
  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.myLambdaFunction.invoke_arn

}

#############################################################################################
resource "aws_api_gateway_method" "post-book" {
  rest_api_id   = aws_api_gateway_rest_api.myRestAPI.id # ID of the rest API gateway
  resource_id   = aws_api_gateway_resource.book_resource.id # ID of the created resource books
  http_method   = "POST"
  authorization = "None"
}

resource "aws_api_gateway_integration" "myRestAPI-post-book" {
  rest_api_id             = aws_api_gateway_rest_api.myRestAPI.id
  resource_id             = aws_api_gateway_resource.book_resource.id # ID of the created resource books
  http_method             = aws_api_gateway_method.post-book.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.myLambdaFunction.invoke_arn

}

#############################################################################################
resource "aws_api_gateway_method" "put-book" {
  rest_api_id   = aws_api_gateway_rest_api.myRestAPI.id # ID of the rest API gateway
  resource_id   = aws_api_gateway_resource.book_resource.id # ID of the created resource books
  http_method   = "PUT"
  authorization = "None"
}

resource "aws_api_gateway_integration" "myRestAPI-put-book" {
  rest_api_id             = aws_api_gateway_rest_api.myRestAPI.id
  resource_id             = aws_api_gateway_resource.book_resource.id # ID of the created resource books
  http_method             = aws_api_gateway_method.put-book.http_method
  integration_http_method = "PUT"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.myLambdaFunction.invoke_arn

}
#############################################################################################

resource "aws_api_gateway_deployment" "api-deployment" {
  rest_api_id = aws_api_gateway_rest_api.myRestAPI.id
  stage_name  = "prod"
}


