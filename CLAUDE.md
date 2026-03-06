# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MCT (Measure Calculation Tool) is a FHIR-based platform for calculating and reporting digital quality measures (dQMs). It has a React frontend and a Java Spring Boot backend that integrates with HAPI FHIR servers acting as healthcare facilities. This is a prototype — not production-ready (no auth, client can modify reports before submission).

### Documentation

- `README.md` - General project information and quick guides.
- `docs/` - Markdown files organized by topic that provide in-depth information that's not suitable for `README.md`
- `CHANGE_MANAGEMENT.md` - Guide and outlines for contributing to the project.

## Architecture

- **`frontend/`** — React 18 SPA using MUI v5, Redux Toolkit for state, React Router v6, Formik+Yup for forms
- **`java/`** — Spring Boot 3.2.5 backend (Java 17) running on port 8088, using HAPI FHIR 8.8.0 and CQL Evaluator 2.4.0 (pending migration to clinical-reasoning 4.4.x)
- **`docker/`** — Docker Compose orchestration for all services
- **`bin/`** — Helper scripts for deployment and data loading

### Backend Structure (`java/src/main/java/org/opencds/cqf/mct/`)

- `api/` — REST endpoints under `/mct/*`: FacilityRegistration, Gather, MeasureConfiguration, ReceivingSystemConfiguration, GeneratePatientData, PatientSelector, Submit
- `service/` — Business logic (11 services covering facility management, measure evaluation, patient data, validation)
- `config/` — Spring/FHIR configuration including CORS (allows all origins)
- `processor/` — Data processing logic
- `validation/` — Input validation

### Frontend Structure (`frontend/src/`)

- `components/` — Reusable UI components
- `pages/` — Dashboard page views
- `store/` — Redux reducers
- `config.js` — API endpoint configuration (backend at `localhost:8088`, FHIR servers)

### Key Configuration

- `java/src/main/resources/application.yaml` — HAPI FHIR config, IG dependencies (QI-Core 4.1.1, US Core 3.1.1), terminology server
- `java/src/main/resources/configuration/` — Measures, facilities, test bundles, terminology, receiving system configs

## Build & Run Commands

### Full Stack (Docker) — Primary Development Method

```bash
cd docker
docker compose up --build        # Starts frontend(:3000), backend(:8088), facility-a(:8080), facility-b(:8082)
./bin/load_local_data.sh         # Load test patient data into FHIR servers
```

Requires Docker with at least 8 GB RAM allocated.

### Frontend Only

```bash
cd frontend
yarn install
yarn start          # Dev server at localhost:3000
yarn build          # Production build
yarn lint           # ESLint
yarn test           # Jest + React Testing Library
yarn test-ci        # CI test mode
```

### Backend Only

```bash
cd java
mvn spring-boot:run              # Start backend at localhost:8088
mvn test                         # Run JUnit tests
mvn clean package -DskipTests    # Build JAR without tests
```

### Loading Test Data Manually

POST `java/src/main/resources/configuration/test-bundles/facility-a-bundle.json` to `localhost:8080/fhir`
POST `java/src/main/resources/configuration/test-bundles/facility-b-bundle.json` to `localhost:8082/fhir`

## Testing

- **Frontend:** Jest + React Testing Library. Config in `frontend/src/setupTests.js`.
- **Backend:** 4 test classes in `java/src/test/java/` — MeasureConfigurationTest, FacilityRegistrationTest, ReceivingSystemConfigurationTest, GatherOperationTest.

## Code Style

- **Frontend:** ESLint (babel parser, prettier integration) + Prettier (single quotes, 140 print width, no trailing commas). See `frontend/.eslintrc` and `frontend/.prettierrc`.
- **Backend:** Standard Java/Spring conventions.

## Performance Note

Measure evaluation runs ~1 second per patient (~100s for single facility, ~200s for dual facility with test data).
