package org.opencds.cqf.mct.util;

import org.hl7.fhir.r4.model.Parameters;
import org.hl7.fhir.r4.model.Resource;
import org.hl7.fhir.r4.model.Type;

/**
 * Utility methods for building FHIR R4 Parameters resources.
 * Replaces the deprecated org.opencds.cqf.cql.evaluator.fhir.util.r4.Parameters helpers.
 */
public final class ParametersUtil {

   private ParametersUtil() {}

   public static Parameters parameters(Parameters.ParametersParameterComponent... parts) {
      Parameters parameters = new Parameters();
      for (Parameters.ParametersParameterComponent part : parts) {
         parameters.addParameter(part);
      }
      return parameters;
   }

   public static Parameters.ParametersParameterComponent part(String name, Resource resource) {
      return new Parameters.ParametersParameterComponent().setName(name).setResource(resource);
   }

   public static Parameters.ParametersParameterComponent part(String name, Type value) {
      return new Parameters.ParametersParameterComponent().setName(name).setValue(value);
   }

   public static Parameters.ParametersParameterComponent part(String name, String value) {
      return new Parameters.ParametersParameterComponent().setName(name).setValue(new org.hl7.fhir.r4.model.StringType(value));
   }
}
