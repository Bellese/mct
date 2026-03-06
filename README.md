# MCT

Measure Calculation Tool for reporting and calculating FHIR-based digital quality measures (dQMs).

## Status and Limitations

This tool is a prototype which we are releasing in the hope that it serves as a useful starting point for further development by interested parties. It currently lacks important features, such as including authentication, and allows for the client to make arbitrary changes to the report before submission. **It is not suitable or intended for production use in its current state.**

## Maintenance

This is a meritocratic, consensus-based community project. Anyone with interest in the project can join the community, contribute to the project design and participate in the decision making process. Participation in these processes is completely voluntary. This document describes how that participation takes place and how to set about earning merit within the project community.

Although these processes are adapted from the OSSWatch Meritocratic Model, this documentation is a formalization of existing processes involving relevant stakeholders.

## Getting started

This getting started guide provides the pre-requisites and steps needed to get the MCT running locally. As always, feedback and contributions are welcome!

For more information on the MCT, please visit the [MCT Implementation Guide](https://build.fhir.org/ig/cqframework/mct-ig/).

For feedback and questions please submit an issue to this repository or on the [Zulip forum](https://chat.fhir.org/#narrow/stream/401023-mct) (requires an account and subscription to the mct stream).

### Pre-requisites

- Docker is required
- At least 8 GB RAM is required
  - If running Docker through a virtual machine (e.g. using Docker Desktop or Colima), ensure the this RAM is allocated to the virtual machine.

### Steps

1. Open a terminal and navigate to the 'docker' directory from the root (e.g. `cd docker`)
1. Standup services with `docker compose up --build`
    - Once the build is complete, 4 images will be running:
       - the frontend (`localhost:3000`)
       - the backend (`localhost:8088`)
       - 2 HAPI FHIR servers which serve as the facilities:
          - `localhost:8080/fhir`
          - `localhost:8082/fhir`
1. Load data with `./bin/load_local_data.sh` or use a HTTP client like Postman to load the patient test data bundles
    - The bundles can be found here: `java/src/main/resources/configuration/test-bundles`.
    - POST the `facility-a-bundle.json` to localhost:8080/fhir
    - POST the `facility-b-bundle.json` to localhost:8082/fhir
1. Navigate to the frontend UI at `http://localhost:3000`
1. Select the organization for testing
    - There are currently 2 organizations to test the current use-cases; single-facility and multiple-facility
1. Select the measure - there is currently only 1 registered with the service
1. Select the facility/facilities you'd like to test, which will populate the patient list
1. Select the patients you would like to include in the report
1. Select the date range (or measurement period) - NOTE that the current test only works with Q1
1. Select the Get Report button - the current performance is ~1 sec per patient (so ~100 sec for the single-facility and ~200 sec for the multiple-facility).

### API Documentation
This project uses HAPI FHIR's OpenAPI implementation to expose interactive API documentation via Swagger UI.

#### Accessing Swagger UI
Once the stack is running, navigate to:
```text
http://localhost:8088/mct/swagger-ui/
```
The raw OpenAPI 3.0 specification is available at:
```text
http://localhost:8088/mct/api-docs
```