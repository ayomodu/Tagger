#!/bin/bash
set -eou pipefail
send_post_request(){
    case $DRONE_DEPLOY_TO in
    "")
        payload="{\"project_name\":\"$DRONE_REPO_NAME\", \"development_version\":\"$version\"}"
        curl --request POST \
        --url http://$PLUGIN_API_DOMAIN_NAME/api/add_project/ \
        --header 'accept: application/json' \
        --header 'Content-Type: application/json' \
        --data "$payload"
        ;;
    staging)
        payload="{\"project_name\":\"$DRONE_REPO_NAME\", \"staging_version\":\"$version\"}"
        curl --request POST \
        --url http://$PLUGIN_API_DOMAIN_NAME/api/add_project/ \
        --header 'accept: application/json' \
        --header 'Content-Type: application/json' \
        --data "$payload"
        ;;
    production)
        payload="{\"project_name\":\"$DRONE_REPO_NAME\", \"production_version\":\"$version\"}"
        curl --request POST \
        --url http://$PLUGIN_API_DOMAIN_NAME/api/add_project/ \
        --header 'accept: application/json' \
        --header 'Content-Type: application/json' \
        --data "$payload"
        ;;
    esac
}


get_semantic_version() {
    # Check if a file exists and read its contents
    if [[ -e "./$PLUGIN_PROJECT_NAME/$PLUGIN_PROJECT_NAME'.csproj" ]]; then
        version=$(awk -F "[><]" '/<Version>/{a=$3}END{print a}' ./$PLUGIN_PROJECT_NAME/$PLUGIN_PROJECT_NAME.csproj)
        echo "deploying for development"
        send_post_request
    elif [[ -e "package.json" ]]; then
        version=$(grep -oP '"version": "\K.*?(?=")' package.json)
        echo "deploying for staging"
        send_post_request
    elif [[ -e "pom.xml" ]]; then
        version=$(awk -F "[><]" '/<version>/{print $3;exit}' pom.xml)
        echo "deploying for production"
        send_post_request
    else
        echo "Error: could not find project configuration file"
        return 1
    fi

    # Check if the version matches the semantic versioning format
    if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$ ]]; then
        echo "$version"
    else
        echo "Error: version is not in semantic versioning format"
        return 1
    fi
}

get_semantic_version