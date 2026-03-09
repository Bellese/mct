# MCT (Measure Calculation Tool) — Technical Documentation

Measure Calculation Tool for reporting and calculating FHIR-based digital quality measures (dQMs) as defined in the HL7 healthcare data standards ecosystem. Users select organizations, facilities, patients, and measures, then execute a `$gather` operation that retrieves patient data from FHIR servers, evaluates CQL measures, validates against HL7 profiles, and returns population-level and individual-level MeasureReports.

**Status:** Prototype — not production-ready (no auth, client can modify reports before submission).
**License:** Apache-2.0

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Tech Stack](#tech-stack)
3. [Directory Structure](#directory-structure)
4. [Backend](#backend)
   - [Entry Point & Server Setup](#entry-point--server-setup)
   - [API Layer](#api-layer)
   - [Service Layer](#service-layer)
   - [Configuration](#configuration)
   - [Validation](#validation)
5. [Frontend](#frontend)
   - [State Management](#state-management)
   - [Pages & Components](#pages--components)
   - [Utility Functions](#utility-functions)
6. [Data Flow](#data-flow)
7. [FHIR Resources](#fhir-resources)
8. [Custom Extensions & Tags](#custom-extensions--tags)
9. [Docker & Deployment](#docker--deployment)
10. [CI/CD](#cicd)
11. [Infrastructure](#infrastructure)
12. [Testing](#testing)
13. [Dependencies](#dependencies)
14. [Developer Guide](#developer-guide)

---

## Architecture Overview

```
┌──────────────┐     ┌──────────────┐     ┌────────────────────┐
│   React SPA  │────▶│  Spring Boot │────▶│  Facility FHIR     │
│  (port 3000) │     │  (port 8088) │     │  Servers            │
└──────────────┘     │              │     │  (:8080, :8082)     │
                     │  /mct/*      │     └────────────────────┘
                     │              │
                     │  HAPI FHIR   │     ┌────────────────────┐
                     │  + CQL +     │────▶│  Terminology Server │
                     │  Clinical    │     │  tx.fhir.org/r4     │
                     │  Reasoning   │     └────────────────────┘
                     └──────────────┘
```

- **Frontend:** React 18 SPA with MUI v5, Redux Toolkit, React Router v6
- **Backend:** Spring Boot 3.2.5 (Java 17) running a HAPI FHIR RestfulServer at `/mct/*`
- **Facility Servers:** HAPI FHIR R4 servers simulating healthcare facilities
- **Configuration:** No database — measures, facilities, terminology, and receiving systems stored as FHIR Bundle JSON files on the classpath

---

## Tech Stack

| Layer          | Technology                                                                        |
|----------------|-----------------------------------------------------------------------------------|
| **Backend**    | Java 17, Spring Boot 3.2.5, HAPI FHIR 8.8.0, Clinical Reasoning 4.4.2           |
| **Frontend**   | React 18.2, MUI v5.11, Redux Toolkit 1.8.5, React Router v6.4, ApexCharts 3.35  |
| **Build**      | Maven + wrapper (backend), Yarn + Create React App (frontend)                     |
| **Infra**      | Docker Compose (local), Helm + Kubernetes on AWS EKS, Terraform                   |
| **CI/CD**      | Travis CI → AWS ECR → Helm deploy to EKS                                          |
| **Profiles**   | QI-Core 4.1.1, US Core 3.1.1                                                     |

---

## Directory Structure

```
mct/
├── bin/                            # Shell scripts (deploy, data loading, CI)
│   ├── deploy.sh                   # ECR push + Helm deploy to EKS
│   ├── install_ci_dependencies.sh
│   ├── load_local_data.sh          # POSTs test bundles to facility FHIR servers
│   └── setup_app_files.sh
├── docker/
│   ├── docker-compose.yml          # 4 services: frontend, backend, facility-a, facility-b
│   └── .env
├── frontend/                       # React SPA
│   ├── Dockerfile
│   ├── package.json                # npm name: "yale-mct"
│   └── src/
│       ├── App.js                  # Root: ThemeCustomization + ScrollTop + Routes
│       ├── config.js               # API base URLs, theme config
│       ├── index.js                # ReactDOM entry point
│       ├── components/             # Reusable UI (AlertDialog, MultiSelects, Loader, etc.)
│       ├── layout/MainLayout/      # App shell: sidebar drawer + header
│       ├── pages/dashboard/        # Population + Individual report views
│       ├── store/                  # Redux store + slices (data, filter)
│       ├── themes/                 # MUI theme customization
│       ├── utils/                  # measureReportHelpers, patientHelper, queryHelper
│       ├── routes/                 # React Router configuration
│       ├── constants/              # App constants
│       └── fixtures/               # Test data JSON
├── java/                           # Spring Boot backend
│   ├── Dockerfile
│   ├── pom.xml
│   ├── mvnw / mvnw.cmd
│   └── src/
│       ├── main/java/org/opencds/cqf/mct/
│       │   ├── MctApplication.java     # Entry point, servlet + CORS config
│       │   ├── SpringContext.java       # Static bean accessor
│       │   ├── api/                    # 7 HAPI FHIR operation providers
│       │   ├── config/                 # MctConfig, MctProperties, MctConstants
│       │   ├── service/                # 11 business logic services
│       │   ├── processor/              # CQL data requirements processing
│       │   └── validation/             # NPM package validation support
│       ├── main/resources/
│       │   ├── application.yaml        # Spring/HAPI config
│       │   └── configuration/
│       │       ├── facilities/         # facilities-bundle.json
│       │       ├── measures/           # measures-bundle.json
│       │       ├── receiving-system/   # receiving-system-bundle.json
│       │       ├── terminology/        # terminology-bundle.json
│       │       ├── patient-data-gen-libraries/  # CQL for test data generation
│       │       └── test-bundles/       # facility-a-bundle.json, facility-b-bundle.json
│       └── test/java/org/opencds/cqf/mct/
│           ├── GatherOperationTest.java
│           ├── FacilityRegistrationTest.java
│           ├── MeasureConfigurationTest.java
│           └── ReceivingSystemConfigurationTest.java
└── infrastructure/
    ├── kubernetes/                 # Helm chart "aphl-mct-k8s"
    │   ├── Chart.yaml
    │   ├── values.yaml
    │   └── templates/              # K8s manifests (frontend, backend, 2 FHIR servers, IG)
    └── terraform/                  # AWS EKS + VPC provisioning
        ├── main.tf
        ├── vpc.tf
        ├── providers.tf
        └── versions.tf
```

---

## Backend

### Entry Point & Server Setup

**`MctApplication.java`** — Spring Boot application class.

- Registers a HAPI FHIR `RestfulServer` as a servlet at `/mct/*`
- Configures CORS (allows all origins, methods: GET/POST/PUT/DELETE/OPTIONS/PATCH)
- Adds `OpenApiInterceptor` for Swagger UI at `/mct/swagger-ui/`
- Registers all 7 API provider classes

**`SpringContext.java`** — `ApplicationContextAware` component providing static access to Spring beans via `SpringContext.getBean(Class)`. Used by service classes that are instantiated with `new` rather than injected.

---

### API Layer

All endpoints use HAPI FHIR's `@Operation` annotation and are served under `/mct/*`.

#### `$gather` (POST) — `GatherAPI`

The core operation. Gathers patient data from facility FHIR servers, evaluates a CQL measure, validates resources, and returns reports.

**Parameters:**

| Name         | Type           | Required | Description                                              |
|--------------|----------------|----------|----------------------------------------------------------|
| `patients`   | Group          | Yes      | Group with member references (`Patient/{id}`)            |
| `facilities` | List\<String\> | Yes      | Facility IDs (`Location/{id}`)                           |
| `measure`    | String         | Yes      | Measure identifier (`Measure/{id}`)                      |
| `period`     | Period         | Yes      | Measurement period with start and end (ISO 8601)         |

**Returns:** `Parameters` resource:

```
Parameters
├── parameter[0]
│   ├── name: "population-report"
│   └── resource: MeasureReport (type: summary)
├── parameter[1]
│   ├── name: "{patient-id}"
│   └── resource: Bundle
│       ├── entry[0]: MeasureReport (type: individual)
│       ├── entry[1..n]: Clinical resources (Condition, Observation, etc.)
│       └── entry[last]: OperationOutcome (missing data notes)
└── parameter[2..n]: ...additional patients
```

**Validation:** Returns `OperationOutcome` (severity=error, code=processing) for missing/invalid parameters.

---

#### `$list-organizations` (GET) — `FacilityRegistrationAPI`

Returns a `Bundle` (collection) of all configured `Organization` resources.

#### `$list-facilities` (GET) — `FacilityRegistrationAPI`

| Parameter      | Type   | Description                      |
|----------------|--------|----------------------------------|
| `organization` | String | Organization ID (strips prefix)  |

Returns a `Bundle` (collection) of `Location` resources for the given organization.

---

#### `$list-measures` (GET) — `MeasureConfigurationAPI`

Returns a `Bundle` (collection) of all configured `Measure` resources.

---

#### `$list-org-patients` (GET) — `PatientSelectorAPI`

| Parameter        | Type   | Description       |
|------------------|--------|-------------------|
| `organizationId` | String | Organization ID   |

Returns a `Group` resource with member references to all patients across the organization's facilities.

#### `$list-facility-patients` (GET) — `PatientSelectorAPI`

| Parameter     | Type           | Description          |
|---------------|----------------|----------------------|
| `facilityIds` | List\<String\> | One or more facility IDs |

Returns a `Group` resource with member references to patients at the specified facilities.

---

#### `$list-receiving-systems` (GET) — `ReceivingSystemConfigurationAPI`

Returns a `Bundle` (collection) of `Endpoint` resources representing submission targets.

---

#### `$submit` (POST) — `SubmitAPI`

| Parameter            | Type       | Description                        |
|----------------------|------------|------------------------------------|
| `receivingSystemUrl` | String     | Receiving system FHIR server URL   |
| `gatherResult`       | Parameters | Result from `$gather` operation    |

Process:
1. Extracts population MeasureReport from `population-report` parameter
2. For each patient bundle, calls `Measure/{id}/$submit-data` on the receiving system
3. Creates the population MeasureReport on the receiving system
4. Returns `OperationOutcome` (severity=information)

---

#### `$generate-patient-data` (GET) — `GeneratePatientDataAPI`

| Parameter      | Type    | Default | Range  |
|----------------|---------|---------|--------|
| `numTestCases` | Integer | 200     | 10–200 |

Executes CQL from `CMS104TestDataGenerator.cql` to generate synthetic patient data. Returns a `Bundle` of test cases.

---

### Service Layer

#### `GatherService`

Top-level orchestrator for the `$gather` operation.

```
gather(Group patients, List<String> facilities, String measureId, Period period) → Parameters
```

1. Creates `PatientDataService` with patients and facilities
2. Creates `MeasureEvaluationService` with measure and period
3. Resolves patient bundles (clinical data + validation + individual reports)
4. Evaluates population-level report
5. Formats everything into a `Parameters` response

**Inner classes:**
- `GatherResult` — holds population report + list of patient bundles
- `PatientBundle` — holds patient ID, individual MeasureReport, clinical data Bundle, and missing data OperationOutcome

---

#### `MeasureEvaluationService`

Evaluates CQL measures using the Clinical Reasoning `R4MeasureProcessor`.

| Method | Description |
|--------|-------------|
| `getPatientReport(PatientBundle)` | Evaluates measure for a single patient → individual MeasureReport |
| `getPopulationReport(List<String>, List<PatientBundle>)` | Combines all patient data and evaluates → summary MeasureReport |
| `evaluate(List<String>, Bundle)` | Core: creates CqlEngine, calls `R4MeasureProcessor.evaluateMeasure()` |

**Dependencies (via SpringContext):** `R4MeasureProcessor`, `IRepository` (content), `MeasureEvaluationOptions`

---

#### `MeasureDataRequirementService`

Extracts data requirements from a measure's CQL to determine what FHIR resources to fetch.

| Method | Returns | Description |
|--------|---------|-------------|
| `getSearchParamMap()` | `Map<ResourceType, Map<param, values>>` | Search parameters grouped by resource type |
| `getSearchParamMapForPatient(patientId)` | Same, patient-scoped | Adds patient compartment filters |
| `getValuesetInfoMap()` | `Map<ResourceType, Map<path, ValueSetInfo>>` | ValueSet requirements per resource type |
| `getProfileMap()` | `Map<ResourceType, List<profileUrl>>` | Validation profiles per resource type |

Parses `Measure.contained[Library]#effective-data-requirements` or compiles from CQL using `DataRequirementsProcessor` + `LibraryManager`.

---

#### `PatientDataService`

Coordinates fetching clinical data across facilities for all selected patients.

```
resolvePatientBundles(MeasureEvaluationService) → List<PatientBundle>
```

For each facility × patient:
1. Calls `FacilityDataService.getPatientData()` to fetch clinical resources
2. Calls `ValidationService.validate()` to validate against profiles
3. Evaluates the individual patient measure report
4. Assembles into a `PatientBundle`

---

#### `FacilityDataService`

Queries a single facility's FHIR server.

| Method | Description |
|--------|-------------|
| `getAllFacilityPatients()` | `GET /Patient?_count=500` — returns Bundle of patients |
| `getFacilityPatientsFromGroup(patientIds)` | Filters facility patients to those in the selection |
| `getPatientData(dataReqService, patientBundle)` | Executes FHIR searches per resource type, adds to bundle |

Creates a HAPI `IGenericClient` using the facility URL from `FacilityRegistrationService.getFacilityUrl()`.

---

#### `ValidationService`

Validates clinical resources against QI-Core / US Core profiles.

```
validate(PatientBundle, facilityId, profileMap) → void (mutates bundle)
```

For each resource:
1. Adds a `Location` tag to `meta.tag[]` (system: `http://cms.gov/fhir/mct/tags/Location`)
2. If profiles exist, validates with `FhirValidator.validateWithResult()`
3. On failure: creates a contained `OperationOutcome`, adds a `validation-result` extension referencing it

---

#### Other Services

| Service | Description |
|---------|-------------|
| `FacilityRegistrationService` | Lists organizations/facilities from `facilities-bundle.json`. Extracts FHIR endpoint URLs from `Location.contained[Endpoint]` |
| `MeasureConfigurationService` | Lists measures from `measures-bundle.json` |
| `ReceivingSystemConfigurationService` | Lists receiving systems from `receiving-system-bundle.json` |
| `PatientSelectorService` | Queries facility servers for patient lists, returns as FHIR `Group` |
| `PatientDataGeneratorService` | Generates synthetic test data via CQL execution with external randomization function |

---

### Configuration

#### `application.yaml`

```yaml
server:
  port: 8088

hapi:
  fhir:
    fhir_version: R4
    package_server_url: https://packages.simplifier.net/
    terminology_server_url: http://tx.fhir.org/r4/
    install_transitive_ig_dependencies: false
    require_profile_for_validation: true
    implementationguides:
      qicore_4_1_1:
        url: https://hl7.org/fhir/us/qicore/STU4.1.1/package.tgz
        name: hl7.fhir.us.qicore
        version: 4.1.1
      uscore_3_1_1:
        url: http://hl7.org/fhir/us/core/STU3.1.1/package.tgz
        name: hl7.fhir.us.core
        version: 3.1.1
```

#### `MctConfig.java` — Spring `@Configuration`

Wires together the entire CQL evaluation and validation stack:

| Bean | Purpose |
|------|---------|
| `fhirContext` | `FhirContext.forCached(R4)` |
| `modelResolver` | `R4FhirModelResolver` for CQL |
| `contentRepository` | `InMemoryFhirRepository` with measures + terminology bundles |
| `measureProcessor` | `R4MeasureProcessor` for CQL measure evaluation |
| `measureEvaluationOptions` | Default evaluation settings |
| `fhirValidator` | `FhirValidator` with `FhirInstanceValidator` |
| `validationSupportChain` | NPM packages → CommonCodeSystems → DefaultProfile → InMemoryTerminology → SnapshotGenerator |
| `mctNpmPackageValidationSupport` | Loads QI-Core/US Core IGs from package server or direct URLs |
| `facilitiesBundle` | Loaded from `configuration/facilities/facilities-bundle.json` |
| `measuresBundle` | Loaded from `configuration/measures/measures-bundle.json` |
| `terminologyBundle` | Loaded from `configuration/terminology/terminology-bundle.json` |
| `receivingSystemsBundle` | Loaded from `configuration/receiving-system/receiving-system-bundle.json` |

#### `MctConstants.java`

All operation names, parameter names, error messages, extension URLs, and tag systems as static constants.

#### `MctProperties.java`

`@ConfigurationProperties(prefix = "hapi.fhir")` — binds `application.yaml` properties including `fhirVersion`, `packageServerUrl`, `terminologyServerUrl`, `installTransitiveIgDependencies`, `requireProfileForValidation`, and `implementationGuides` map.

---

### Validation

**`MctNpmPackageValidationSupport`** — extends HAPI's `NpmPackageValidationSupport` to load IG packages from direct URLs or the NPM package server. Supports optional transitive dependency installation.

---

## Frontend

### State Management

**Redux store** with two slices:

#### Filter Slice (`store/reducers/filter.js`)

Tracks UI selections:

```javascript
{
  organization: '',           // Selected organization ID
  selectedFacilities: [],     // Selected facility IDs
  selectedPatients: [],       // Selected patient IDs
  date: '2026',               // Measurement period/quarter
  measure: '',                // Selected measure ID
  drawerOpen: true,
  openItem: ['dashboard'],
  openComponent: 'buttons',
  componentDrawerOpen: true
}
```

Actions: `activeItem`, `activeComponent`, `openDrawer`, `inputSelection`, `openComponentDrawer`

#### Data Slice (`store/reducers/data.js`)

Manages API data and loading states:

```javascript
{
  facilities: [],
  patients: [],
  organizations: [],
  measures: [],
  measureReport: null,
  status: 'idle',    // idle | loading | succeeded | finalized | failed
  error: null
}
```

**Async thunks:**

| Thunk | Endpoint | Method |
|-------|----------|--------|
| `fetchOrganizations` | `/mct/$list-organizations` | GET |
| `fetchFacilities(orgId)` | `/mct/$list-facilities?organization={orgId}` | GET |
| `fetchMeasures` | `/mct/$list-measures` | GET |
| `fetchPatients(orgId)` | `/mct/$list-org-patients?organizationId={orgId}` | GET |
| `fetchFacilityPatients` | `/mct/$list-facility-patients?facilityIds=...` | GET |
| `executeGatherOperation` | `/mct/$gather` | POST |

**`$gather` payload builder** (`buildMeasurePayload`):
```javascript
{
  resourceType: 'Parameters',
  parameter: [
    { name: 'facilities', valueString: 'Location/{id}' },  // per facility
    { name: 'period', valuePeriod: { start, end } },
    { name: 'measure', valueString: measureId },
    { name: 'patients', resource: {
        resourceType: 'Group',
        member: [{ entity: { reference: 'Patient/{id}' } }]
    }}
  ]
}
```

**Timeout:** 180 seconds (3 minutes) on the gather operation.

---

### Pages & Components

#### Dashboard (`pages/dashboard/index.js`)

Main view with conditional rendering:

| State | Display |
|-------|---------|
| No measure selected | Prompt: "Select a Measure to Begin" |
| Measure selected, no report | Prompt: "Select Patient(s) and submit" |
| Loading | `LoadingPage("Retrieving Measure Report")` |
| Report ready | Tabs: Population Report + Individual Data |

**Key dashboard components:**

| Component | Purpose |
|-----------|---------|
| `PopulationMeasureReport` | Population-level statistics and stratifiers |
| `IndividualMeasureReport` | Per-patient reports with validation data |
| `PopulationStatistics` | Aggregate population counts |
| `PatientColumnChart` | ApexCharts visualization |
| `PatientTable` / `PatientsList` | Patient selection and listing |
| `ValidationDataTable` | FHIR validation issues per resource |
| `MeasureReportPopulationData` | Population group data display |
| `PromptChoiceCard` | User prompt container |

**Layout:** `MainLayout` with a sidebar drawer and header. Orchestrates initial data loading cascade: organizations → facilities + measures → patients.

**Reusable components:** `AlertDialog`, `FacilitiesMultiSelect`, `PatientMultiSelect`, `MainCard`, `Loader`, `LoadingPage`, `Selection`, `SeverityIcon`, `ScrollTop`

---

### Utility Functions

#### `measureReportHelpers.js`

| Function | Description |
|----------|-------------|
| `processMeasureReportPayload(params)` | Parses `$gather` response → `{ populationData, individualLevelData[], measureReport }` |
| `gatherIndividualLevelData(entries, name)` | Extracts patient-level data → `{ name, patient, ethnicity[], resources[], measureReport }` |
| `summarizeMeasureReport(report)` | Generates stats: `patientCount`, resource severity counts |
| `parseStratifier(report)` | Extracts stratification from `MeasureReport.group[0].stratifier[]` |
| `extractDescription(report)` | Extracts description from HL7 v5 extension |
| `populationGather(group)` | Processes population data from group structure |

#### `queryHelper.js`

| Function | Description |
|----------|-------------|
| `timeout(ms, promise)` | Wraps a promise with a timeout rejection |
| `createPeriodFromQuarter(quarter)` | Maps quarter string (q1–q4, year) to FHIR Period `{start, end}` |

#### `patientHelper.js`

Patient data extraction and formatting utilities.

---

## Data Flow

### Complete `$gather` Pipeline

```
User selects Org → $list-organizations
                 → $list-facilities
                 → $list-measures
                 → $list-facility-patients
User selects Measure + Patients + Period
User clicks "Get Report"
                 ↓
Frontend POSTs $gather with Parameters payload
                 ↓
GatherAPI validates parameters
                 ↓
GatherService.gather()
  ├── PatientDataService
  │     └── For each facility:
  │           └── FacilityDataService
  │                 ├── getFacilityPatientsFromGroup() → filter to selected patients
  │                 └── For each patient:
  │                       └── getPatientData()
  │                             ├── MeasureDataRequirementService.getSearchParamMapForPatient()
  │                             └── FHIR search per resource type → add to PatientBundle
  │     └── ValidationService.validate() → mutates resources with extensions
  │     └── MeasureEvaluationService.getPatientReport() → individual MeasureReport
  │
  └── MeasureEvaluationService.getPopulationReport() → summary MeasureReport
                 ↓
Response: Parameters { population-report, patient-1, patient-2, ... }
                 ↓
Frontend parses via measureReportHelpers → renders dashboard tabs
```

---

## FHIR Resources

| Resource          | Source              | Purpose                                           |
|-------------------|---------------------|---------------------------------------------------|
| Organization      | Config bundle       | Healthcare organization                           |
| Location          | Config bundle       | Facility (with contained Endpoint)                |
| Endpoint          | Contained in Location | FHIR REST URL for facility server               |
| Measure           | Config bundle       | Measure definition with CQL logic                 |
| Library           | Contained/referenced | CQL library for measure evaluation               |
| Group             | API parameter       | Patient cohort for gather                         |
| Period            | API parameter       | Measurement period (start/end)                    |
| Patient           | Facility server     | Patient demographics                              |
| Condition         | Facility server     | Diagnoses                                         |
| Observation       | Facility server     | Lab results, vitals                               |
| Procedure         | Facility server     | Procedures                                        |
| Encounter         | Facility server     | Patient visits                                    |
| MedicationStatement | Facility server   | Medications                                       |
| MeasureReport     | Response            | Population (summary) or individual results        |
| Bundle            | Response            | Container for patient data + reports              |
| OperationOutcome  | Response            | Validation results or error messages              |
| Parameters        | Request/Response    | Operation I/O                                     |

---

## Custom Extensions & Tags

| Identifier | Type | Location | Purpose |
|------------|------|----------|---------|
| `http://cms.gov/fhir/mct/StructureDefinition/validation-result` | Extension (Reference) | Clinical resource `.extension[]` | Links resource to contained OperationOutcome with validation issues |
| `http://cms.gov/fhir/mct/StructureDefinition/measurereport-location` | Extension (Reference) | `MeasureReport.extension[]` | Identifies originating facility |
| `http://cms.gov/fhir/mct/tags/Location` | Meta tag | `Resource.meta.tag[]` | Tags resources with originating facility ID |

---

## Docker & Deployment

### Docker Compose (`docker/docker-compose.yml`)

| Service        | Image                        | Port | Description                    |
|----------------|------------------------------|------|--------------------------------|
| `mct-frontend` | Built from `../frontend`     | 3000 | React UI                       |
| `mct-backend`  | Built from `../java`         | 8088 | Spring Boot API                |
| `facility-a`   | `hapiproject/hapi:latest`    | 8080 | HAPI FHIR server (facility A)  |
| `facility-b`   | `hapiproject/hapi:latest`    | 8082 | HAPI FHIR server (facility B)  |

**Requirements:** Docker with at least 8 GB RAM.

### Dockerfiles

**Backend** (`java/Dockerfile`):
```dockerfile
FROM maven:3.9.6-eclipse-temurin-17
COPY . .
RUN mvn clean package -DskipTests
ENTRYPOINT ["java", "-jar", "target/mct-0.0.1-SNAPSHOT.jar"]
```

**Frontend** (`frontend/Dockerfile`): Multi-stage Node 18.12.1-alpine build → `yarn install` + `yarn build` → `yarn start` on port 3000.

### Build & Run Commands

```bash
# Full stack (Docker)
cd docker && docker compose up --build
./bin/load_local_data.sh

# Frontend only
cd frontend && yarn install && yarn start    # Dev server :3000

# Backend only
cd java && mvn spring-boot:run               # Server :8088

# Build
cd frontend && yarn build                    # Production build
cd java && mvn clean package -DskipTests     # JAR

# Lint
cd frontend && yarn lint
```

### API Documentation

Once the stack is running, Swagger UI is available at:
- **Swagger UI:** `http://localhost:8088/mct/swagger-ui/`
- **OpenAPI spec:** `http://localhost:8088/mct/api-docs`

### Loading Test Data

```bash
# Automated
./bin/load_local_data.sh

# Manual
POST java/src/main/resources/configuration/test-bundles/facility-a-bundle.json → localhost:8080/fhir
POST java/src/main/resources/configuration/test-bundles/facility-b-bundle.json → localhost:8082/fhir
```

---

## CI/CD

**Provider:** Travis CI (`.travis.yml`)

| Stage   | Trigger       | Steps                                                                 |
|---------|---------------|-----------------------------------------------------------------------|
| Test    | All branches  | Docker build frontend → `yarn test-ci`                                |
| Deploy  | `main` only   | Build both Docker images → push to AWS ECR → `./bin/deploy.sh` (Helm) |

Deploy updates facility URLs in `facilities-bundle.json` (localhost → internal K8s service names) before building the backend image.

---

## Infrastructure

### Kubernetes (`infrastructure/kubernetes/`)

Helm chart `aphl-mct-k8s` with templates for:
- Frontend deployment + service
- Backend deployment + service
- Two CQF Ruler (FHIR server) deployments + services
- IG server deployment + service

Images tagged with `$TRAVIS_COMMIT`.

### Terraform (`infrastructure/terraform/`)

Provisions AWS infrastructure:
- **EKS cluster** with blue/green managed node groups (`t3.medium` SPOT instances)
- **VPC** with private subnets
- **KMS keys** for EBS encryption
- **IAM policies** and security groups for SSH

---

## Testing

### Backend (JUnit 5 + Spring Boot Test)

Run with `cd java && mvn test`. Uses `@SpringBootTest(webEnvironment = RANDOM_PORT)` with a real HAPI FHIR client.

| Test Class | Coverage |
|------------|----------|
| `GatherOperationTest` | Parameter validation: missing patients, empty group, missing facilities, missing measure, missing period, missing period start/end |
| `FacilityRegistrationTest` | `$list-organizations` (2 orgs), `$list-facilities` (2 per org), facility URL extraction |
| `MeasureConfigurationTest` | `$list-measures` |
| `ReceivingSystemConfigurationTest` | `$list-receiving-systems` |

### Frontend (Jest + React Testing Library)

Run with `cd frontend && yarn test` (watch) or `yarn test-ci` (single run).

| Test File | Coverage |
|-----------|----------|
| `measureReportHelpers.spec.js` | FHIR MeasureReport parsing (with snapshots) |
| `patientHelper.spec.js` | Patient data extraction |
| `queryHelper.spec.js` | Period/timeout utilities |

---

## Dependencies

### Backend (Key)

| Artifact | Version | Purpose |
|----------|---------|---------|
| `spring-boot-starter-web` | 3.2.5 | Web framework |
| `hapi-fhir-base` / `structures-r4` / `server` / `validation` | 8.8.0 | FHIR R4 |
| `cqf-fhir-cr` | 4.4.2 | Clinical Reasoning measure evaluation |
| `cqf-fhir-cql` | 4.4.2 | CQL engine integration |
| `cqf-fhir-utility` | 4.4.2 | Repository, adapters |
| `guava` | 33.4.0-jre | Core utilities |
| `jakarta.xml.bind-api` | 4.0.2 | XML binding |

### Frontend (Key)

| Package | Version | Purpose |
|---------|---------|---------|
| `react` / `react-dom` | 18.2.0 | UI framework |
| `@reduxjs/toolkit` | 1.8.5 | State management |
| `@mui/material` | 5.11.10 | Component library |
| `react-router-dom` | 6.4.1 | Routing |
| `apexcharts` | 3.35.5 | Charts |
| `formik` / `yup` | 2.2.9 / 0.32.11 | Forms + validation |
| `moment` | 2.29.4 | Date handling |
| `lodash` | 4.17.21 | Utilities |

---

## Developer Guide

### Adding a New Measure

1. Add Measure + Library JSON to `configuration/measures/measures-bundle.json`
2. Include `effective-data-requirements` contained Library (or CQL will be compiled at runtime)
3. Add test patient data to `configuration/test-bundles/`
4. Restart backend

### Adding a New API Operation

1. Create API class in `api/` with `@Operation` annotated method
2. Add operation name constant to `MctConstants`
3. Implement service class if needed
4. Register provider in `MctApplication.restfulServer()` resource providers list
5. Add integration tests

### Adding a New Facility

1. Add `Location` + `Organization` + `Endpoint` entries to `configuration/facilities/facilities-bundle.json`
2. Add a new Docker Compose service (HAPI FHIR server) if needed
3. Update `bin/load_local_data.sh` for test data loading

### Performance Notes

- Measure evaluation: ~1 second per patient
- Single facility (~100 patients): ~100 seconds
- Dual facility (~100 patients each): ~200 seconds
- Frontend timeout: 180 seconds
