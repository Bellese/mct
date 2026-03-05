package org.opencds.cqf.mct.service;

import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.Measure;
import org.opencds.cqf.mct.SpringContext;
import org.opencds.cqf.mct.api.MeasureConfigurationAPI;
import org.opencds.cqf.mct.util.BundleHelper;

/**
 * The Measure Configuration Service logic for {@link org.opencds.cqf.mct.api.MeasureConfigurationAPI}.
 */
public class MeasureConfigurationService {

   private final Bundle measuresBundle;

   /**
    * Instantiates a new Measure Configuration Service.
    */
   public MeasureConfigurationService() {
      measuresBundle = SpringContext.getBean("measuresBundle", Bundle.class);
   }

   /**
    * The $list-measures operation logic.
    *
    * @see MeasureConfigurationAPI#listMeasures()
    * @return the configured measures in a bundle
    */
   public Bundle listMeasures() {
      Bundle measures = new Bundle().setType(Bundle.BundleType.COLLECTION);
      BundleHelper.listResources(measuresBundle, Measure.class)
              .forEach(x -> measures.addEntry().setResource(x));
      return measures;
   }

   /**
    * Gets the specified <a href="http://hl7.org/fhir/measure.html">Measure</a> resource.
    *
    * @param measureId the measure id
    * @return the measure or null if the measure is not present
    */
   public Measure getMeasure(String measureId) {
      return BundleHelper.findById(measuresBundle, Measure.class, measureId);
   }

}
