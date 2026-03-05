package org.opencds.cqf.mct.util;

import ca.uhn.fhir.context.FhirContext;
import ca.uhn.fhir.util.BundleUtil;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.Location;
import org.hl7.fhir.r4.model.Resource;

import java.util.List;
import java.util.stream.Collectors;

public class BundleHelper {

   private static final FhirContext FHIR_CONTEXT = FhirContext.forR4();

   public static <T extends Resource> List<T> listResources(Bundle bundle, Class<T> resourceType) {
      return BundleUtil.toListOfResourcesOfType(FHIR_CONTEXT, bundle, resourceType);
   }

   public static <T extends Resource> T findById(Bundle bundle, Class<T> resourceType, String id) {
      return listResources(bundle, resourceType).stream()
              .filter(r -> id.equals(r.getIdElement().getIdPart()))
              .findFirst()
              .orElse(null);
   }

   public static List<Location> filterLocationsByOrganization(Bundle bundle, String organizationId) {
      return listResources(bundle, Location.class).stream()
              .filter(loc -> loc.hasManagingOrganization()
                      && loc.getManagingOrganization().getReferenceElement().getIdPart().equals(organizationId))
              .collect(Collectors.toList());
   }
}
