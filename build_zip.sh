#!/usr/bin/env bash

# this assumes that one has AWS_PROFILE env set and credentials present in ~/.aws/credentials
rm -r build/ dist/ sumologic_gsuitealertcenter.egg-info/
rm -r sumogsuitealertscollector/__pycache__/  sumogsuitealertscollector/sumoclient/__pycache__/ sumogsuitealertscollector/common/__pycache__/ sumogsuitealertscollector/omnistorage/__pycache__/
rm sumogsuitealertscollector/*.pyc sumogsuitealertscollector/sumoclient/*.pyc sumogsuitealertscollector/common/*.pyc sumogsuitealertscollector/omnistorage/*.pyc
rm sumogsuitealertscollector/omnistorage/*.db sumogsuitealertscollector/omnistorage/gsuitealertcenter
rm sumogsuitealertscollector.zip
cp requirements.txt sumogsuitealertscollector/
cd sumogsuitealertscollector/
zip -r ../sumogsuitealertscollector.zip .
rm requirements.txt
cd ..

aws s3 cp sumogsuitealertscollector.zip s3://appdev-cloudformation-templates/sumogsuitealertscollector.zip --acl public-read
aws s3 cp deploy.sh s3://appdev-cloudformation-templates/sumo_gsuite_alerts_collector_deploy.sh --acl public-read