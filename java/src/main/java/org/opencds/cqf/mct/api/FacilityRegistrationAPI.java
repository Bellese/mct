package org.opencds.cqf.mct.api;

import ca.uhn.fhir.rest.annotation.Operation;
import ca.uhn.fhir.rest.annotation.OperationParam;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.Location;
import org.hl7.fhir.r4.model.OperationOutcome;
import org.opencds.cqf.mct.SpringContext;
import org.opencds.cqf.mct.config.MctConstants;
import org.opencds.cqf.mct.service.FacilityRegistrationService;

/**
 * The Facility Registration API.
 */
public class FacilityRegistrationAPI {
   private final FacilityRegistrationService facilityRegistrationService;

   /**
    * Instantiates a new Facility Registration API.
    */
   public FacilityRegistrationAPI() {
      facilityRegistrationService = SpringContext.getBean(FacilityRegistrationService.class);
   }

   /**
    * The $list-organizations operation.
    *
    * @return a bundle with all the configured <a href="http://hl7.org/fhir/organization.html">Organization</a> resources
    */
   @Operation(name = MctConstants.LIST_ORGANIZATIONS_OPERATION_NAME, idempotent = true)
   public Bundle listOrganizations() {
      return facilityRegistrationService.listOrganizations();
   }

   /**
    * The $list-facilities operation.
    *
    * @param organizationId the organization id
    * @return a bundle with all facilities (<a href="http://hl7.org/fhir/location.html">Location</a> resources) referencing the <a href="http://hl7.org/fhir/organization.html">Organization</a>
    */
   @Operation(name = MctConstants.LIST_FACILITIES_OPERATION_NAME, idempotent = true)
   public Bundle listFacilities(@OperationParam(name = MctConstants.LIST_FACILITIES_PARAM) String organizationId) {
      return facilityRegistrationService.listFacilities(organizationId);
   }

   /**
    * The $register-facility operation. Adds a new facility and persists the bundle.
    *
    * @param facility the <a href="http://hl7.org/fhir/location.html">Location</a> resource to register
    * @return an OperationOutcome confirming success
    */
   @Operation(name = MctConstants.REGISTER_FACILITY_OPERATION_NAME)
   public OperationOutcome registerFacility(@OperationParam(name = MctConstants.FACILITY_PARAM) Location facility) {
      return facilityRegistrationService.registerFacility(facility);
   }

   /**
    * The $update-facility operation. Updates an existing facility and persists the bundle.
    *
    * @param facility the <a href="http://hl7.org/fhir/location.html">Location</a> resource with updated fields
    * @return an OperationOutcome confirming success
    */
   @Operation(name = MctConstants.UPDATE_FACILITY_OPERATION_NAME)
   public OperationOutcome updateFacility(@OperationParam(name = MctConstants.FACILITY_PARAM) Location facility) {
      return facilityRegistrationService.updateFacility(facility);
   }

   /**
    * The $delete-facility operation. Removes a facility and persists the bundle.
    *
    * @param facilityId the id of the facility to remove
    * @return an OperationOutcome confirming success
    */
   @Operation(name = MctConstants.DELETE_FACILITY_OPERATION_NAME)
   public OperationOutcome deleteFacility(@OperationParam(name = MctConstants.FACILITY_ID_PARAM) String facilityId) {
      return facilityRegistrationService.deleteFacility(facilityId);
   }
}
