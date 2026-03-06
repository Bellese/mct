# Plan: Upgrade HAPI FHIR from 6.2.2 to Latest

## Context

The MCT Java backend currently uses **HAPI FHIR 6.2.2** (released 2022). The latest stable release is **HAPI FHIR 8.8.0** (February 2025). The current version is over 2 years behind and is missing security fixes, performance improvements, and bug fixes. Additionally, several transitive dependencies (SnakeYAML, json-smart) are already pinned to override vulnerabilities in the current stack.

This is not a simple version bump — it's a **major platform upgrade** affecting Java version, Spring Boot, the servlet API namespace, and the CQL evaluation library. The CQL evaluator library (`org.opencds.cqf.cql:evaluator` 2.4.0) used by MCT has been superseded by the `clinical-reasoning` project, which targets HAPI 8.x.

## Version Changes Summary

| Dependency | Current | Target | Notes |
|---|---|---|---|
| **Java** | 11 | 17 (minimum) | Required by HAPI 7.0+ and Spring Boot 3.x |
| **HAPI FHIR** | 6.2.2 | 8.8.0 | Latest stable |
| **org.hl7.fhir.utilities** | 5.6.76 (pinned) | Remove pin | HAPI 8.x bundles a compatible version |
| **Spring Boot** | 2.7.15 | 3.2.x+ | Required for jakarta.* namespace compatibility |
| **Spring Framework** | 5.3.29 | 6.1.x+ (via Boot 3.2) | Comes with Spring Boot 3.x |
| **javax.servlet-api** | 3.1.0 | Remove | Replaced by jakarta.servlet (bundled with Spring Boot 3) |
| **CQL Evaluator** | 2.4.0 (`org.opencds.cqf.cql:evaluator.*`) | **clinical-reasoning** 4.4.x (`org.opencds.cqf.fhir:cqf-fhir-cr-hapi`) | cql-evaluator is deprecated; clinical-reasoning is the successor |
| **CQL Translator** | 2.4.0 (`info.cqframework:model-jackson`, `elm-jackson`) | 3.x+ (via clinical-reasoning) | Bundled as transitive dependency |
| **engine-jackson** | 2.6.0 | Remove or update | Absorbed into clinical-reasoning |
| **SnakeYAML** | 2.2 (override) | Remove override | Spring Boot 3.x bundles a non-vulnerable version |
| **json-smart** | 2.4.11 (override) | Remove override | Spring Boot 3.x bundles a non-vulnerable version |
| **Guava** | 31.1-jre | 33.x+ | Update to latest for compatibility |

## Breaking Changes to Account For

### 1. Java 11 to Java 17 (HIGH IMPACT)

- Update `pom.xml` properties: `java.version`, `maven.compiler.source`, `maven.compiler.target`
- Update `Dockerfile` base images from Java 11 to Java 17
- Update `.tool-versions` if applicable
- Review code for any Java 11-specific patterns (unlikely to cause issues)

### 2. javax.* to jakarta.* Namespace Migration (HIGH IMPACT)

- HAPI FHIR 7.0+ and Spring Boot 3.x both require `jakarta.*` packages
- **Files affected:**
  - `MctApplication.java` — uses `javax.servlet` for `RestfulServer` and `CorsInterceptor`
  - `pom.xml` — remove `javax.servlet-api` dependency
- All `javax.servlet.*` imports become `jakarta.servlet.*`

### 3. CQL Evaluator to Clinical Reasoning Migration (HIGH IMPACT)

- The `org.opencds.cqf.cql:evaluator.*` artifacts (2.4.0) are deprecated and replaced by the `clinical-reasoning` project
- This affects the deepest integration points in the codebase:
  - **`MctConfig.java`** (33 beans) — ~20 imports from `org.opencds.cqf.cql.evaluator.*` for factories, providers, adapters
  - **`MeasureEvaluationService.java`** — uses `R4MeasureProcessor`, `DataProviderFactory`, `EndpointConverter`, etc.
  - **`GatherAPI.java`**, **`SubmitAPI.java`**, **`GatherService.java`** — static imports for `Parameters.parameters()` and `Parameters.part()`
  - **`FacilityRegistrationService.java`**, **`MeasureConfigurationService.java`**, **`ReceivingSystemConfigurationService.java`** — use `BundleRetrieveProvider`
  - **`PatientDataGeneratorService.java`** — uses CQL engine classes (`Context`, `DataProvider`, `JsonCqlLibraryReader`, `Library`, `VersionedIdentifier`)
  - **`MeasureDataRequirementService.java`** — uses CQL translator classes
  - **`DataRequirementsProcessor.java`** — uses ELM requirements classes
  - **Test files** — `FacilityRegistrationTest.java`, `GatherOperationTest.java`
- The clinical-reasoning library has a different API surface; a mapping of old classes to new classes will need to be established

### 4. Spring Boot 2.7 to 3.x (MEDIUM IMPACT)

- `application.yaml` configuration keys may change
- Spring Security 6.x changes (MCT has no auth, so minimal impact)
- Auto-configuration class locations moved to `META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports`
- `spring-boot-maven-plugin` version bump

### 5. HAPI FHIR API Changes (6.2 to 8.8) (MEDIUM IMPACT)

- **6.4**: Database definition changes (not applicable — MCT doesn't use JPA server)
- **6.6**: `ModelConfig` renamed to `StorageSettings`, `DaoConfig` renamed to `JpaStorageSettings` (not applicable — MCT doesn't use JPA)
- **6.6**: Validation `$validate` now returns 200 instead of 412 (may affect tests)
- **6.8**: `ThreadLocal` interceptor registrations deprecated
- **7.0**: Contained resource ID handling changes (`#` prefix behavior)
- **8.0**: Device resource patient compartment changes
- **8.x**: Package installation ID handling changes (may affect IG loading in `MctNpmPackageValidationSupport`)
- **8.x**: Snapshot repository moved to Maven Central (update `<repositories>` in pom.xml, remove Sonatype references)

### 6. Maven Repository Changes (LOW IMPACT)

- OSS Sonatype snapshots were sunsetted June 2025
- HAPI FHIR snapshots now published to Maven Central
- Remove `oss-sonatype` and `oss-sonatype-public` repository entries from `pom.xml`

### 7. Docker Configuration (LOW IMPACT)

- Update base images in `docker/` Dockerfiles to Java 17
- HAPI FHIR JPA Server Starter images used for facility servers should also be updated for compatibility

## Recommended Approach

Given the scope, this upgrade should be done incrementally:

**Phase 1**: Java 17 + Spring Boot 3.x + javax to jakarta migration -- DONE
**Phase 2**: HAPI FHIR 8.8.0 upgrade -- DONE
**Phase 3**: CQL Evaluator to Clinical Reasoning migration -- BLOCKING (see below)
**Phase 4**: Clean up overrides (SnakeYAML, json-smart, Guava, repository entries) -- DONE
**Phase 5**: Docker + CI updates -- DONE

## Current Implementation Status

Phases 1, 2, 4, and 5 have been applied:
- `pom.xml`: Java 17, Spring Boot 3.2.5, HAPI FHIR 8.8.0, removed vulnerability overrides, removed Sonatype repos, added HAPI validation modules, added Jakarta XML Bind, updated Guava to 33.x, updated Surefire
- `MctApplication.java`: Removed `ElasticsearchRestClientAutoConfiguration` exclusion (removed in Spring Boot 3)
- `DataRequirementsProcessor.java`: `javax.xml.bind` to `jakarta.xml.bind`
- `java/Dockerfile`: Updated to `maven:3.9.6-eclipse-temurin-17`
- Created `ParametersUtil.java` to replace `org.opencds.cqf.cql.evaluator.fhir.util.r4.Parameters` static helpers
- Updated all files using `Parameters.parameters()` / `Parameters.part()` to use the new `ParametersUtil`

### Phase 3 Blocker: CQL Evaluator to Clinical Reasoning

The `cql-evaluator` 2.4.0 artifacts were compiled against HAPI FHIR 6.x (javax.servlet). They are **binary-incompatible** with HAPI FHIR 8.8.0 (jakarta.servlet). The `cql-evaluator` project has been archived and replaced by the `clinical-reasoning` project (v4.4.x), which has a fundamentally different architecture:

- **Old**: Builder/Factory pattern (`DataProviderFactory`, `TerminologyProviderFactory`, `R4MeasureProcessor`, `BundleRetrieveProvider`, etc.)
- **New**: Repository API pattern (`IRepository` interface) with hexagonal architecture

Files still depending on `cql-evaluator` that need migration:
- `MctConfig.java` — ~20 evaluator imports for builder/factory beans
- `MeasureEvaluationService.java` — `R4MeasureProcessor` and builder factories
- `FacilityRegistrationService.java` — `BundleRetrieveProvider`
- `MeasureConfigurationService.java` — `BundleRetrieveProvider`
- `ReceivingSystemConfigurationService.java` — `BundleRetrieveProvider`
- `PatientDataGeneratorService.java` — CQL engine execution classes

The CQL engine classes (`org.opencds.cqf.cql.engine.*`) from the archived `cql-engine` project have been merged into the `clinical_quality_language` monorepo. Maven artifact coordinates and class locations have changed in newer versions.

**Recommended next steps for Phase 3:**
1. Add `org.opencds.cqf.fhir:cqf-fhir-cr-hapi:4.4.2` as the primary clinical-reasoning dependency
2. Implement the `IRepository` interface for Bundle-based and REST-based data access
3. Replace `R4MeasureProcessor` with the clinical-reasoning equivalent
4. Replace `BundleRetrieveProvider` with Repository-based retrieval
5. Update CQL engine imports to match the new `clinical_quality_language` monorepo coordinates

## Verification

- `mvn clean compile` — confirms all imports resolve
- `mvn test` — runs 4 test classes (MeasureConfigurationTest, FacilityRegistrationTest, ReceivingSystemConfigurationTest, GatherOperationTest)
- `docker compose up --build` — full stack integration test
- `./bin/load_local_data.sh` + manual test of gather/submit workflow

## Files Modified

- `java/pom.xml` — version upgrades and dependency changes
- `java/Dockerfile` — Java 17 base image
- `java/src/main/java/org/opencds/cqf/mct/MctApplication.java` — Spring Boot 3 compatibility
- `java/src/main/java/org/opencds/cqf/mct/processor/DataRequirementsProcessor.java` — javax to jakarta
- `java/src/main/java/org/opencds/cqf/mct/util/ParametersUtil.java` — NEW: replaces evaluator Parameters helpers
- `java/src/main/java/org/opencds/cqf/mct/api/GatherAPI.java` — updated imports
- `java/src/main/java/org/opencds/cqf/mct/api/SubmitAPI.java` — updated imports
- `java/src/main/java/org/opencds/cqf/mct/service/GatherService.java` — updated imports
- `java/src/test/java/org/opencds/cqf/mct/FacilityRegistrationTest.java` — updated imports
- `java/src/test/java/org/opencds/cqf/mct/GatherOperationTest.java` — updated imports

## Files Still Requiring CQL Evaluator Migration (Phase 3)

- `java/src/main/java/org/opencds/cqf/mct/config/MctConfig.java`
- `java/src/main/java/org/opencds/cqf/mct/service/MeasureEvaluationService.java`
- `java/src/main/java/org/opencds/cqf/mct/service/PatientDataGeneratorService.java`
- `java/src/main/java/org/opencds/cqf/mct/service/MeasureDataRequirementService.java`
- `java/src/main/java/org/opencds/cqf/mct/service/FacilityRegistrationService.java`
- `java/src/main/java/org/opencds/cqf/mct/service/MeasureConfigurationService.java`
- `java/src/main/java/org/opencds/cqf/mct/service/ReceivingSystemConfigurationService.java`

## Sources

- [HAPI FHIR Changelog 2025](https://hapifhir.io/hapi-fhir/docs/introduction/changelog.html)
- [HAPI FHIR Changelog 2023](https://hapifhir.io/hapi-fhir/docs/introduction/changelog_2023.html)
- [HAPI FHIR 7.0.0 Jakarta Migration Guide](https://hapifhir.io/hapi-fhir/docs/interceptors/jakarta_upgrade.html)
- [HAPI FHIR GitHub Releases](https://github.com/hapifhir/hapi-fhir/releases)
- [CQF Clinical Reasoning GitHub](https://github.com/cqframework/clinical-reasoning)
- [Clinical Reasoning Releases](https://github.com/cqframework/clinical-reasoning/releases)
- [Spring Boot 3.0 Migration Guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.0-Migration-Guide)
