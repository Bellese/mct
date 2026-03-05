package org.opencds.cqf.mct.service;

import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.Endpoint;
import org.opencds.cqf.mct.SpringContext;
import org.opencds.cqf.mct.util.BundleHelper;

/**
 * The Receiving System Configuration Service for the {@link org.opencds.cqf.mct.api.ReceivingSystemConfigurationAPI}.
 */
public class ReceivingSystemConfigurationService {

   private final Bundle receivingSystemsBundle;

   /**
    * Instantiates a new Receiving System Configuration Service.
    */
   public ReceivingSystemConfigurationService() {
      receivingSystemsBundle = SpringContext.getBean("receivingSystemsBundle", Bundle.class);
   }

   /**
    * The $list-receiving-systems operation logic.
    *
    * @return a bundle of receiving system <a href="http://hl7.org/fhir/endpoint.html">Endpoint</a> resources
    */
   public Bundle listReceivingSystems() {
      Bundle endpoints = new Bundle().setType(Bundle.BundleType.COLLECTION);
      BundleHelper.listResources(receivingSystemsBundle, Endpoint.class)
              .forEach(x -> endpoints.addEntry().setResource(x));
      return endpoints;
   }

}
