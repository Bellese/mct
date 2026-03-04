# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MCT (Measure Calculation Tool) is a Spring Boot + React application for calculating FHIR-based digital quality measures (dQMs). It evaluates CQL-based eCQMs against patient data retrieved from FHIR facility servers.

**Status:** Prototype — not production-ready. Authentication and other critical features are intentionally absent.

---

## Commands

### Full Stack (Docker)

Run from the `docker/` directory:

```bash
docker-compose up --build
```

Starts four services: frontend (`:3000`), backend (`:8088`), facility-a (`:8080/fhir`), facility-b (`:8082/fhir`).

Load test data after startup:

```bash
./bin/load_local_data.sh
```

### Java Backend

Run from the `java/` directory:

```bash
./mvnw spring-boot:run          # Run locally (port 8088)
./mvnw clean package -DskipTests  # Build JAR without tests
./mvnw test                     # Run all tests
./mvnw test -Dtest=GatherOperationTest  # Run a single test class
./mvnw clean package            # Build with tests
```

### Frontend

Run from the `frontend/` directory:

```bash
yarn install      # Install dependencies
yarn start        # Dev server (port 3000)
yarn test         # Interactive test watch mode
yarn test-ci      # Single-pass test run (CI mode)
yarn build        # Production build
```

Lint: `eslint --ext js .`

---

## Architecture

### Request Flow

The primary operation is `$gather`, which takes a patient group, facility URLs, a measure identifier, and a measurement period, then returns population and per-patient MeasureReports.

```
Frontend → GatherAPI.$gather()
         → GatherService.gather()
           ├── PatientDataService    (fetches patient bundles from facility FHIR servers)
           └── MeasureEvaluationService
                 └── R4MeasureProcessor (cql-evaluator)
                       ├── LibrarySourceProvider (loads CQL/ELM libraries)
                       ├── CqlTranslator (CQL → ELM)
                       └── DataProvider (executes against patient bundles)
         → Returns Parameters resource with MeasureReports
```

### Java Backend (`java/src/main/java/org/opencds/cqf/mct/`)

| Package | Purpose |
|---|---|
| `api/` | 7 HAPI FHIR `@Operation` REST controllers |
| `service/` | Business logic — `GatherService` is the primary orchestrator |
| `config/` | Spring beans (`MctConfig.java`), app properties (`MctProperties.java`), constants |
| `processor/` | `DataRequirementsProcessor` — extracts CQL data requirements from measures |
| `validation/` | `MctNpmPackageValidationSupport` — loads IG NPM packages for profile validation |

**`MctConfig.java`** wires together the entire CQL evaluation stack: FHIR context, library source providers, terminology services, data providers, and the FHIR validator.

**`MctProperties.java`** maps `hapi.fhir.*` from `application.yaml`, including the IG package registrations.

### Key Configuration (`java/src/main/resources/`)

- `application.yaml` — server port, FHIR version (R4), terminology server, registered IGs
- `configuration/measures/measures-bundle.json` — Measure + Library resources loaded at startup
- `configuration/facilities/facilities-bundle.json` — Facility endpoint definitions
- `configuration/terminology/terminology-bundle.json` — Value sets and code systems
- `configuration/test-bundles/` — `facility-a-bundle.json` and `facility-b-bundle.json` (patient data for local dev)
- `configuration/patient-data-gen-libraries/` — CQL for synthetic test data generation

### FHIR / CQL Stack

- **FHIR Version:** R4 (4.0.1)
- **QI Core:** 4.1.1 (STU4.1.1)
- **US Core:** 3.1.1
- **CQL Evaluator:** `org.opencds.cqf.cql:evaluator.*` 2.4.0
- **CQL Translator:** `info.cqframework:*` 2.4.0
- **HAPI FHIR:** 6.2.2
- **Facility servers:** `cschuler72/cqf-ruler:latest` (bare HAPI FHIR — no IG config)

The MCT backend is responsible for all IG-aware logic. Facility servers are plain FHIR data stores.

### Frontend (`frontend/src/`)

React 18 + Redux Toolkit + React Router v6 + Material UI 5. The backend API base URL defaults to `http://localhost:8088`. Key areas:

- `pages/` — Page-level components driving the step-by-step workflow (org → measure → facility → patients → period → report)
- `store/` — Redux slices for workflow state
- `utils/` — Helper functions (tested via `.spec.js` files in the same directory)

### Tests

Java tests live in `java/src/test/java/org/opencds/cqf/mct/` (JUnit 5, 4 integration-style test classes). Frontend tests use Jest + React Testing Library, co-located in `frontend/src/utils/`.

---

## Adding IG Support

To register a new Implementation Guide, add an entry under `hapi.fhir.implementationguides` in `application.yaml`:

```yaml
implementationguides:
  qicore_6_0_0:
    url: https://hl7.org/fhir/us/qicore/STU6/package.tgz
    name: hl7.fhir.us.qicore
    version: 6.0.0
```

Also update `MctNpmPackageValidationSupport` to load the new package for profile validation, and add the corresponding supporting CQL libraries to the measures bundle.
