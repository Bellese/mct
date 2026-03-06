package org.opencds.cqf.mct.service;

import ca.uhn.fhir.util.ClasspathUtil;
import org.cqframework.cql.cql2elm.CqlCompilerOptions;
import org.cqframework.cql.cql2elm.CqlTranslator;
import org.cqframework.cql.cql2elm.DefaultLibrarySourceProvider;
import org.cqframework.cql.cql2elm.LibraryManager;
import org.cqframework.cql.cql2elm.ModelManager;
import org.hl7.elm.r1.VersionedIdentifier;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.IntegerType;
import org.opencds.cqf.cql.engine.data.DataProvider;
import org.opencds.cqf.cql.engine.data.ExternalFunctionProvider;
import org.opencds.cqf.cql.engine.data.SystemExternalFunctionProvider;
import org.opencds.cqf.cql.engine.execution.CqlEngine;
import org.opencds.cqf.cql.engine.execution.Environment;
import org.opencds.cqf.cql.engine.execution.EvaluationParams;
import org.opencds.cqf.cql.engine.execution.EvaluationResults;
import org.opencds.cqf.mct.SpringContext;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.Random;

/**
 * The Patient Data Generator Service logic for the {@link org.opencds.cqf.mct.api.GeneratePatientDataAPI}.
 */
public class PatientDataGeneratorService {
   private final DataProvider dataProvider;
   private static final Random randomNumberGenerator = new Random();

   /**
    * Instantiates a new Patient Data Generator Service.
    */
   public PatientDataGeneratorService() {
      dataProvider = SpringContext.getBean(DataProvider.class);
   }

   /**
    * Generate test cases for the CMS104 pilot measure
    *
    * @see org.opencds.cqf.mct.api.GeneratePatientDataAPI#generatePatientData(IntegerType)
    * @param numTestCases the number of test cases to generate (200 by default)
    * @return the bundle of test cases containing the patient data
    * @throws IOException           when the cql file does not exist or is malformed
    * @throws NoSuchMethodException when the external function method is not present
    */
   public Bundle generatePatientData(Integer numTestCases) throws IOException, NoSuchMethodException {
      VersionedIdentifier versionedIdentifier =
              new VersionedIdentifier().withId("CMS104TestDataGenerator").withVersion("1.0.0");

      File libDir = new File(Objects.requireNonNull(ClasspathUtil.class.getClassLoader().getResource(
              "configuration/patient-data-gen-libraries")).getFile());
      String cqlFilePath = new File(libDir, "CMS104TestDataGenerator.cql").getAbsolutePath();

      CqlCompilerOptions compilerOptions = CqlCompilerOptions.defaultOptions();
      ModelManager modelManager = new ModelManager();
      LibraryManager libraryManager = new LibraryManager(modelManager, compilerOptions);
      libraryManager.getLibrarySourceLoader().registerProvider(
              new DefaultLibrarySourceProvider(new kotlinx.io.files.Path(libDir)));

      // Translate CQL — LibraryManager caches the compiled library
      CqlTranslator.fromFile(cqlFilePath, libraryManager);

      // Build Environment and CqlEngine
      Map<String, DataProvider> dataProviders = new HashMap<>();
      dataProviders.put("http://hl7.org/fhir", dataProvider);
      Environment environment = new Environment(libraryManager, dataProviders, null);

      ExternalFunctionProvider externalFunctionProvider = new SystemExternalFunctionProvider(
              Collections.singletonList(PatientDataGeneratorService.class.getMethod("getRandomNumber")));
      environment.registerExternalFunctionProvider(versionedIdentifier, externalFunctionProvider);

      CqlEngine engine = new CqlEngine(environment);

      // Build evaluation parameters
      Map<String, Object> parameters = new HashMap<>();
      if (numTestCases != null) {
         Integer validTestCaseCount = numTestCases < 10 ? 10 : numTestCases > 200 ? 200 : numTestCases;
         parameters.put("NumberOfTests", validTestCaseCount);
      }

      EvaluationParams.LibraryParams.Builder libParamsBuilder = new EvaluationParams.LibraryParams.Builder();
      libParamsBuilder.expressions("TestDataGenerationResult");
      EvaluationParams.LibraryParams libParams = libParamsBuilder.build();

      EvaluationParams.Builder paramsBuilder = new EvaluationParams.Builder();
      paramsBuilder.setParameters(parameters);
      paramsBuilder.library(versionedIdentifier, libParams);
      EvaluationParams evalParams = paramsBuilder.build();

      EvaluationResults results = engine.evaluate(evalParams);
      Object value = results.getOnlyResultOrThrow().get("TestDataGenerationResult").getValue();

      return (Bundle) value;
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
