# Java Backend Dependencies

This document outlines the dependencies for the MCT Java backend application, as defined in `java/pom.xml`.

## Build Properties

| Property | Value |
|---|---|
| Java Version | 17 |
| Source Encoding | UTF-8 |

## Runtime Dependencies

### Spring Framework

| Artifact | Version | Purpose |
|---|---|---|
| `org.springframework.boot:spring-boot-starter-web` | 3.2.5 | Web application framework with embedded Tomcat |

### HAPI FHIR

| Artifact | Version | Purpose |
|---|---|---|
| `ca.uhn.hapi.fhir:hapi-fhir-base` | 8.8.0 | FHIR base library |
| `ca.uhn.hapi.fhir:hapi-fhir-structures-r4` | 8.8.0 | FHIR R4 resource structures |
| `ca.uhn.hapi.fhir:hapi-fhir-server` | 8.8.0 | FHIR server framework |
| `ca.uhn.hapi.fhir:hapi-fhir-validation` | 8.8.0 | FHIR resource validation |
| `ca.uhn.hapi.fhir:hapi-fhir-validation-resources-r4` | 8.8.0 | R4 validation resource definitions |
| `ca.uhn.hapi.fhir:hapi-fhir-caching-caffeine` | 8.8.0 | Caffeine-based caching provider (required by HAPI 8.x validation) |

### CQL Clinical Reasoning

| Artifact | Version | Purpose |
|---|---|---|
| `org.opencds.cqf.fhir:cqf-fhir-cr` | 4.4.2 | Clinical Reasoning core — measure evaluation, R4MeasureProcessor, Repository API |
| `org.opencds.cqf.fhir:cqf-fhir-utility` | 4.4.2 | FHIR utilities — InMemoryFhirRepository, IAdapterFactory |
| `org.opencds.cqf.fhir:cqf-fhir-cql` | 4.4.2 | CQL engine wrappers — Engines.forRepository(), RepositoryFhirLibrarySourceProvider |

### Jakarta XML Bind

| Artifact | Version | Purpose |
|---|---|---|
| `jakarta.xml.bind:jakarta.xml.bind-api` | 4.0.2 | Jakarta XML Binding API (replaces javax.xml.bind removed in Java 11+) |
| `org.glassfish.jaxb:jaxb-runtime` | 4.0.5 | JAXB runtime implementation |

### Utility

| Artifact | Version | Purpose |
|---|---|---|
| `com.google.guava:guava` | 33.4.0-jre | Google core libraries for Java |

## Test Dependencies

| Artifact | Version | Purpose |
|---|---|---|
| `org.springframework.boot:spring-boot-starter-test` | 3.2.5 | Spring Boot test framework (JUnit, Mockito, etc.) |

## Build Plugins

| Plugin | Version | Purpose |
|---|---|---|
| `org.springframework.boot:spring-boot-maven-plugin` | 3.2.5 | Packages the application as an executable JAR |
| `org.apache.maven.plugins:maven-surefire-plugin` | 3.2.5 | Runs unit tests during the build |

## Maven Repositories

Maven Central only (Sonatype snapshot repositories were removed as they have been sunsetted).
