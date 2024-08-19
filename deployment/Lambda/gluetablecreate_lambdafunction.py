import boto3
import pyodata
import traceback
import re
import json
import os
import requests
from os import path
from botocore.exceptions import ClientError

aws_region = os.getenv('AWS_REGION')

glue_client = boto3.client("glue", region_name=aws_region)

# SAP Secret Parameters
secret_name = os.environ['secretname']
SAP_PROTO='https'
SAP_SERVICE_PATH='/sap/opu/odata/sap/'

def getSAPSecret(secretnameinput):
    # Create a Secrets Manager client
    secret_client = boto3.client('secretsmanager', region_name=aws_region)
    try:
        get_secret_value_response = secret_client.get_secret_value(
            SecretId=secretnameinput
        )
        text_secret_data = json.loads(get_secret_value_response['SecretString'])

    except Exception as e:
            print(f"An error occurred: {str(e)}.")
    return text_secret_data

def getODataClient(sapservice):
    SAP_SECRET={
    'user': sapuser,
    'password': password
    }
    
    try:
        serviceuri = (
            SAP_PROTO
            + "://"
            + sapurl
            + ":"
            + sapport
            + SAP_SERVICE_PATH
            + sapservice
        )

        print("service call:" + serviceuri)
        sapauth = SAP_SECRET
        session = requests.Session()
        session.auth = (sapauth["user"], sapauth["password"])
        timeout_value = 60
        response = session.head(serviceuri, headers={"x-csrf-token": "fetch"}, timeout=timeout_value)
        token = response.headers.get("x-csrf-token", "")
        session.headers.update({"x-csrf-token": token})

        oDataClient = pyodata.Client(serviceuri, session)
        return oDataClient
    except Exception as e:
        traceback.print_exc()
        return e


def get_sap_columns_from_metadata(servicename: str):
    oDataclient = getODataClient(sapservice=servicename)
    for es in oDataclient.schema.entity_sets:
        if es.name.startswith("TextsOf") or es.name.startswith("FactsOf") or es.name.startswith("AttrOf"):
            properties = oDataclient.schema.entity_type(es.name).proprties()
            entityname = es.name

    results = []

    for prop in properties:
        label = re.sub(r"[^a-zA-Z0-9\s]", "", prop.label)
        results.append(
            {
                "entityName": entityname,
                "propertyName": prop.name,
                "label": re.sub(r"\s", "_", label),
                "type": prop.type_info.name,
                "maxLength": prop.max_length,
                "precision": prop.precision,
                "scale": prop.scale,
            }
        )
        
    return results

# Function to map JSON types to Glue types
def map_json_type_to_glue(json_type):
    # Mapping of Edm types to Glue types
    type_mapping = {
        "Edm.String": "string",
        "Edm.Decimal": "double",
        "Edm.Boolean": "boolean",
        "Edm.Byte": "byte",
        "Edm.DateTime": "string",
        "Edm.Time": "string",
        "Edm.Double": "double",
        "Edm.Guid": "string",
        "Edm.Int16": "double",
        "Edm.Int32": "double",
        "Edm.Int64": "double",
        "Edm.Single": "double",
        "Edm.Binary": "double",
    }
    # If the JSON type is not found in the mapping, default to VARCHAR
    return type_mapping.get(json_type, "string")

def generate_table_columns(servicename: str):
    sapcolumns = get_sap_columns_from_metadata(servicename=servicename)
    table_name = 'your_table_name'

    table_columns= []
#    table_columns= [
#    {'Name': 'column1', 'Type': 'string',  'Comment': 'string'},
#    {'Name': 'column2', 'Type': 'int'},
#    {'Name': 'column3', 'Type': 'double'},
#    ]
    column_names = {}  # Dictionary to track column names and their occurrence counts
    for column_data in sapcolumns:
        original_column_name = column_data["propertyName"].lower()
        if column_data["propertyName"].startswith("ODQ"):
            original_column_name = column_data["propertyName"].lower()

        column_name = original_column_name

        # If the column name already exists, append an incremental counter
        if column_name in column_names:
            counter = column_names[column_name]
            column_name = (
                f"{original_column_name}_{column_data['propertyName'].lower()}"
            )
            column_names[original_column_name] += 1
        else:
            column_names[original_column_name] = 1
        json_type = column_data["type"]
        glue_type = map_json_type_to_glue(json_type)
        description = column_data["label"]

        table_dict = {
        'Name': f"{column_name}",
        'Type': f"{glue_type}",
        'Comment': f"{description}",
        }
        table_columns.append(table_dict)
    #add timestamp field
    table_dict = {
    'Name': f"loadts",
    'Type': f"timestamp",
    'Comment': f"Load Timestamp",
    }
    table_columns.append(table_dict)
    #add record counter field
    table_dict = {
    'Name': f"counter",
    'Type': f"int",
    'Comment': f"Record Counter",
    }
    table_columns.append(table_dict)    

    return table_columns
    

def create_glue_table(servicename: str):
    table_details = generate_table_columns(servicename=servicename)

    try:
        table_response = glue_client.create_table(
            DatabaseName=database_name,
            TableInput={
                'Name': table_name,
                'Description': table_name,
                'StorageDescriptor': {
                    'Columns': table_details,
                    'Location': table_location,
                },
                'TableType': 'EXTERNAL_TABLE'
            },
            OpenTableFormatInput={
                'IcebergInput': {
                    'MetadataOperation': 'CREATE'
                }
            }
        )
        print(f"Created table: {str(table_name)}")
    except Exception as e:
        print(f"Error creating Glue table: {str(e)}")

def lambda_handler(event, context):
    global table_name
    global database_name
    global table_location
    global sapurl
    global sapport
    global sapuser
    global password

    #Retrive SAP connection value
    sap_secret_value = getSAPSecret(secretnameinput=secret_name)
    sapurl = sap_secret_value['sapurl']
    sapport = sap_secret_value['port']
    sapuser = sap_secret_value['username']
    password = sap_secret_value['password']

    bucket = os.environ.get('BucketConfig')
    object_key = os.environ.get('FileNameConfig')
    # Retrieve flow definition from S3
    s3 = boto3.client('s3')
    configs3 = s3.get_object(Bucket=bucket, Key=object_key)
    configdata = json.loads(configs3['Body'].read().decode('utf-8'))
    datasources = configdata["datasources"]
    
    for source in datasources:
        table_name = source["table_name"]
        database_name = source["database_name"]
        table_location = source["s3_path"]
        create_glue_table(servicename=source["service"])
   
    print(f'Glue DDL executed successfully!')



