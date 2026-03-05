package org.opencds.cqf.mct.service;

import ca.uhn.fhir.repository.IRepository;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.Group;
import org.hl7.fhir.r4.model.Measure;
import org.hl7.fhir.r4.model.MeasureReport;
import org.hl7.fhir.r4.model.Period;
import org.opencds.cqf.cql.engine.execution.CqlEngine;
import org.opencds.cqf.fhir.cql.Engines;
import org.opencds.cqf.fhir.cr.measure.MeasureEvaluationOptions;
import org.opencds.cqf.fhir.cr.measure.r4.R4MeasureProcessor;
import org.opencds.cqf.mct.SpringContext;

import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

/**
 * The Measure Evaluation Service.
 */
public class MeasureEvaluationService {
   private final Measure measure;
   private final MeasureDataRequirementService measureDataRequirementService;
   private final R4MeasureProcessor measureProcessor;
   private final IRepository contentRepository;
   private final MeasureEvaluationOptions evaluationOptions;
   private final ZonedDateTime periodStart;
   private final ZonedDateTime periodEnd;

   /**
    * Instantiates a new Measure Evaluation Service.
    *
    * @param measureId the measure id
    * @param period    the measurement period
    */
   public MeasureEvaluationService(String measureId, Period period) {
      measure = SpringContext.getBean(MeasureConfigurationService.class).getMeasure(measureId);
      measureDataRequirementService = new MeasureDataRequirementService(measure);
      measureProcessor = SpringContext.getBean(R4MeasureProcessor.class);
      contentRepository = SpringContext.getBean(IRepository.class);
      evaluationOptions = SpringContext.getBean(MeasureEvaluationOptions.class);
      periodStart = period.getStart().toInstant().atZone(ZoneId.systemDefault());
      periodEnd = period.getEnd().toInstant().atZone(ZoneId.systemDefault());
   }

   /**
    * Gets the measure url.
    *
    * @return the measure url
    */
   public String getMeasureUrl() {
      return measure.getUrl();
   }

   /**
    * Gets the measure data requirements service.
    *
    * @see MeasureDataRequirementService
    * @return the measure data requirements service
    */
   public MeasureDataRequirementService getMeasureDataRequirementsService() {
      return measureDataRequirementService;
   }

   /**
    * Gets the patient report.
    *
    * @see PatientDataService#resolvePatientBundles(MeasureEvaluationService)
    * @param patientBundle the patient bundle
    * @return the patient <a href="http://hl7.org/fhir/measurereport.html">MeasureReport</a>
    */
   public MeasureReport getPatientReport(GatherService.PatientBundle patientBundle) {
      return evaluate(Collections.singletonList("Patient/" + patientBundle.getPatientId()), patientBundle.getPatientData());
   }

   /**
    * Gets the population report.
    *
    * @see GatherService#gather(Group, List, String, Period)
    * @param patientIds         the patient ids
    * @param patientDataBundles the patient data bundles
    * @return the population <a href="http://hl7.org/fhir/measurereport.html">MeasureReport</a>
    */
   public MeasureReport getPopulationReport(List<String> patientIds, List<GatherService.PatientBundle> patientDataBundles) {
      return evaluate(patientIds, new Bundle().setEntry(patientDataBundles.stream().map(
              bundle -> bundle.getPatientData().getEntry()).flatMap(List::stream).collect(Collectors.toList())));
   }

   /**
    * Evaluate the patient-level and population-level <a href="http://hl7.org/fhir/measure.html">Measure</a>.
    *
    * @param patientIds  the patient ids
    * @param patientData the patient data
    * @return the result of the $evaluate-measure operation (<a href="http://hl7.org/fhir/measurereport.html">MeasureReport</a>)
    */
   public MeasureReport evaluate(List<String> patientIds, Bundle patientData) {
      CqlEngine engine = Engines.forRepository(
              contentRepository,
              evaluationOptions.getEvaluationSettings(),
              patientData);
      return measureProcessor.evaluateMeasure(
              measure, periodStart, periodEnd, null, patientIds, null, engine, null);
   }
}
