#!/bin/bash

cd ~/
git clone "${TEAM_REPO}" --branch "${TEAM_REPO_BRANCH}" ~/openhack

cd ~/openhack/support/simulator
az acr build --image devopsoh/simulator:latest --registry "${CONTAINER_REGISTRY}" --file Dockerfile . 2>&1 | tee "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/simulator.txt"

cd ~/openhack/support/tripviewer
az acr build --image devopsoh/tripviewer:latest --registry ${CONTAINER_REGISTRY} --file Dockerfile . 2>&1 | tee "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/tripviewer.txt"

cd ~/openhack/apis/poi/web
az acr build --image devopsoh/api-poi:${BASE_IMAGE_TAG} --registry ${CONTAINER_REGISTRY} --build-arg build_version=${BASE_IMAGE_TAG} --file Dockerfile . 2>&1 | tee "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/poi.txt"

cd ~/openhack/apis/trips
az acr build --image devopsoh/api-trips:${BASE_IMAGE_TAG} --registry ${CONTAINER_REGISTRY} --build-arg build_version=${BASE_IMAGE_TAG} --file Dockerfile . 2>&1 | tee "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/trips.txt"

cd ~/openhack/apis/user-java
az acr build --image devopsoh/api-user-java:${BASE_IMAGE_TAG} --registry ${CONTAINER_REGISTRY} --build-arg build_version=${BASE_IMAGE_TAG} --file Dockerfile . 2>&1 | tee "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/userjava.txt"

cd ~/openhack/apis/userprofile
az acr build --image devopsoh/api-userprofile:${BASE_IMAGE_TAG} --registry ${CONTAINER_REGISTRY} --build-arg build_version=${BASE_IMAGE_TAG} --file Dockerfile . > "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/userprofile.txt"