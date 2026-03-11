package org.opencds.cqf.mct.service;

import ca.uhn.fhir.context.FhirContext;
import ca.uhn.fhir.util.OperationOutcomeUtil;
import org.hl7.fhir.exceptions.FHIRException;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.Endpoint;
import org.hl7.fhir.r4.model.Location;
import org.hl7.fhir.r4.model.OperationOutcome;
import org.hl7.fhir.r4.model.Organization;
import org.hl7.fhir.r4.model.Resource;
import org.opencds.cqf.mct.SpringContext;
import org.opencds.cqf.mct.api.FacilityRegistrationAPI;
import org.opencds.cqf.mct.config.MctConstants;
import org.opencds.cqf.mct.util.BundleHelper;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.List;

/**
 * The Facility Registration Service used by the {@link org.opencds.cqf.mct.api.FacilityRegistrationAPI}.
 */
public class FacilityRegistrationService {

   private final Bundle facilitiesBundle;
   private final String facilitiesBundlePath;

   /**
    * Instantiates a new Facility Registration Service.
    */
   public FacilityRegistrationService(String facilitiesBundlePath) {
      this.facilitiesBundlePath = facilitiesBundlePath;
      facilitiesBundle = SpringContext.getBean("facilitiesBundle", Bundle.class);
   }

   /**
    * The $list-organizations operation logic.
    * @see FacilityRegistrationAPI#listOrganizations()
    *
    * @return a bundle with all the configured <a href="http://hl7.org/fhir/organization.html">Organization</a> resources
    */
   public Bundle listOrganizations() {
      Bundle orgs = new Bundle().setType(Bundle.BundleType.COLLECTION);
      BundleHelper.listResources(facilitiesBundle, Organization.class)
              .forEach(x -> orgs.addEntry().setResource(x));
      return orgs;
   }

   /**
    * The $list-facilities operation logic.
    * @see  FacilityRegistrationAPI#listFacilities(String)
    *
    * @param organizationId the organization id
    * @return the bundle of all facilities (<a href="http://hl7.org/fhir/location.html">Location</a> resources)
    * referencing the <a href="http://hl7.org/fhir/organization.html">Organization</a>
    */
   public Bundle listFacilities(String organizationId) {
      Bundle facilities = new Bundle().setType(Bundle.BundleType.COLLECTION);
      getLocations(organizationId).forEach(x -> facilities.addEntry().setResource(x));
      return facilities;
   }

   /**
    * Gets the <a href="http://hl7.org/fhir/location.html">Location</a> resources.
    *
    * @see PatientSelectorService#getPatientsForOrganization(String)
    * @param organizationId the organization id
    * @return either all the configured facilities (<a href="http://hl7.org/fhir/location.html">Location</a> resources)
    * or the configured facilities referencing the <a href="http://hl7.org/fhir/organization.html">Organization</a>
    */
   public List<Location> getLocations(String organizationId) {
      if (organizationId == null) {
         return BundleHelper.listResources(facilitiesBundle, Location.class);
      }
      if (organizationId.startsWith("Organization/")) {
         organizationId = organizationId.replace("Organization/", "");
      }
      return BundleHelper.filterLocationsByOrganization(facilitiesBundle, organizationId);
   }

   /**
    * Retrieves the specified facility (<a href="http://hl7.org/fhir/location.html">Location</a> resources).
    *
    * @param locationId the location id
    * @return the facility
    */
   public Location getFacility(String locationId) {
      if (locationId.startsWith("Location/")) {
         locationId = locationId.replace("Location/", "");
      }
      return BundleHelper.findById(facilitiesBundle, Location.class, locationId);
   }

   /**
    * Gets the facility url.
    *
    * @see FacilityDataService
    * @param facilityId the facility id
    * @return the facility url
    */
   public String getFacilityUrl(String facilityId) {
      Location facility = getFacility(facilityId);
      for (Resource containedResource : facility.getContained()) {
         if (containedResource instanceof Endpoint) {
            Endpoint endpoint = (Endpoint) containedResource;
            if (endpoint.hasConnectionType() && endpoint.getConnectionType().hasCode() && endpoint.hasAddress()
                    && endpoint.getConnectionType().getCode().equals(MctConstants.FHIR_REST_CONNECTION_TYPE)) {
               return endpoint.getAddress();
            }
         }
      }
      throw new FHIRException(MctConstants.MISSING_FHIR_REST_ENDPOINT);
   }

   /**
    * Registers a new facility and persists the facilities bundle.
    *
    * @param location the Location resource to add
    * @return an OperationOutcome confirming success
    */
   public OperationOutcome registerFacility(Location location) {
      facilitiesBundle.addEntry().setResource(location);
      persistFacilitiesBundle();
      return successOutcome("Facility registered: " + location.getName());
   }

   /**
    * Updates an existing facility and persists the facilities bundle.
    *
    * @param location the Location resource with updated fields (matched by id)
    * @return an OperationOutcome confirming success
    */
   public OperationOutcome updateFacility(Location location) {
      String id = location.getIdElement().getIdPart();
      List<Bundle.BundleEntryComponent> entries = facilitiesBundle.getEntry();
      for (int i = 0; i < entries.size(); i++) {
         Resource r = entries.get(i).getResource();
         if (r instanceof Location && id.equals(r.getIdElement().getIdPart())) {
            entries.get(i).setResource(location);
            persistFacilitiesBundle();
            return successOutcome("Facility updated: " + location.getName());
         }
      }
      throw new FHIRException("Facility not found: " + id);
   }

   /**
    * Deletes a facility and persists the facilities bundle.
    *
    * @param facilityId the id of the Location resource to remove
    * @return an OperationOutcome confirming success
    */
   public OperationOutcome deleteFacility(String facilityId) {
      final String id = facilityId;
      boolean removed = facilitiesBundle.getEntry().removeIf(
              e -> e.getResource() instanceof Location && id.equals(e.getResource().getIdElement().getIdPart()));
      if (!removed) {
         throw new FHIRException("Facility not found: " + id);
      }
      persistFacilitiesBundle();
      return successOutcome("Facility deleted: " + id);
   }

   private void persistFacilitiesBundle() {
      try {
         File file = new File(facilitiesBundlePath);
         file.getParentFile().mkdirs();
         String json = SpringContext.getBean(FhirContext.class).newJsonParser().setPrettyPrint(true)
                 .encodeResourceToString(facilitiesBundle);
         Files.writeString(file.toPath(), json);
      } catch (IOException e) {
         throw new RuntimeException("Failed to persist facilities bundle: " + e.getMessage(), e);
      }
   }

   private OperationOutcome successOutcome(String message) {
      OperationOutcome outcome = new OperationOutcome();
      OperationOutcomeUtil.addIssue(SpringContext.getBean(FhirContext.class), outcome,
              MctConstants.SEVERITY_INFORMATION, message, null, MctConstants.CODE_INFORMATIONAL);
      return outcome;
   }
}
