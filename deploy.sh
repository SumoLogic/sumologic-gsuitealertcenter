#!/usr/bin/env bash

# For supported regions refer https://cloud.google.com/functions/docs/locations
region="us-central1"
project_id="<your project id>"
delegated_email="<delegated email>"
sumo_endpoint="<sumologic endpoint>"

#Functions in a given region in a given project must have unique (case insensitive) names
funcname="sumogsuitealertcenterfunc"
function_memory="256MB"
function_timeout="300s"

# job name should be unique in a project
job_name="$funcname""-""$region""-job"
service_account="sumogsuitealertcenteraccount"


create_service_account() {

    echo "creating service account..."
    gcloud iam service-accounts create $service_account --display-name "Sumo Gsuite Alert Center Collector"

    service_account_email="$service_account@$project_id.iam.gserviceaccount.com"
    echo "service account email $service_account_email"

    echo "assigning datastore owner role..."
    gcloud projects add-iam-policy-binding "$project_id" --member="serviceAccount:$service_account_email" --role="roles/datastore.owner"
}

deploy_functions() {

    echo "removing old files..."
    rm sumogsuitealertscollector.zip
    rm -r sumogsuitealertscollector/

    echo "downloading zip..."
    wget https://s3.amazonaws.com/appdev-cloudformation-templates/sumogsuitealertscollector.zip && unzip sumogsuitealertscollector.zip -d sumogsuitealertscollector/

    # creating access keys and downloading
    filename="service_account_credentials.json"
    gcloud iam service-accounts keys create "sumogsuitealertscollector/$filename" --iam-account "$service_account_email"

    # for more options refer - https://cloud.google.com/sdk/gcloud/reference/beta/functions/deploy#--source
    echo "deploying and configuring environement variables"
    gcloud beta functions deploy "$funcname" --entry-point main --trigger-http --memory="$function_memory" --timeout="$function_timeout" --service-account="$service_account_email" \
        --region="$region" --runtime=python37 --source=sumogsuitealertscollector/ --set-env-vars DELEGATED_EMAIL="$delegated_email",SUMO_ENDPOINT="$sumo_endpoint",CREDENTIALS_FILEPATH="$filename"

    # updating env variables
    # gcloud functions deploy "$funcname" --update-env-vars DELEGATED_EMAIL=$delegated_email,SUMO_ENDPOINT=$sumo_endpoint,CREDENTIALS_FILEPATH=$credentials_path
}

create_job() {

    uri="https://$region-$project_id.cloudfunctions.net/$funcname"
    cron_frequency="*/5 * * * *"

    # Cloud Scheduler is currently available in all App Engine supported regions. To use Cloud Scheduler your project must contain an App Engine app that is located in one of the supported regions.
    # for more option refer - https://cloud.google.com/sdk/gcloud/reference/beta/scheduler/jobs/create/http
    echo "creating cloud scheduler with jobname: $job_name frequency: $cron_frequency with function uri: $uri"
    gcloud services enable cloudscheduler.googleapis.com
    gcloud beta scheduler jobs create http "$job_name" --description="Job for triggering $funcname google cloud function" --uri="$uri" --schedule="$cron_frequency"

}

delete_job() {

    echo "Deleting $job_name"
    gcloud beta scheduler jobs delete $job_name
}

delete_service_account() {

    service_account_email="$service_account@$project_id.iam.gserviceaccount.com"
    echo "Deleting $service_account_email"
    gcloud iam service-accounts delete $service_account_email
}

delete_functions() {

    echo "Deleting function"
    gcloud beta functions delete "$funcname" --region=$region
}

create_resources() {

    echo "Starting Deployment..."

    create_service_account
    deploy_functions
    create_job

    echo "enabling alert center api..."
    gcloud services enable alertcenter.googleapis.com

    # authorize gsuite - manual step
    echo "go to https://admin.google.com and authorize below client id"
    cat "sumogsuitealertscollector/$filename" | grep "client_id"

}

destroy_resources() {

    echo "Destroying resources"

    delete_job
    delete_functions
    delete_service_account

    echo "Disabling alert center api..."
    gcloud services disable alertcenter.googleapis.com

}

# use gcloud projects list for listing projects
echo "setting up project: $project_id for current session..."
gcloud config set project "$project_id"

create_resources
#destroy_resources