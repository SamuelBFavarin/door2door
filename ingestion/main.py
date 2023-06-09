from google.cloud import storage
from google.cloud import bigquery
from google.cloud.exceptions import NotFound, Conflict
from flask import Request, Response
from datetime import datetime
from typing import List, Tuple
import os
import json


# GET ENV VARS
bucket_name = os.environ["BUCKET_NAME"]
dataset_name = os.environ["DATASET_NAME"]
table_name = os.environ["TABLE_NAME"]
project_id = os.environ["PROJECT_ID"]

# DEFINE CLIENTS
storage_client = storage.Client(project=project_id)
bq_client = bigquery.Client(project=project_id)


def get_json_data(bucket_name:str, filter_date:str, full_load:str = False) -> List[str]:

    bucket = storage_client.bucket(bucket_name)
    blobs_list = []
    json_data = []

    if full_load:
        blobs_list = bucket.list_blobs()

    else:
        blobs_list = bucket.list_blobs(prefix=filter_date)
    
    for blob in blobs_list:
        json_str = blob.download_as_string().decode()
        json_list = json_str.split('\n')
        json_data += [json.loads(json_obj) for json_obj in json_list if json_obj.strip()]

    return json_data

def generate_api_events_table_schema() -> List[bigquery.SchemaField]:
    return [
        bigquery.SchemaField("event", "STRING"),
        bigquery.SchemaField("on", "STRING"),
        bigquery.SchemaField("at", "TIMESTAMP"),
        bigquery.SchemaField("data", "RECORD", mode="NULLABLE",
            fields=[
                bigquery.SchemaField("id", "STRING", mode="NULLABLE"),
                bigquery.SchemaField("start", "TIMESTAMP", mode="NULLABLE"),
                bigquery.SchemaField("finish", "TIMESTAMP", mode="NULLABLE"),
                bigquery.SchemaField("location", "RECORD", mode="NULLABLE",
                    fields=[
                            bigquery.SchemaField("lat", "FLOAT", mode="NULLABLE"),
                            bigquery.SchemaField("lng", "FLOAT", mode="NULLABLE"),
                            bigquery.SchemaField("at", "TIMESTAMP", mode="NULLABLE"),
                    ],
                ),
            ],
        ),
        bigquery.SchemaField("organization_id", "STRING"),
    ]

def create_and_get_table(dataset_name:str, table_name:str, schema:List[bigquery.SchemaField]) -> bigquery.Table | None:
    
    table_ref = bq_client.dataset(dataset_name).table(table_name)
    try:
        table = bigquery.Table(table_ref, schema=schema)
        table = bq_client.create_table(table)
        print(f'Table {table_ref} created')
        return table
    except NotFound:
        print(f'Dataset {dataset_name} does not exist')
        return None
    except Conflict:
        print(f'Table {table_ref} already exists')
        table = bq_client.get_table(table_ref)
        return table

    return None



def insert_data(data:List[str], dataset_name:str, table_name:str) -> Tuple[bool, List[str]]:

    schema = generate_api_events_table_schema()

    table = create_and_get_table(dataset_name, table_name, schema)
    rows_to_insert = [tuple(json_obj.values()) for json_obj in data]
    errors = bq_client.insert_rows(table, rows_to_insert)

    return (len(errors) == 0, errors)


def main(request: Request) -> Response:

    # GET REQUESTS
    request_json = request.get_json() if request else []
    filter_date = request_json['filter_date'] if 'filter_date' in request_json else datetime.now().strftime('%Y-%m-%d')
    full_load = request_json['full_load'] if 'full_load' in request_json else False

    print('filter_date', filter_date, 'full_load', full_load)

    list_json_data = get_json_data(bucket_name, filter_date, full_load)

    if len(list_json_data) > 0:
        response, errors = insert_data(list_json_data, dataset_name, table_name)
        
        if response:
            print(f'Loaded row(s) into {dataset_name}.{table_name} table.')
            return Response(status=200)
        else:
            print(f'Encountered errors while inserting rows: {errors}')
            return Response(status=400)
    
    else:
        print(f'No found row(s) to load into {dataset_name}.{table_name} table.')
        return Response(status=404)


if __name__ == "__main__":
    main(None)