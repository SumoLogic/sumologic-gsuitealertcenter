#!/usr/bin/env bash

funcname="sumogsuitealertcenterfunc"
region="us-central1"
project_id="<your project id>"
delegated_email="<delegated email>"
sumo_endpoint="<sumologic endpoint>"
function_memory="256MB"
function_timeout="300s"

echo "Starting Deployment..."

# use gcloud projects list for listing projects
echo "setting up project: $project_id for current session..."
gcloud config set project "$project_id"

echo "creating service account..."
gcloud iam service-accounts create sumogsuitealertcenterfunc --display-name "Sumo Gsuite Alert Center Collector"

service_account_email="$funcname@$project_id.iam.gserviceaccount.com"
echo "service account email $service_account_email"

echo "assigning datastore owner role..."
gcloud projects add-iam-policy-binding "$project_id" --member="serviceAccount:$service_account_email" --role="roles/datastore.owner"

echo "enabling alert center api..."
gcloud services enable alertcenter.googleapis.com

echo "removing old files..."
rm sumogsuitealertscollector.zip
rm -r sumogsuitealertscollector/

echo "downloading zip..."
wget https://s3.amazonaws.com/appdev-cloudformation-templates/sumogsuitealertscollector.zip && unzip sumogsuitealertscollector.zip -d sumogsuitealertscollector/

# creating access keys and downloading
filename="service_account_credentials.json"
gcloud iam service-accounts keys create "sumogsuitealertscollector/$filename" --iam-account "$service_account_email"

# for more options refer - https://cloud.google.com/sdk/gcloud/reference/beta/functions/deploy#--source
echo "deploying function and setting environement variables"
gcloud beta functions deploy "$funcname" --entry-point main --trigger-http --memory="$function_memory" --timeout="$function_timeout" --service-account="$service_account_email" \
    --region="$region" --runtime=python37 --source=sumogsuitealertscollector/ --set-env-vars DELEGATED_EMAIL="$delegated_email",SUMO_ENDPOINT="$sumo_endpoint",CREDENTIALS_FILEPATH="$filename"

# updating env variables
# gcloud functions deploy "$funcname" --update-env-vars DELEGATED_EMAIL=$delegated_email,SUMO_ENDPOINT=$sumo_endpoint,CREDENTIALS_FILEPATH=$credentials_path

job_name=$funcname"_job"
uri="https://$region-$project_id.cloudfunctions.net/$funcname"
cron_frequency="*/5 * * * *"

# for more option refer - https://cloud.google.com/sdk/gcloud/reference/beta/scheduler/jobs/create/http
echo "creating cloud scheduler with jobname: $job_name frequency: $cron_frequency with function uri: $uri"
gcloud services enable cloudscheduler.googleapis.com
gcloud beta scheduler jobs create http "$job_name" --description="Job for triggering $funcname google cloud function" --uri="$uri" --schedule="$cron_frequency"

# authorize gsuite - manual step
echo "go to https://admin.google.com and authorize below client id"
cat "sumogsuitealertscollector/$filename" | grep "client_id"

