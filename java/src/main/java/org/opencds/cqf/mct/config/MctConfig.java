package org.opencds.cqf.mct.config;

import ca.uhn.fhir.context.ConfigurationException;
import ca.uhn.fhir.context.FhirContext;
import ca.uhn.fhir.context.support.DefaultProfileValidationSupport;
import ca.uhn.fhir.repository.IRepository;
import ca.uhn.fhir.util.ClasspathUtil;
import ca.uhn.fhir.validation.FhirValidator;
import org.cqframework.cql.cql2elm.LibrarySourceProvider;
import org.hl7.fhir.common.hapi.validation.support.CachingValidationSupport;
import org.hl7.fhir.common.hapi.validation.support.CommonCodeSystemsTerminologyService;
import org.hl7.fhir.common.hapi.validation.support.InMemoryTerminologyServerValidationSupport;
import org.hl7.fhir.common.hapi.validation.support.SnapshotGeneratingValidationSupport;
import org.hl7.fhir.common.hapi.validation.support.ValidationSupportChain;
import org.hl7.fhir.common.hapi.validation.validator.FhirInstanceValidator;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.utilities.npm.NpmPackage;
import org.opencds.cqf.cql.engine.data.CompositeDataProvider;
import org.opencds.cqf.cql.engine.data.DataProvider;
import org.opencds.cqf.cql.engine.fhir.model.R4FhirModelResolver;
import org.opencds.cqf.cql.engine.fhir.retrieve.RestFhirRetrieveProvider;
import org.opencds.cqf.cql.engine.fhir.searchparam.SearchParameterResolver;
import org.opencds.cqf.cql.engine.model.ModelResolver;
import org.opencds.cqf.fhir.cql.cql2elm.content.RepositoryFhirLibrarySourceProvider;
import org.opencds.cqf.fhir.cql.cql2elm.util.LibraryVersionSelector;
import org.opencds.cqf.fhir.cr.measure.MeasureEvaluationOptions;
import org.opencds.cqf.fhir.cr.measure.r4.R4MeasureProcessor;
import org.opencds.cqf.fhir.utility.adapter.IAdapterFactory;
import org.opencds.cqf.fhir.utility.repository.InMemoryFhirRepository;
import org.opencds.cqf.mct.service.FacilityRegistrationService;
import org.springframework.beans.factory.annotation.Qualifier;
import org.opencds.cqf.mct.service.MeasureConfigurationService;
import org.opencds.cqf.mct.service.PatientSelectorService;
import org.opencds.cqf.mct.service.ReceivingSystemConfigurationService;
import org.opencds.cqf.mct.validation.MctNpmPackageValidationSupport;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

import java.io.IOException;
import java.util.Map;
import java.util.Objects;

@Configuration
@Import({ MctProperties.class })
public class MctConfig {

   @Bean
   public ModelResolver modelResolver() {
      return new R4FhirModelResolver();
   }

   @Bean
   public DataProvider dataProvider(FhirContext fhirContext, ModelResolver modelResolver) {
      RestFhirRetrieveProvider retrieveProvider = new RestFhirRetrieveProvider(
              new SearchParameterResolver(fhirContext), modelResolver,
              fhirContext.newRestfulGenericClient("http://localhost:8080/fhir"));
      return new CompositeDataProvider(modelResolver, retrieveProvider);
   }

   @Bean
   public IRepository contentRepository(FhirContext fhirContext, @Qualifier("measuresBundle") Bundle measuresBundle, @Qualifier("terminologyBundle") Bundle terminologyBundle) {
      Bundle combined = new Bundle().setType(Bundle.BundleType.COLLECTION);
      measuresBundle.getEntry().forEach(e -> combined.addEntry(e.copy()));
      terminologyBundle.getEntry().forEach(e -> combined.addEntry(e.copy()));
      return new InMemoryFhirRepository(fhirContext, combined);
   }

   @Bean
   public MeasureEvaluationOptions measureEvaluationOptions() {
      return MeasureEvaluationOptions.defaultOptions();
   }

   @Bean
   public R4MeasureProcessor measureProcessor(IRepository contentRepository, MeasureEvaluationOptions measureEvaluationOptions) {
      return new R4MeasureProcessor(contentRepository, measureEvaluationOptions);
   }

   @Bean
   public IAdapterFactory adapterFactory(FhirContext fhirContext) {
      return IAdapterFactory.forFhirContext(fhirContext);
   }

   @Bean
   public LibraryVersionSelector libraryVersionSelector(IAdapterFactory adapterFactory) {
      return new LibraryVersionSelector(adapterFactory);
   }

   @Bean
   public LibrarySourceProvider repositoryFhirLibrarySourceProvider(
           IRepository contentRepository, IAdapterFactory adapterFactory, LibraryVersionSelector libraryVersionSelector) {
      return new RepositoryFhirLibrarySourceProvider(contentRepository, adapterFactory, libraryVersionSelector);
   }

   @Bean
   public MctNpmPackageValidationSupport mctNpmPackageValidationSupport(
           FhirContext fhirContext, MctProperties properties) throws IOException {
      MctNpmPackageValidationSupport validationSupport = new MctNpmPackageValidationSupport(fhirContext);
      NpmPackage basePackage;
      for (Map.Entry<String, MctProperties.ImplementationGuide> igs : properties.getImplementationGuides().entrySet()) {
         if (igs.getValue().getUrl() != null) {
            basePackage = NpmPackage.fromUrl(igs.getValue().getUrl());
         }
         else if (properties.getPackageServerUrl() == null) {
            throw new ConfigurationException("The package_server_url property must be present if the implementationguides url property is absent");
         }
         else if (igs.getValue().getName() != null && igs.getValue().getVersion() != null) {
            basePackage = NpmPackage.fromUrl(properties.getPackageServerUrl() + "/" + igs.getValue().getName() + "/" + igs.getValue().getVersion());
         }
         else if (igs.getValue().getName() != null) {
            basePackage = NpmPackage.fromUrl(properties.getPackageServerUrl() + "/" + igs.getValue().getName());
         }
         else {
            throw new ConfigurationException("The implementationguides property must include either a url or a name with an optional version");
         }
         validationSupport.loadPackage(basePackage);
         if (properties.getInstallTransitiveIgDependencies()) {
            for (String dependency : basePackage.dependencies()) {
               if (properties.getPackageServerUrl() == null) {
                  throw new ConfigurationException("The package_server_url property must be present to resolve implementationguides dependencies");
               }

               validationSupport.loadPackage(NpmPackage.fromUrl(properties.getPackageServerUrl() + "/" + dependency.replace("#", "/")));
            }
         }
      }

      return validationSupport;
   }

   @Bean
   public ValidationSupportChain validationSupportChain(
           MctNpmPackageValidationSupport mctNpmPackageValidationSupport, FhirContext fhirContext) {
      return new ValidationSupportChain(
              mctNpmPackageValidationSupport,
              new CommonCodeSystemsTerminologyService(fhirContext),
              new DefaultProfileValidationSupport(fhirContext),
              new InMemoryTerminologyServerValidationSupport(fhirContext),
              new SnapshotGeneratingValidationSupport(fhirContext)
      );
   }

   @Bean
   public FhirValidator fhirValidator(FhirContext fhirContext, ValidationSupportChain validationSupportChain) {
      CachingValidationSupport validationSupport = new CachingValidationSupport(validationSupportChain);
      FhirValidator validator = fhirContext.newValidator();
      FhirInstanceValidator instanceValidator = new FhirInstanceValidator(validationSupport);
      validator.registerValidatorModule(instanceValidator);
      return validator;
   }

   @Bean
   public FacilityRegistrationService facilityRegistrationService() {
      return new FacilityRegistrationService();
   }

   @Bean
   public MeasureConfigurationService measureConfigurationService() {
      return new MeasureConfigurationService();
   }

   @Bean
   public ReceivingSystemConfigurationService receivingSystemConfigurationService() {
      return new ReceivingSystemConfigurationService();
   }

   @Bean
   public PatientSelectorService patientSelectorService() {
      return new PatientSelectorService();
   }

   @Bean
   public String pathToConfigurationResources() {
      return Objects.requireNonNull(ClasspathUtil.class.getClassLoader().getResource("configuration")).getPath();
   }

   @Bean
   public Bundle receivingSystemsBundle(FhirContext fhirContext) {
      return fhirContext.newJsonParser().parseResource(Bundle.class,
              ClasspathUtil.loadResourceAsStream("classpath:configuration/receiving-system/receiving-system-bundle.json"));
   }

   @Bean
   public Bundle facilitiesBundle(FhirContext fhirContext) {
      return fhirContext.newJsonParser().parseResource(Bundle.class,
              ClasspathUtil.loadResourceAsStream("classpath:configuration/facilities/facilities-bundle.json"));
   }

   @Bean
   public Bundle measuresBundle(FhirContext fhirContext) {
      return fhirContext.newJsonParser().parseResource(Bundle.class,
              ClasspathUtil.loadResourceAsStream("classpath:configuration/measures/measures-bundle.json"));
   }

   @Bean
   public Bundle terminologyBundle(FhirContext fhirContext) {
      return fhirContext.newJsonParser().parseResource(Bundle.class,
              ClasspathUtil.loadResourceAsStream("classpath:configuration/terminology/terminology-bundle.json"));
   }
}
