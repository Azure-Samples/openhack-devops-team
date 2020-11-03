[![Board Status](https://dev.azure.com/brvuong0311/0541fa3c-2ce4-4f52-a1bf-350645409731/e5f4e8e9-0827-41f5-ada3-aa116e33b626/_apis/work/boardbadge/2e86ac60-f12b-4df6-8c19-145056805288)](https://dev.azure.com/brvuong0311/0541fa3c-2ce4-4f52-a1bf-350645409731/_boards/board/t/e5f4e8e9-0827-41f5-ada3-aa116e33b626/Microsoft.RequirementCategory)
# Project Name (bv)

The DevOps open hack event is designed to foster learning via implementing DevOps practices with a series of challenges.

## Architecture

The application used for this event is a heavily modified and recreated version of the original [My Driving application](https://github.com/Azure-Samples/MyDriving).

The team environment consists of the following:

* Azure Kubernetes Service (AKS) cluster which has four APIs deployed:

  * POI (Trip Points of Interest) - CRUD API written in .Net Core 2 for points of interest on trips
  * Trips - CRUD open API written in golang 1.11 for trips connected to the client application
  * UserProfile - CRUD open API written in Node.JS for the users of the client application
    > Note:PATCH/POST operations not functional
  * User-Java - API written in Java with POST and PATCH routes plus swagger docs routes for the users of the client application.
* Mobile Apps - for iOS and Android which will display driving trip data

## Getting Started

To understand each of the components above in more detail, please visit the readme files inside the root folder of each corresponding part of the application.

### Prerequisites

It is useful but not required to have a basic knowledge of the following topics:

* Kubernetes
* Azure DevOps (formally VSTS) or Jenkins

## Resources

The provisioning of this environment for proctors can be found in the [DevOps Openhack Proctor](https://github.com/Azure-Samples/openhack-devops-proctor) Github repository.
