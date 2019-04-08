# sumologic-gsuitealertcenter
Solution to pull alerts from G Suite Alert Center to Sumo Logic


## Installation

This collector can be deployed both onprem and on cloud(google cloud functions).
For installing the collector as a serverless solution refer these [docs](https://help.sumologic.com/07Sumo-Logic-Apps/06Google/G_Suite/01Collect-Logs-for-G-Suite/02Configure_Collection_for_G_Suite_Alert_Center) 

### Deploying the collector on a VM
 
1. Setup the Alert Center API by referring to the following [docs](https://developers.google.com/admin-sdk/alertcenter/guides/prerequisites). Here while creating key in service account make a note of the location of Service Account JSON file that has been downloaded in your computer you will need it later.

2. Add a Hosted Collector and HTTP Source

    * To create a new Sumo Logic Hosted Collector, perform the steps in [Configure a Hosted Collector](https://help.sumologic.com/03Send-Data/Hosted-Collectors/Configure-a-Hosted-Collector).
    * Add an [HTTP Logs and Metrics Source](https://help.sumologic.com/03Send-Data/Sources/02Sources-for-Hosted-Collectors/HTTP-Source). Under Advanced you'll see options regarding timestamps and time zones and when you select Timestamp parsing specify the custom time stamp format as shown below: 
      - Format: `yyyy-MM-dd'T'HH:mm:ss.SSS'Z'` 
      - Timestamp locator: `\"createTime\": (.*),`.
    
3. Configuring the **sumologic-gsuitealertcenter** collector
    
    Below instructions assume pip is already installed if not then, see the pip [docs](https://pip.pypa.io/en/stable/installing/) on how to download and install pip.
    *sumologic-gsuitealertcenter* is compatible with python 3.7 and python 2.7. It has been tested on Ubuntu 18.04 LTS and Debian 4.9.130.
    Login to a Linux machine and download and follow the below steps:

    * Install the collector using below command
      ``` pip install sumologic-gsuitealertcenter```

    * Create a configuration file named gsuitealertcenter.yaml in home directory by copying the below snippet.
      Add the SUMO_ENDPOINT, CREDENTIALS_FILEPATH(downloaded in step 1) and DELEGATED_EMAIL parameters obtained from step 1 and step 2 and save it.

      ```
      SumoLogic:
        SUMO_ENDPOINT: <SUMO LOGIC HTTP URL>
        
      GsuiteAlertCenter:
        DELEGATED_EMAIL: "<use the default email address>"
        CREDENTIALS_FILEPATH: "<path to json Service Accouont JSON file>"
        
      Collection:
        ENVIRONMENT: onprem

      ```
    * Create a cron job  for running the collector every 5 minutes by using the crontab -e and adding the below line
        `*/5 * * * *  /usr/bin/python -m sumogsuitealertscollector.main > /dev/null 2>&1`
