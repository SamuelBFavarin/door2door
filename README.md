# door2door
Door2Door is a data pipeline that ingests GPS sensor data from vehicles, and creates various data models following a bronze/silver/gold data warehouse structure. The pipeline provides useful insights, such as the average distance traveled by vehicles during a specific operating period.

The project uses Python for the API ingestion step and dbt for data quality checks and transformations. The entire project is hosted on Google Cloud Platform (GCP) and leverages various GCP technologies, including:

- Cloud Functions, which execute the Python ingestion process
- Cloud Storage, which stores raw data and hosts dbt documentation
- BigQuery, which serves as the data warehouse
- Cloud Build, which executes the dbt Docker and runs the transformation and quality checks
- Cloud Scheduler, which serves as the orchestrator

## How to run

To run the Door2Door project locally, follow these steps:

- Include the Service Account Credentials in the /credentials folder.
- Use the Makefile to run the necessary dbt steps.
- To execute the ingestion process, run `make ingestion`. By default, this command ingests all data from the previous day.



## Data Warehouse Documentation 
https://storage.googleapis.com/door-2-door-dbt-doc/target/index.html#!/overview
