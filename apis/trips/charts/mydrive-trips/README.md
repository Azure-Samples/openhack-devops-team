# My Driving Trips API

## Description

This installs the application on a Kubernetes cluster with the following components:

1. A Service to allow public ingress on Port 80
2. Creates a deployment that manages 2 pods (or more!)

## Installation instructions

1. Install Kubernetes Helm (any method is fine!) https://github.com/kubernetes/helm/blob/master/docs/install.md

2. Make sure tiller (the server side component to Helm) is up to date:
```helm init --upgrade```

3. Make any changes you'd like to the `charts/mydrive-trips/values.yaml` fil. If you change the image tag, make sure the image exists on ACR or docker hub.

4. Run the following commands in a terminal window in the `charts/mydrive-trips/` folder.

```bash

helm install . -f values.yaml

```
