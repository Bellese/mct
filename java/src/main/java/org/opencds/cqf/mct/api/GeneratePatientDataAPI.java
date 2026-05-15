package org.opencds.cqf.mct.api;

import ca.uhn.fhir.rest.annotation.Operation;
import ca.uhn.fhir.rest.annotation.OperationParam;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.IntegerType;
import org.hl7.fhir.r4.model.StringType;
import org.opencds.cqf.mct.config.MctConstants;
import org.opencds.cqf.mct.service.PatientDataGeneratorService;

import java.io.IOException;

/**
 * The Generate Patient Data API.
 */
public class GeneratePatientDataAPI {

   /**
    * Generate the patient data bundle.
    *
    * @param numTestCases the number of test cases to generate (200 by default)
    * @param measureRef the measure for which to produce test cases (CMS104 by default)
    * @return a bundle of test cases
    * @throws IOException           when the cql file does not exist or is malformed
    * @throws NoSuchMethodException when the external function method is not present
    */
   @Operation(name = MctConstants.GENERATE_PATIENT_DATA_OPERATION_NAME, idempotent = true)
   public Bundle generatePatientData(
      @OperationParam(name = "numTestCases") IntegerType numTestCases,
      @OperationParam(name = "measureRef") StringType measureRef
   ) throws IOException, NoSuchMethodException {
      if (numTestCases == null) numTestCases = new IntegerType(200);
      if (measureRef == null) measureRef = new StringType("CMS104");
      return new PatientDataGeneratorService().generatePatientData(numTestCases.getValue(), measureRef.getValue());
   }
}
