library CMS122TestDataGenerator2026 version '1.0.0'

using FHIR version '4.0.1'

parameter MeasurementPeriod default Interval[@2026-01-01T00:00:00.000Z, @2027-01-01T00:00:00.000Z)
parameter NumberOfTests default 200
parameter MeasureId default 'CMS122'

define NumberOfTestCases:
    (expand { Interval[ToQuantity(0), ToQuantity(NumberOfTests)] } per ToQuantity(1)) expandResult
        return Truncate((start of expandResult).value)

define function GetNumberOfTestCasesList(count Integer):
    (expand { Interval[ToQuantity(0), ToQuantity(count)] } per ToQuantity(1)) expandResult
        return Truncate((start of expandResult).value)

define InNumeratorCount:
    GetNumberOfTestCasesList(Truncate(Round(Length(NumberOfTestCases) * 0.45)))

define OtherPopulationsCount:
    GetNumberOfTestCasesList(Truncate(Round(Length(NumberOfTestCases) * 0.1)))

define function BuildTestCaseId(population String, count Integer):
    MeasureId + '-' + ToString(NumberOfTests) + 'N-' + population + '-' + ToString(count)

define function getRandomNumber() returns Decimal : external

define function RandomNumberInRange(low Integer, high Integer):
    Truncate(Round(getRandomNumber() * ( high - low ) + low))

define RandomMonth:
    RandomNumberInRange(1, 12)

define RandomDay:
    RandomNumberInRange(1, 28)

define EvaluationTimezone:
    timezoneoffset from Now()

define ProviderId:
    'cms122-provider'

define ProviderReference:
    'Practitioner/' + ProviderId

define MaleFirstName_10:
    { 'Lucas', 'Markell', 'Leland', 'Thomas', 'Patrick', 'Johnny', 'Jude', 'Shane', 'Parker', 'Julian' }

define FemaleFirstName_10:
    { 'Lilian', 'Carrie', 'Meagan', 'Rhonda', 'Nicole', 'Jamie', 'Sara', 'Ayesha', 'Layla', 'Maeve' }

define LastNames_10:
    { 'Galvez', 'Najera', 'Hughes', 'Lane', 'Mejia', 'Robinson', 'Anderson', 'Ramirez', 'Rogers', 'Kaur' }

define RandomMaleFirstName:
    MaleFirstName_10[RandomNumberInRange(0, 9)]

define RandomFemaleFirstName:
    FemaleFirstName_10[RandomNumberInRange(0, 9)]

define RandomLastName:
    LastNames_10[RandomNumberInRange(0, 9)]

define DiabetesCodes:
    Tuple {
        system: 'http://snomed.info/sct',
        codes: { '44054006', '46635009', '73211009' }
    }

define OfficeVisitCodes:
    {
        Tuple {
            system: 'http://www.ama-assn.org/go/cpt',
            codes: { '99202', '99203', '99204', '99212', '99213' }
        },
        Tuple {
            system: 'http://snomed.info/sct',
            codes: { '185349003', '185463005', '185465003' }
        }
    }

define HbA1cLaboratoryTestCodes:
    Tuple {
        system: 'http://loinc.org',
        codes: { '4548-4', '17856-6', '17855-8', '4549-2', '96595-4' }
    }

define GlucoseManagementIndicatorCodes:
    Tuple {
        system: 'http://loinc.org',
        codes: { '97506-0' }
    }

define HospiceCareAmbulatoryCodes:
    Tuple {
        system: 'http://snomed.info/sct',
        codes: { '385763009' }
    }

define PalliativeCareInterventionCodes:
    Tuple {
        system: 'http://snomed.info/sct',
        codes: { '103735009' }
    }

define HousingStatusCode:
    Tuple {
        system: 'http://loinc.org',
        code: '71802-3'
    }

define LivesInNursingHomeCode:
    Tuple {
        system: 'http://snomed.info/sct',
        code: '160734000'
    }

define RaceCategoryCodes:
    {
        Tuple { raceCategoryCode: '1002-5', raceCategoryDisplay: 'American Indian or Alaska Native' },
        Tuple { raceCategoryCode: '2028-9', raceCategoryDisplay: 'Asian' },
        Tuple { raceCategoryCode: '2054-5', raceCategoryDisplay: 'Black or African American' },
        Tuple { raceCategoryCode: '2076-8', raceCategoryDisplay: 'Native Hawaiian or Other Pacific Islander' },
        Tuple { raceCategoryCode: '2106-3', raceCategoryDisplay: 'White' }
    }

define EthnicityCategoryCodes:
    {
        Tuple { ethnicityCategoryCode: '2135-1', ethnicityCategoryDisplay: 'Hispanic or Latino' },
        Tuple { ethnicityCategoryCode: '2186-5', ethnicityCategoryDisplay: 'Non Hispanic or Latino' }
    }

define function GetRandomDateTimeDuringMeasurementPeriod():
    start of MeasurementPeriod + ToQuantity(ToString(RandomNumberInRange(1, 330)) + ' days')

define function BuildRandomTestCase(TestCaseId String, count Integer, PatientReference String, IsMale Boolean, IsOlder Boolean):
    TestCaseId ID
        let PatientFirstName: if IsMale then RandomMaleFirstName else RandomFemaleFirstName,
            PatientLastName: RandomLastName,
            PatientGender: if IsMale then 'male' else 'female',
            PatientBirthDate: if IsOlder then Date(RandomNumberInRange(1940, 1959), RandomMonth, RandomDay) else Date(RandomNumberInRange(1965, 1995), RandomMonth, RandomDay),
            AdultPatient: BuildPatient(TestCaseId, PatientFirstName, PatientLastName, PatientGender, PatientBirthDate, count),
            DiabetesConditionReference: 'Condition/' + TestCaseId + '-diabetes',
            EncounterReference: 'Encounter/' + TestCaseId + '-qualifying',
            DiabetesCode: DiabetesCodes.codes[RandomNumberInRange(0, Length(DiabetesCodes.codes) - 1)],
            ConditionOnset: start of MeasurementPeriod - ToQuantity(ToString(RandomNumberInRange(30, 365)) + ' days'),
            DiabetesCondition: BuildCondition(TestCaseId + '-diabetes', 'http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-condition-encounter-diagnosis', DiabetesCodes.system, DiabetesCode, PatientReference, EncounterReference, ConditionOnset),
            RandomEncounterCodeSet: OfficeVisitCodes[RandomNumberInRange(0, Length(OfficeVisitCodes) - 1)],
            EncounterCode: RandomEncounterCodeSet.codes[RandomNumberInRange(0, Length(RandomEncounterCodeSet.codes) - 1)],
            EncounterPeriodEnd: GetRandomDateTimeDuringMeasurementPeriod(),
            EncounterPeriodStart: EncounterPeriodEnd - ToQuantity(ToString(RandomNumberInRange(0, 3)) + ' days'),
            QualifyingEncounter: BuildEncounter(TestCaseId + '-qualifying', 'finished', 'AMB', RandomEncounterCodeSet.system, EncounterCode, PatientReference, EncounterPeriodStart, EncounterPeriodEnd, DiabetesConditionReference),
            GlycemicAssessmentDate: EncounterPeriodEnd,
            HbA1cCode: HbA1cLaboratoryTestCodes.codes[RandomNumberInRange(0, Length(HbA1cLaboratoryTestCodes.codes) - 1)],
            ControlledHbA1cObservation: BuildLaboratoryObservation(TestCaseId + '-hba1c-controlled', HbA1cLaboratoryTestCodes.system, HbA1cCode, PatientReference, EncounterReference, GlycemicAssessmentDate, 7.0),
            HighHbA1cObservation: BuildLaboratoryObservation(TestCaseId + '-hba1c-high', HbA1cLaboratoryTestCodes.system, HbA1cCode, PatientReference, EncounterReference, GlycemicAssessmentDate, 10.2),
            MissingResultHbA1cObservation: BuildLaboratoryObservationWithoutResult(TestCaseId + '-hba1c-missing-result', HbA1cLaboratoryTestCodes.system, HbA1cCode, PatientReference, EncounterReference, GlycemicAssessmentDate),
            HospiceProcedure: BuildProcedure(TestCaseId + '-hospice-proc', EncounterPeriodEnd, 'completed', HospiceCareAmbulatoryCodes.system, HospiceCareAmbulatoryCodes.codes[0], PatientReference, EncounterReference, Interval[EncounterPeriodStart, EncounterPeriodEnd]),
            NursingHomeObservation: BuildScreeningAssessmentObservation(TestCaseId + '-nursing-home', HousingStatusCode.system, HousingStatusCode.code, LivesInNursingHomeCode.system, LivesInNursingHomeCode.code, PatientReference, EncounterReference, EncounterPeriodEnd),
            PalliativeCareProcedure: BuildProcedure(TestCaseId + '-palliative-proc', EncounterPeriodEnd, 'completed', PalliativeCareInterventionCodes.system, PalliativeCareInterventionCodes.codes[0], PatientReference, EncounterReference, Interval[EncounterPeriodStart, EncounterPeriodEnd])
            return
                Tuple {
                    ThePatient: AdultPatient,
                    TheDiabetesCondition: DiabetesCondition,
                    TheQualifyingEncounter: QualifyingEncounter,
                    TheControlledHbA1cObservation: ControlledHbA1cObservation,
                    TheHighHbA1cObservation: HighHbA1cObservation,
                    TheMissingResultHbA1cObservation: MissingResultHbA1cObservation,
                    TheHospiceProcedure: HospiceProcedure,
                    TheNursingHomeObservation: NursingHomeObservation,
                    ThePalliativeCareProcedure: PalliativeCareProcedure
                }

define BuildIneligibleTestCases:
    OtherPopulationsCount C
        let TestCaseId: BuildTestCaseId('ineligible-underage', C),
            PatientFirstName: if C <= (Last(OtherPopulationsCount) / 2) then RandomMaleFirstName else RandomFemaleFirstName,
            PatientLastName: RandomLastName,
            PatientGender: if C <= (Last(OtherPopulationsCount) / 2) then 'male' else 'female',
            UnderagePatient: BuildPatient(TestCaseId, PatientFirstName, PatientLastName, PatientGender, Date(RandomNumberInRange(2010, 2015), RandomMonth, RandomDay), C)
            return { UnderagePatient }

define BuildInInitialPopulationTestCases:
    OtherPopulationsCount C
        let TestCaseId: BuildTestCaseId('denominator-controlled', C),
            PatientReference: 'Patient/' + TestCaseId,
            IsMale: C <= (Last(OtherPopulationsCount) / 2),
            Result: BuildRandomTestCase(TestCaseId, C, PatientReference, IsMale, false)
            return { Result.ThePatient } union { Result.TheDiabetesCondition } union { Result.TheQualifyingEncounter } union { Result.TheControlledHbA1cObservation }

define BuildInNumeratorHighHbA1cTestCases:
    InNumeratorCount C
        let TestCaseId: BuildTestCaseId('numerator-high-hba1c', C),
            PatientReference: 'Patient/' + TestCaseId,
            IsMale: C <= (Last(InNumeratorCount) / 2),
            Result: BuildRandomTestCase(TestCaseId, C, PatientReference, IsMale, false)
            return { Result.ThePatient } union { Result.TheDiabetesCondition } union { Result.TheQualifyingEncounter } union { Result.TheHighHbA1cObservation }

define BuildInNumeratorNoAssessmentTestCases:
    OtherPopulationsCount C
        let TestCaseId: BuildTestCaseId('numerator-no-assessment', C),
            PatientReference: 'Patient/' + TestCaseId,
            IsMale: C <= (Last(OtherPopulationsCount) / 2),
            Result: BuildRandomTestCase(TestCaseId, C, PatientReference, IsMale, false)
            return { Result.ThePatient } union { Result.TheDiabetesCondition } union { Result.TheQualifyingEncounter }

define BuildInNumeratorMissingResultTestCases:
    OtherPopulationsCount C
        let TestCaseId: BuildTestCaseId('numerator-missing-result', C),
            PatientReference: 'Patient/' + TestCaseId,
            IsMale: C <= (Last(OtherPopulationsCount) / 2),
            Result: BuildRandomTestCase(TestCaseId, C, PatientReference, IsMale, false)
            return { Result.ThePatient } union { Result.TheDiabetesCondition } union { Result.TheQualifyingEncounter } union { Result.TheMissingResultHbA1cObservation }

define BuildDenominatorExclusionHospiceProcedureTestCases:
    OtherPopulationsCount C
        let TestCaseId: BuildTestCaseId('denex-hospice-proc', C),
            PatientReference: 'Patient/' + TestCaseId,
            IsMale: C <= (Last(OtherPopulationsCount) / 2),
            Result: BuildRandomTestCase(TestCaseId, C, PatientReference, IsMale, false)
            return { Result.ThePatient } union { Result.TheDiabetesCondition } union { Result.TheQualifyingEncounter } union { Result.TheControlledHbA1cObservation } union { Result.TheHospiceProcedure }

define BuildDenominatorExclusionNursingHomeTestCases:
    OtherPopulationsCount C
        let TestCaseId: BuildTestCaseId('denex-nursing-home', C),
            PatientReference: 'Patient/' + TestCaseId,
            IsMale: C <= (Last(OtherPopulationsCount) / 2),
            Result: BuildRandomTestCase(TestCaseId, C, PatientReference, IsMale, true)
            return { Result.ThePatient } union { Result.TheDiabetesCondition } union { Result.TheQualifyingEncounter } union { Result.TheControlledHbA1cObservation } union { Result.TheNursingHomeObservation }

define BuildDenominatorExclusionPalliativeProcedureTestCases:
    OtherPopulationsCount C
        let TestCaseId: BuildTestCaseId('denex-palliative-proc', C),
            PatientReference: 'Patient/' + TestCaseId,
            IsMale: C <= (Last(OtherPopulationsCount) / 2),
            Result: BuildRandomTestCase(TestCaseId, C, PatientReference, IsMale, false)
            return { Result.ThePatient } union { Result.TheDiabetesCondition } union { Result.TheQualifyingEncounter } union { Result.TheControlledHbA1cObservation } union { Result.ThePalliativeCareProcedure }

define BuildTestCases:
    { BuildPractitioner(ProviderId) }
    union (flatten BuildIneligibleTestCases)
    union (flatten BuildInInitialPopulationTestCases)
    union (flatten BuildInNumeratorHighHbA1cTestCases)
    union (flatten BuildInNumeratorNoAssessmentTestCases)
    union (flatten BuildInNumeratorMissingResultTestCases)
    union (flatten BuildDenominatorExclusionHospiceProcedureTestCases)
    union (flatten BuildDenominatorExclusionNursingHomeTestCases)
    union (flatten BuildDenominatorExclusionPalliativeProcedureTestCases)

define TestDataGenerationResult:
    BuildBundle(BuildTestCases)

define function BuildBundle(resources List<Choice<FHIR.Resource>>):
    FHIR.Bundle {
        type: FHIR.BundleType { value: 'transaction'},
        entry: BuildBundleEntry(resources)
    }

define function BuildBundleEntry(resources List<FHIR.Resource>):
    resources resource
        let FHIRType:
            case
                when resource is FHIR.Patient then 'Patient/'
                when resource is FHIR.Encounter then 'Encounter/'
                when resource is FHIR.Condition then 'Condition/'
                when resource is FHIR.Observation then 'Observation/'
                when resource is FHIR.Practitioner then 'Practitioner/'
                when resource is FHIR.Procedure then 'Procedure/'
                else ''
            end
        return
            FHIR.Bundle.Entry {
                resource: resource,
                request: FHIR.Bundle.Entry.Request {
                    method: FHIR.HTTPVerb { value: 'PUT' },
                    url: FHIR.url { value: FHIRType + resource.id.value }
                }
            }

define function BuildMeta(profile String):
    FHIR.Meta {
        profile: List<FHIR.canonical> {
            FHIR.canonical { value: profile }
        }
    }

define function BuildCodeableConcept(system String, code String):
    FHIR.CodeableConcept {
        coding: List<FHIR.Coding> {
            BuildCoding(system, code)
        }
    }

define function BuildCoding(system String, code String):
    FHIR.Coding {
        system: FHIR.uri { value: system },
        code: FHIR.code { value: code }
    }

define function BuildCoding(system String, code String, display String):
    FHIR.Coding {
        system: FHIR.uri { value: system },
        code: FHIR.code { value: code },
        display: FHIR.string { value: display }
    }

define function BuildExtension(url String, value Choice<FHIR.base64Binary,FHIR.boolean,FHIR.canonical,FHIR.code,FHIR.date,FHIR.dateTime,FHIR.decimal,FHIR.id,FHIR.instant,FHIR.integer,FHIR.markdown,FHIR.oid,FHIR.positiveInt,FHIR.string,FHIR.time,FHIR.unsignedInt,FHIR.uri,FHIR.url,FHIR.uuid,FHIR.Address,FHIR.Age,FHIR.Annotation,FHIR.Attachment,FHIR.CodeableConcept,FHIR.Coding,FHIR.ContactPoint,FHIR.Count,FHIR.Distance,FHIR.Duration,FHIR.HumanName,FHIR.Identifier,FHIR.Money,FHIR.Period,FHIR.Quantity,FHIR.Range,FHIR.Ratio,FHIR.Reference,FHIR.SampledData,FHIR.Signature,FHIR.Timing,FHIR.ContactDetail,FHIR.Contributor,FHIR.Expression,FHIR.ParameterDefinition,FHIR.RelatedArtifact,FHIR.TriggerDefinition,FHIR.UsageContext,FHIR.Dosage,FHIR.Meta>):
    FHIR.Extension {
        url: FHIR.uri { value: url },
        value: value
    }

define function BuildPatientRaceAndEthnicityExtensions(raceTuple Tuple{raceCategoryCode String, raceCategoryDisplay String}, ethnicityTuple Tuple{ethnicityCategoryCode String, ethnicityCategoryDisplay String}):
    List<FHIR.Extension> {
        FHIR.Extension {
            url: FHIR.uri { value: 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-race' },
            extension: List<FHIR.Extension> {
                FHIR.Extension {
                    url: FHIR.uri { value: 'ombCategory' },
                    value: BuildCoding('urn:oid:2.16.840.1.113883.6.238', raceTuple.raceCategoryCode, raceTuple.raceCategoryDisplay)
                },
                FHIR.Extension {
                    url: FHIR.uri { value: 'text' },
                    value: FHIR.string { value: raceTuple.raceCategoryDisplay }
                }
            }
        },
        FHIR.Extension {
            url: FHIR.uri { value: 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity' },
            extension: List<FHIR.Extension> {
                FHIR.Extension {
                    url: FHIR.uri { value: 'ombCategory' },
                    value: BuildCoding('urn:oid:2.16.840.1.113883.6.238', ethnicityTuple.ethnicityCategoryCode, ethnicityTuple.ethnicityCategoryDisplay)
                },
                FHIR.Extension {
                    url: FHIR.uri { value: 'text' },
                    value: FHIR.string { value: ethnicityTuple.ethnicityCategoryDisplay }
                }
            }
        }
    }

define function BuildPatient(id String, firstName String, lastName String, gender String, birthDate Date, count Integer):
    FHIR.Patient {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-patient'),
        extension: BuildPatientRaceAndEthnicityExtensions(RaceCategoryCodes[RandomNumberInRange(0, 4)], EthnicityCategoryCodes[RandomNumberInRange(0, 1)]),
        identifier: List<FHIR.Identifier> {
            FHIR.Identifier {
                system: FHIR.uri { value: 'http://example.org/mct/patient-id' },
                value: FHIR.string { value: id }
            }
        },
        name: List<FHIR.HumanName> {
            FHIR.HumanName {
                use: FHIR.NameUse { value: 'official' },
                family: FHIR.string { value: lastName },
                given: List<FHIR.string> {
                    FHIR.string { value: firstName }
                }
            }
        },
        telecom: List<FHIR.ContactPoint> {
            FHIR.ContactPoint {
                system: FHIR.ContactPointSystem { value: 'email' },
                value: FHIR.string { value: firstName + '.' + lastName + '@example.org' },
                use: FHIR.ContactPointUse { value: 'home' }
            }
        },
        gender: FHIR.AdministrativeGender { value: gender },
        birthDate: FHIR.date { value: birthDate },
        deceased: FHIR.boolean { value: false },
        address: List<FHIR.Address> {
            FHIR.Address {
                line: List<FHIR.string> {
                    FHIR.string { value: ToString(count) + ' Test Data Lane' }
                },
                city: FHIR.string { value: 'Testville' },
                state: FHIR.string { value: 'MD' },
                postalCode: FHIR.string { value: '209' + ToString(RandomNumberInRange(10, 99)) },
                period: FHIR.Period {
                    start: FHIR.dateTime { value: start of MeasurementPeriod },
                    end: FHIR.dateTime { value: end of MeasurementPeriod }
                }
            }
        },
        communication: List<FHIR.Patient.Communication> {
            FHIR.Patient.Communication {
                language: BuildCodeableConcept('urn:ietf:bcp:47', 'en-US')
            }
        }
    }

define function BuildCondition(id String, profile String, codeSystem String, codeCode String, subject String, encounterReference String, onset DateTime):
    FHIR.Condition {
        id: FHIR.id { value: id },
        meta: BuildMeta(profile),
        clinicalStatus: BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/condition-clinical', 'active'),
        verificationStatus: BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/condition-ver-status', 'confirmed'),
        category: List<FHIR.CodeableConcept> {
            BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/condition-category', 'encounter-diagnosis')
        },
        code: BuildCodeableConcept(codeSystem, codeCode),
        subject: FHIR.Reference { reference: FHIR.string { value: subject } },
        encounter: FHIR.Reference { reference: FHIR.string { value: encounterReference } },
        onset: FHIR.dateTime { value: onset }
    }

define function BuildEncounter(id String, status String, classCode String, typeSystem String, typeCode String, subject String, periodStart DateTime, periodEnd DateTime, diagnosisReference String):
    FHIR.Encounter {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-encounter'),
        status: FHIR.EncounterStatus { value: status },
        class: BuildCoding('http://terminology.hl7.org/CodeSystem/v3-ActCode', classCode),
        type: List<FHIR.CodeableConcept> {
            BuildCodeableConcept(typeSystem, typeCode)
        },
        subject: FHIR.Reference { reference: FHIR.string { value: subject } },
        period: FHIR.Period { start: FHIR.dateTime { value: periodStart }, end: FHIR.dateTime { value: periodEnd } },
        diagnosis: if diagnosisReference is not null
            then List<FHIR.Encounter.Diagnosis> {
                FHIR.Encounter.Diagnosis {
                    condition: FHIR.Reference { reference: FHIR.string { value: diagnosisReference } },
                    rank: FHIR.positiveInt { value: 1 }
                }
            }
            else null
    }

define function BuildPractitioner(id String):
    FHIR.Practitioner {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-practitioner'),
        identifier: List<FHIR.Identifier> {
            FHIR.Identifier {
                system: FHIR.uri { value: 'http://hl7.org/fhir/sid/us-npi' },
                value: FHIR.string { value: '9999999999' }
            }
        },
        active: FHIR.boolean { value: true },
        name: List<FHIR.HumanName> {
            FHIR.HumanName {
                use: FHIR.NameUse { value: 'official' },
                family: FHIR.string { value: 'TestProvider' },
                given: List<FHIR.string> {
                    FHIR.string { value: 'CMS122' }
                }
            }
        }
    }

define function BuildLaboratoryObservation(id String, codeSystem String, codeCode String, subject String, encounterReference String, effectiveDateTime DateTime, resultValue Decimal):
    FHIR.Observation {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-observation-lab'),
        status: FHIR.ObservationStatus { value: 'final' },
        category: List<FHIR.CodeableConcept> {
            BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/observation-category', 'laboratory')
        },
        code: BuildCodeableConcept(codeSystem, codeCode),
        subject: FHIR.Reference { reference: FHIR.string { value: subject } },
        encounter: FHIR.Reference { reference: FHIR.string { value: encounterReference } },
        effective: FHIR.dateTime { value: effectiveDateTime },
        value: FHIR.Quantity {
            value: FHIR.decimal { value: resultValue },
            unit: FHIR.string { value: '%' },
            system: FHIR.uri { value: 'http://unitsofmeasure.org' },
            code: FHIR.code { value: '%' }
        }
    }

define function BuildLaboratoryObservationWithoutResult(id String, codeSystem String, codeCode String, subject String, encounterReference String, effectiveDateTime DateTime):
    FHIR.Observation {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-observation-lab'),
        status: FHIR.ObservationStatus { value: 'final' },
        category: List<FHIR.CodeableConcept> {
            BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/observation-category', 'laboratory')
        },
        code: BuildCodeableConcept(codeSystem, codeCode),
        subject: FHIR.Reference { reference: FHIR.string { value: subject } },
        encounter: FHIR.Reference { reference: FHIR.string { value: encounterReference } },
        effective: FHIR.dateTime { value: effectiveDateTime }
    }

define function BuildScreeningAssessmentObservation(id String, codeSystem String, codeCode String, valueSystem String, valueCode String, subject String, encounterReference String, effectiveDateTime DateTime):
    FHIR.Observation {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-observation-screening-assessment'),
        status: FHIR.ObservationStatus { value: 'final' },
        code: BuildCodeableConcept(codeSystem, codeCode),
        subject: FHIR.Reference { reference: FHIR.string { value: subject } },
        encounter: FHIR.Reference { reference: FHIR.string { value: encounterReference } },
        effective: FHIR.dateTime { value: effectiveDateTime },
        value: BuildCodeableConcept(valueSystem, valueCode)
    }

define function BuildProcedure(id String, recorded DateTime, status String, codeSystem String, codeCode String, subject String, encounterReference String, performed Choice<DateTime, Interval<DateTime>>):
    FHIR.Procedure {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-procedure'),
        extension: List<FHIR.Extension> {
            BuildExtension('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-recorded', FHIR.dateTime{ value: recorded })
        },
        status: FHIR.ProcedureStatus { value: status },
        code: BuildCodeableConcept(codeSystem, codeCode),
        subject: FHIR.Reference { reference: FHIR.string { value: subject } },
        encounter: FHIR.Reference { reference: FHIR.string { value: encounterReference } },
        performed:
            if performed is DateTime then FHIR.dateTime { value: performed }
            else FHIR.Period { start: FHIR.dateTime { value: start of performed }, end: FHIR.dateTime { value: end of performed } }
    }
