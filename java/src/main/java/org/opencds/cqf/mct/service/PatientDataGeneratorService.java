package org.opencds.cqf.mct.service;

import ca.uhn.fhir.util.ClasspathUtil;
import org.cqframework.cql.cql2elm.CqlTranslator;
import org.cqframework.cql.cql2elm.DefaultLibrarySourceProvider;
import org.cqframework.cql.cql2elm.LibraryManager;
import org.cqframework.cql.cql2elm.LibrarySourceProvider;
import org.cqframework.cql.cql2elm.ModelManager;
import org.hl7.elm.r1.VersionedIdentifier;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.Group;
import org.hl7.fhir.r4.model.IntegerType;
import org.hl7.fhir.r4.model.Patient;
import org.hl7.fhir.r4.model.Reference;
import org.hl7.fhir.r4.model.Resource;
import org.opencds.cqf.cql.engine.data.DataProvider;
import org.opencds.cqf.cql.engine.data.ExternalFunctionProvider;
import org.opencds.cqf.cql.engine.execution.CqlEngine;
import org.opencds.cqf.cql.engine.execution.Environment;
import org.opencds.cqf.cql.engine.execution.EvaluationExpressionRef;
import org.opencds.cqf.cql.engine.execution.EvaluationParams;
import org.opencds.cqf.cql.engine.execution.EvaluationResult;
import org.opencds.cqf.cql.engine.execution.EvaluationResults;
import org.opencds.cqf.cql.engine.execution.ExpressionResult;
import org.opencds.cqf.cql.engine.data.SystemExternalFunctionProvider;
import org.opencds.cqf.mct.SpringContext;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.Random;
import java.util.stream.Collectors;

import org.hl7.elm.r1.ExpressionDef;
import java.util.Comparator;

/**
 * The Patient Data Generator Service logic for the {@link org.opencds.cqf.mct.api.GeneratePatientDataAPI}.
 */
public class PatientDataGeneratorService {
   private static final String GENERATED_PATIENT_BASE = "-generated";
   private final DataProvider dataProvider;
   private static final Random randomNumberGenerator = new Random();

   /**
    * Instantiates a new Patient Data Generator Service.
    */
   public PatientDataGeneratorService() {
      this(SpringContext.getBean(DataProvider.class));
   }

   /**
    * Instantiates a new Patient Data Generator Service with the provided data provider.
    *
    * @param dataProvider the data provider used by the CQL execution context
    */
   public PatientDataGeneratorService(DataProvider dataProvider) {
      this.dataProvider = dataProvider;
   }

   /**
    * Generate test cases for the CMS104 pilot measure
    *
    * @see org.opencds.cqf.mct.api.GeneratePatientDataAPI#generatePatientData(IntegerType)
    * @param numTestCases the number of test cases to generate (200 by default, defined in the CQL)
    * @return the bundle of test cases containing the patient data
    * @throws IOException           when the cql file does not exist or is malformed
    * @throws NoSuchMethodException when the external function method is not present
    */
   public Bundle generatePatientData(Integer numTestCases) throws IOException, NoSuchMethodException {
      VersionedIdentifier versionedIdentifier =
              new VersionedIdentifier().withId("CMS104TestDataGenerator2026").withVersion("1.0.0");
      File cqlFile = new File(Objects.requireNonNull(Objects.requireNonNull(ClasspathUtil.class.getClassLoader().getResource(
              "configuration/patient-data-gen-libraries/" + "CMS104TestDataGenerator2026" + ".cql")).getFile(), "UTF-8"));
      File libraryDirectory = cqlFile.getParentFile();
      ModelManager modelManager = new ModelManager();
      LibraryManager libraryManager = new LibraryManager(modelManager);
      LibrarySourceProvider librarySourceProvider = new DefaultLibrarySourceProvider(
              new kotlinx.io.files.Path(libraryDirectory));
      libraryManager.getLibrarySourceLoader().registerProvider(librarySourceProvider);
      CqlTranslator translator = CqlTranslator.fromFile(cqlFile.getAbsolutePath(), libraryManager);
      if (!translator.getErrors().isEmpty()) {
         String errors = translator.getErrors().stream()
         .map(error -> error.getLocator() == null
         ? error.getMessage()
         : error.getLocator().toLocator() + " " + error.getMessage())
         .collect(Collectors.joining(System.lineSeparator()));
         throw new IllegalArgumentException(errors);
      }
      translator.getTranslatedLibrary()
         .getLibrary()
         .getStatements()
         .getDef()
         .sort(Comparator.comparing(ExpressionDef::getName));
      libraryManager.getCompiledLibraries().put(versionedIdentifier, translator.getTranslatedLibrary());
      Environment environment = new Environment(libraryManager, new HashMap<>(Map.of("http://hl7.org/fhir", dataProvider)));
      if (numTestCases != null) {
         // min 10, max 1000, default is 200 (in the CQL)
         Integer validTestCaseCount = numTestCases < 10 ? 10 : numTestCases > 1000 ? 1000 : numTestCases;
         EvaluationParams.Builder evaluationParamsBuilder = new EvaluationParams.Builder();
         evaluationParamsBuilder.setParameters(Map.of("NumberOfTests", validTestCaseCount));
         evaluationParamsBuilder.library(versionedIdentifier, new EvaluationParams.LibraryParams(
                 new ArrayList<>(Collections.singletonList(new EvaluationExpressionRef("TestDataGenerationResult")))));
         ExternalFunctionProvider externalFunctionProvider = new SystemExternalFunctionProvider(Collections.singletonList(PatientDataGeneratorService.class.getMethod("getRandomNumber")));
         environment.registerExternalFunctionProvider(versionedIdentifier, externalFunctionProvider);
         EvaluationResults results = new CqlEngine(environment).evaluate(evaluationParamsBuilder.build());
         throwIfEvaluationFailed(results, versionedIdentifier);
         Object result = getEvaluationResultValue(results, versionedIdentifier);
         Bundle bundle = (Bundle) result;
         String measureId = "cms104"; 
         appendGeneratedPatientGroup(bundle, numTestCases, measureId);
         return bundle;
      }
      ExternalFunctionProvider externalFunctionProvider = new SystemExternalFunctionProvider(Collections.singletonList(PatientDataGeneratorService.class.getMethod("getRandomNumber")));
      environment.registerExternalFunctionProvider(versionedIdentifier, externalFunctionProvider);
      EvaluationParams.Builder evaluationParamsBuilder = new EvaluationParams.Builder();
      evaluationParamsBuilder.library(versionedIdentifier, new EvaluationParams.LibraryParams(
              new ArrayList<>(Collections.singletonList(new EvaluationExpressionRef("TestDataGenerationResult")))));
      EvaluationResults results = new CqlEngine(environment).evaluate(evaluationParamsBuilder.build());
      throwIfEvaluationFailed(results, versionedIdentifier);
      Object result = getEvaluationResultValue(results, versionedIdentifier);

      Bundle bundle = (Bundle) result;
      String measureId = "cms104"; 
      appendGeneratedPatientGroup(bundle, numTestCases, measureId);
      return bundle;
   }

   private Object getEvaluationResultValue(EvaluationResults results, VersionedIdentifier versionedIdentifier) {
      EvaluationResult evaluationResult = results.getResultFor(versionedIdentifier);
      if (evaluationResult == null) {
         evaluationResult = results.getResultFor(new VersionedIdentifier().withId(versionedIdentifier.getId()));
      }
      if (evaluationResult == null) {
         throw new IllegalStateException("CQL evaluation did not return results for " +
                 formatIdentifier(versionedIdentifier) + ". Available result libraries: " +
                 formatIdentifiers(results.getResults().keySet()));
      }

      ExpressionResult expressionResult = evaluationResult.get("TestDataGenerationResult");
      if (expressionResult == null) {
         throw new IllegalStateException("CQL evaluation did not return expression TestDataGenerationResult for " +
                 formatIdentifier(versionedIdentifier) + ". Available expressions: " +
                 evaluationResult.getExpressionResults().keySet());
      }

      Object value = expressionResult.getValue();
      if (value == null) {
         throw new IllegalStateException("CQL expression TestDataGenerationResult returned null for " +
                 formatIdentifier(versionedIdentifier) + ".");
      }

      return value;
   }

   private void throwIfEvaluationFailed(EvaluationResults results, VersionedIdentifier versionedIdentifier) {
      if (!results.hasExceptions()) {
         return;
      }

      RuntimeException exception = results.getExceptionFor(versionedIdentifier);
      if (exception == null) {
         exception = results.getExceptionFor(new VersionedIdentifier().withId(versionedIdentifier.getId()));
      }
      if (exception == null && !results.getExceptions().isEmpty()) {
         exception = results.getExceptions().values().iterator().next();
      }
      if (exception != null) {
         throw exception;
      }

      throw new IllegalStateException("CQL evaluation failed without an exception detail.");
   }

   private String formatIdentifiers(Iterable<VersionedIdentifier> identifiers) {
      ArrayList<String> formattedIdentifiers = new ArrayList<>();
      for (VersionedIdentifier identifier : identifiers) {
         formattedIdentifiers.add(formatIdentifier(identifier));
      }
      return formattedIdentifiers.toString();
   }

   private String formatIdentifier(VersionedIdentifier identifier) {
      if (identifier == null) {
         return "<null>";
      }
      return identifier.getVersion() == null || identifier.getVersion().isBlank()
              ? identifier.getId()
              : identifier.getId() + "|" + identifier.getVersion();
   }

   private void appendGeneratedPatientGroup(Bundle bundle, int numTestCases, String measureId) {
      Group group = new Group()
              .setActive(true)
              .setType(Group.GroupType.PERSON)
              .setActual(true)
              .setName("Generated patients");
      String groupIdentifier = measureId + "-" + 
         Integer.toString(numTestCases) + 
         "N" + GENERATED_PATIENT_BASE;
      group.setId(groupIdentifier);

      for (Bundle.BundleEntryComponent entry : bundle.getEntry()) {
         Resource resource = entry.getResource();
         if (resource instanceof Patient) {
            String patientId = resource.getIdElement().getIdPart();
            if (patientId != null && !patientId.isBlank()) {
               group.addMember().setEntity(new Reference("Patient/" + patientId));
            }
         }
      }

      group.setQuantity(group.getMember().size());
      Bundle.BundleEntryComponent groupEntry = bundle.addEntry().setResource(group);
      groupEntry.getRequest()
              .setMethod(Bundle.HTTPVerb.PUT)
              .setUrl("Group/" + groupIdentifier);
   }

   /**
    * Gets random decimal. This is an external function used in the CQL logic.
    *
    * @return the random decimal
    */
   public static BigDecimal getRandomNumber() {
      return BigDecimal.valueOf(randomNumberGenerator.nextDouble());
   }
}
