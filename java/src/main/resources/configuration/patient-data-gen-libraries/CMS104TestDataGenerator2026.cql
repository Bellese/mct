library CMS104TestDataGenerator2026 version '1.0.0'

using FHIR version '4.0.1'

parameter MeasurementPeriod default Interval[@2026-01-01T00:00:00.000Z, @2027-01-01T00:00:00.000Z)
parameter NumberOfTests default 200
parameter MeasureId default 'CMS104'

define NumberOfTestCases:
    (expand { Interval[ToQuantity(0), ToQuantity(NumberOfTests)] } per ToQuantity(1)) exapandResult
        return Truncate((start of exapandResult).value)

define function GetNumberOfTestCasesList(count Integer):
    (expand { Interval[ToQuantity(0), ToQuantity(count)] } per ToQuantity(1)) exapandResult
        return Truncate((start of exapandResult).value)

define InNumeratorCount:
    GetNumberOfTestCasesList(Truncate(Round(Length(NumberOfTestCases) * 0.6)))

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

define RandomHour:
    RandomNumberInRange(1, 23)

define RandomMinute:
    RandomNumberInRange(1, 59)

define RandomSecond:
    RandomNumberInRange(1, 59)

define RandomMillisecond:
    RandomNumberInRange(1, 999)

define EvaluationTimezone:
    timezoneoffset from Now()

define ProviderId:
    'cms104-provider'

define ProviderReference:
    'Practitioner/' + ProviderId

define MaleFirstName_100:
    {'Lucas', 'Markell', 'Leland', 'Jonatan', 'Frederick', 'German', 'Elvis', 'Gage', 'Yisroel', 'Thomas', 'Jayson', 'Kenton', 'Patrick', 'Alberto', 'Willis', 'Davon', 'Kyron', 'Rolando', 'Johnny', 'Cristian', 'Donald', 'Broderick', 'Chaz', 'Elian', 'Darrin', 'Dayton', 'Jude', 'Samir', 'Benito', 'Demetrius', 'Shane', 'Adan', 'Johnpaul', 'Waylon', 'Rigoberto', 'Bo', 'Bruno', 'Kadin', 'Shamar', 'Vernon', 'Bryce', 'Dane', 'Ronaldo', 'Aditya', 'Bowen', 'Luciano', 'Jamison', 'Bernard', 'Brennan', 'Xander', 'Tate', 'Lukas', 'Sydney', 'Jayvon', 'Samuel', 'Jett', 'Octavio', 'Ramon', 'Humberto', 'Elliot', 'Riley', 'Izaiah', 'Ronan', 'Myron', 'Kale', 'Wade', 'Randolph', 'Konner', 'Donnell', 'Jaxon', 'Santino', 'Taylor', 'Jerod', 'Corey', 'Leonardo', 'Ibrahim', 'Eddie', 'Ashton', 'Bobby', 'Keshawn', 'Kerry', 'Garett', 'Adrian', 'Leon', 'Parker', 'Ellis', 'Kalen', 'Austin', 'Ralph', 'Deshawn', 'Keelan', 'Cade', 'Jamel', 'Benjamin', 'Seamus', 'Treyvon', 'Notnamed', 'Greyson', 'Devlin', 'Julian'}

define FemaleFirstName_100:
    {'Lilian', 'Carrie', 'Meagan', 'Maddison', 'Rhonda', 'Kaiya', 'Alysa', 'Angelique', 'Bonnie', 'Rita', 'Santana', 'Daija', 'Carina', 'Madeleine', 'Notnamed', 'Jacie', 'Jaycie', 'Yulissa', 'Elexis', 'Adrianna', 'Nicole', 'Michaela', 'Nallely', 'Brandi', 'Mariah', 'Elisha', 'Jamie', 'Susana', 'Lianna', 'Sierra', 'Lexie', 'Stefany', 'Josefina', 'Lina', 'Alaysia', 'Chana', 'Katy', 'Robyn', 'Sara', 'Charlize', 'Kari', 'Brandy', 'Yamile', 'Kaylin', 'Lauryn', 'Harlie', 'Ellie', 'Verania', 'Madysen', 'Lucinda', 'Melinda', 'Irene', 'Ayesha', 'Jamia', 'Tea', 'Joseline', 'Aiyanna', 'Destini', 'Saige', 'Makiya', 'Dymond', 'Tatyana', 'Layla', 'Maricela', 'Deanna', 'Claudia', 'Averie', 'Amaiya', 'Adia', 'Ximena', 'Caleigh', 'Ainsley', 'Mckayla', 'Maci', 'Lizette', 'Amari', 'Josephine', 'Misty', 'Janna', 'Bayley', 'Heidy', 'Elyssa', 'Julieta', 'Maeve', 'Lori', 'Gracie', 'Mckinley', 'Aiyana', 'Maiya', 'Yessenia', 'Brielle', 'Armani', 'Christie', 'Heidi', 'Kellie', 'Alyssa', 'Madalynn', 'Zara', 'Lea', 'Malia'}

define LastNames_200:
    {'Galvez', 'Najera', 'Cornelius', 'Thrasher', 'Grove', 'Hughes', 'Cosgrove', 'Bollinger', 'Lane', 'Mejia', 'Downey', 'Brewer', 'Duncan', 'Gandy', 'Ash', 'Grimes', 'Forman', 'Robinson', 'Chow', 'Ha', 'Yancey', 'Carlton', 'Shank', 'Hamm', 'Shields', 'Anderson', 'Sheridan', 'Worden', 'Toro', 'Espinosa', 'Nagy', 'Beckwith', 'Molina', 'Ingram', 'Pace', 'Dominguez', 'Clough', 'Andres', 'Raymond', 'Spurlock', 'Liles', 'Chavarria', 'Acuna', 'Neil', 'Peterman', 'Rauch', 'Romero', 'Collazo', 'Burge', 'High', 'Girard', 'Taylor', 'Knudsen', 'Gale', 'Paz', 'Wagoner', 'Luce', 'Patterson', 'Close', 'Jack', 'Kinsey', 'Taggart', 'Engle', 'Masters', 'Clements', 'Brinkman', 'Singh', 'Yoo', 'Bailey', 'Broughton', 'Weis', 'Rock', 'Stokes', 'Elizondo', 'Wolf', 'Ambrose', 'Zapata', 'Garza', 'Godfrey', 'Brant', 'Yoder', 'Mcgrew', 'Sheets', 'Arias', 'Ketchum', 'Pauley', 'Kaminski', 'Devries', 'Beavers', 'Sharp', 'Ayres', 'Dailey', 'Schaffer', 'Cortez', 'Hill', 'Shen', 'Mackenzie', 'Strauss', 'Haynes', 'Kent', 'Andersen', 'Greiner', 'Muhammad', 'Salgado', 'Westfall', 'Dahl', 'Kimble', 'Zielinski', 'Culp', 'Bustos', 'Ramirez', 'Ruggiero', 'Joseph', 'Biddle', 'Meeker', 'Duke', 'Estep', 'Grossman', 'Becerra', 'Mohr', 'Ledbetter', 'Rogers', 'Estrella', 'Daugherty', 'Switzer', 'Weatherford', 'Schulze', 'Ott', 'Scroggins', 'Alcantar', 'Heinz', 'Adamson', 'Lafferty', 'Gifford', 'Peek', 'Burgos', 'Phelan', 'Weller', 'Barba', 'Sorensen', 'Hamel', 'Aguirre', 'Aponte', 'McCormack', 'Lantz', 'Schell', 'Burr', 'Currier', 'Carlson', 'Post', 'Crutchfield', 'Marx', 'Quick', 'Keck', 'Cho', 'Lindley', 'Whitson', 'Flood', 'McClintock', 'Nolan', 'Lightfoot', 'Bostic', 'Ashley', 'Roque', 'Mazur', 'Ware', 'Bautista', 'Kirkland', 'Wheaton', 'Waller', 'Gaddis', 'Tavares', 'Corey', 'Hadley', 'Kessler', 'Lehmann', 'Pringle', 'Lam', 'Gorman', 'Paris', 'Love', 'Goodrich', 'See', 'Ritter', 'Cornwell', 'Newton', 'Rowland', 'Ferrara', 'Benavides', 'Monroe', 'Pack', 'Brannon', 'Dove', 'Goldberg', 'Farrell', 'Harrington', 'Kaur', 'Lassiter', 'Antonio', 'Hale'}

define RandomMaleFirstName:
    MaleFirstName_100[RandomNumberInRange(0, 99)]

define RandomFemaleFirstName:
    FemaleFirstName_100[RandomNumberInRange(0, 99)]

define RandomLastName:
    LastNames_200[RandomNumberInRange(0, 199)]

define ICD10IschemicStrokeCodes:
    Tuple {
        system: 'http://hl7.org/fhir/sid/icd-10-cm',
        codes: { 'I63.011', 'I63.012', 'I63.013', 'I63.019', 'I63.02', 'I63.031', 'I63.032', 'I63.033', 'I63.039', 'I63.09', 'I63.10', 'I63.111', 'I63.112', 'I63.113', 'I63.119', 'I63.12', 'I63.131', 'I63.132', 'I63.133', 'I63.139', 'I63.19', 'I63.20', 'I63.211', 'I63.212', 'I63.213', 'I63.219', 'I63.22', 'I63.231', 'I63.232', 'I63.233', 'I63.239', 'I63.29', 'I63.30', 'I63.311', 'I63.312', 'I63.313', 'I63.319', 'I63.321', 'I63.322', 'I63.323', 'I63.329', 'I63.331', 'I63.332', 'I63.333', 'I63.339', 'I63.341', 'I63.342', 'I63.343', 'I63.349', 'I63.39', 'I63.40', 'I63.411', 'I63.412', 'I63.413', 'I63.419', 'I63.421', 'I63.422', 'I63.423', 'I63.429', 'I63.431', 'I63.432', 'I63.433', 'I63.439', 'I63.441', 'I63.442', 'I63.443', 'I63.449', 'I63.49', 'I63.50', 'I63.511', 'I63.512', 'I63.513', 'I63.519', 'I63.521', 'I63.522', 'I63.523', 'I63.529', 'I63.531', 'I63.532', 'I63.533', 'I63.539', 'I63.541', 'I63.542', 'I63.543', 'I63.549', 'I63.59', 'I63.6', 'I63.81', 'I63.89', 'I63.9' }
    }

define SnomedIschemicStrokeCodes:
    Tuple {
        system: 'http://snomed.info/sct',
        codes: { '111297002', '116288000', '195185009', '195186005', '195189003', '195190007', '195212005', '195213000', '195216008', '195217004', '195230003', '230690007', '230691006', '230692004', '230693009', '230694003' , '230695002', '230696001', '230698000', '230699008', '230700009', '230701008', '307363008', '422504002', '426107000' }
    }

define RxNormAntithromboticCodes:
    Tuple {
        system: 'http://www.nlm.nih.gov/research/umls/rxnorm',
        codes: { '1037045', '1037179', '1092398', '1114198', '1116635', '1232082', '1232086', '1250907', '1361574', '1364435', '1364445', '1536467', '1536498', '1536503', '1536675', '1536815', '1536833', '1536840', '1537029', '1549682', '1593110', '1599543', '1599551', '1599555', '1658717', '1659195', '1659197', '1665356', '1666332', '1722689', '1723476', '1730187', '1804735', '1804737', '1811631', '1811632', '197447', '197945', '198464', '198466', '198467', '198471', '198475', '198479', '198480', '1992427', '2059015', '212033', '2267026', '2360605', '238134', '238135', '243670', '243694', '252857', '2565491', '2565492', '2583731', '2588062', '2590616', '2590620', '2590623', '2590627', '2590631', '2590635', '259081', '2618839', '2626726', '308278', '308297', '308351', '308363', '308409', '308411', '308416', '309362', '313406', '318272', '359221', '432638', '637540', '692836', '702316', '749196', '763111', '763116', '806446', '827318', '848768', '854238', '854241', '854245', '854248', '854252', '854255', '855288', '855296', '855302', '855312', '855318', '855324', '855332', '855338', '855344', '857121', '861356', '861360', '861363', '861365', '900528', '978725', '978733', '978736', '978740', '978744', '978746', '978755', '978759', '978777', '994226', '994237', '994430', '994435', '994528', '994535' }
    }

define MedicalReasonForNotProvidingTreatmentCodes:
    Tuple {
        system: 'http://snomed.info/sct',
        codes: { '183932001', '183964008', '183966005', '266721009', '31438003', '35688006', '407563006', '410529002', '410534003', '410536001', '416098002', '419511003', '428024001', '428119001', '59037007', '62014003', '79899007' }
    }

define PatientRefusalCodes:
    Tuple {
        system: 'http://snomed.info/sct',
        codes: { '1162745003', '1296859006', '182890002', '182895007', '182896008', '182897004', '182898009', '182900006', '182901005', '182903008', '183945002', '183946001', '183948000', '275936005', '406149000', '416432009', '443390004', '895451009' }
    }

define DenominatorExceptionReasonCodeSets:
    { MedicalReasonForNotProvidingTreatmentCodes, PatientRefusalCodes }

define PharmacologicalContraindicationCodes:
    Tuple {
        system: 'http://www.nlm.nih.gov/research/umls/rxnorm',
        codes: { '855812', '855818' }
    }

define InpatientEncounterCodes:
    { '183452005', '32485007', '442281000124108' }

define InpatientEncounterDischargeCodes:
    Tuple {
        system: 'http://snomed.info/sct',
        codes: { '428371000124100', '306701001', '306703003', '434781000124105', '445060000', '371828006', '428361000124107' }
    }

define MedicationRequestStatusCodes:
    { 'active', 'completed' }

define ComfortMeasureCodes:
    Tuple {
        system: 'http://snomed.info/sct',
        codes: { '133918004', '182964004', '385736008', '385763009' }
    }

define AllowedMedicationRequestIntents:
    { 'order', 'original-order', 'reflex-order', 'filler-order', 'instance-order' }

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

define DateMaxDays:
    { 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

define GetRandomDateTimeDuringMeasurementPeriod:
    DateTime(
        year from start of MeasurementPeriod,
        RandomNumberInRange(1, 12),
        RandomDay, RandomHour, RandomMinute, RandomSecond, RandomMillisecond, EvaluationTimezone
    )

define function DateInPeriodRough(startDate DateTime, endDate DateTime):
    Tuple {
        theYear: year from startDate,
        theMonth: if month from startDate > month from endDate then month from startDate else RandomNumberInRange(month from startDate, month from endDate),
        theDay: if day from startDate > day from endDate then day from startDate else RandomNumberInRange(day from startDate, day from endDate)
    }

define function GetRandomDateInPeriod(startDate DateTime, endDate DateTime):
    startDate s
        let RoughDate: DateInPeriodRough(startDate, endDate)
    return DateTime(
        RoughDate.theYear,
        RoughDate.theMonth,
        if RoughDate.theDay > DateMaxDays[RoughDate.theMonth] then day from endDate else RoughDate.theDay,
        hour from startDate, minute from startDate, second from startDate, millisecond from startDate, EvaluationTimezone
    )

define function BuildRandomTestCase(TestCaseId String, count Integer, PatientReference String, IsMale Boolean, HasInpatientEncounterWithDischarge Boolean):
    TestCaseId ID
        let PatientFirstName: if IsMale then RandomMaleFirstName else RandomFemaleFirstName,
            PatientLastName: RandomLastName,
            PatientGender: if IsMale then 'male' else 'female',
            PatientBirthDate: Date(RandomNumberInRange(1950, 2000), RandomMonth, RandomDay),
            AdultPatient: BuildPatient(TestCaseId, PatientFirstName, PatientLastName, PatientGender, PatientBirthDate, Addresses[count]),
            ConditionReference: 'Condition/' + TestCaseId,
            EncounterReference: 'Encounter/' + TestCaseId,
            CoverageReference: 'Coverage/' + TestCaseId,
            MedicationRequestReference: 'MedicationRequest/' + TestCaseId + '-rej-at',
            IschemicStrokeCodeSets: { ICD10IschemicStrokeCodes, SnomedIschemicStrokeCodes },
            RandomIschemicCodeSet: IschemicStrokeCodeSets[RandomNumberInRange(0, 1)],
            IschemicCodeSystem: RandomIschemicCodeSet.system,
            IschemicCodeCode: RandomIschemicCodeSet.codes[RandomNumberInRange(0, Length(RandomIschemicCodeSet.codes) - 1)],
            IschemicCondition: BuildCondition(TestCaseId, IschemicCodeSystem, IschemicCodeCode, PatientReference, EncounterReference),
            RandomInpatientEncounterCode: InpatientEncounterCodes[RandomNumberInRange(0, Length(InpatientEncounterCodes) - 1)],
            EncounterPeriodEnd: GetRandomDateTimeDuringMeasurementPeriod,
            EncounterPeriodStart: EncounterPeriodEnd - ToQuantity(ToString(RandomNumberInRange(0, 120)) + ' days'),
            EncounterInterval: Interval[EncounterPeriodStart, EncounterPeriodEnd],
            EncounterDischargeSystem: if HasInpatientEncounterWithDischarge then InpatientEncounterDischargeCodes.system else null,
            EncounterDischargeCode: if HasInpatientEncounterWithDischarge then InpatientEncounterDischargeCodes.codes[RandomNumberInRange(0, Length(InpatientEncounterDischargeCodes.codes) - 1)] else null,
            NonElectiveInpatientEncounter: BuildEncounter(TestCaseId, 'finished', RandomInpatientEncounterCode, PatientReference, EncounterPeriodStart, EncounterPeriodEnd, ConditionReference, EncounterDischargeSystem, EncounterDischargeCode),
            PatientCoverage: BuildCoverage(TestCaseId, PatientReference),
            PrincipalDiagnosisClaim: BuildClaim(TestCaseId, PatientReference, EncounterReference, ProviderReference, CoverageReference, EncounterPeriodEnd, IschemicCodeSystem, IschemicCodeCode),
            AntithromboticMedReqAuthoredOn: EncounterPeriodEnd - ToQuantity(ToString(RandomNumberInRange(0, 3)) + ' days'),
            AntithromboticMedReqStatus: MedicationRequestStatusCodes[RandomNumberInRange(0, 1)],
            AntithromboticMedReqIntent: AllowedMedicationRequestIntents[RandomNumberInRange(0, Length(AllowedMedicationRequestIntents) - 1)],
            AntithromboticMedReqMedicationConcept: BuildCodeableConcept(RxNormAntithromboticCodes.system, RxNormAntithromboticCodes.codes[RandomNumberInRange(0, Length(RxNormAntithromboticCodes.codes) - 1)]),
            ReasonCodeSet: DenominatorExceptionReasonCodeSets[RandomNumberInRange(0, Length(DenominatorExceptionReasonCodeSets) - 1)],
            ReasonCode: ReasonCodeSet.codes[RandomNumberInRange(0, Length(ReasonCodeSet.codes) - 1)],
            PharmacologicalContraindicationMedicationConcept: BuildCodeableConcept(PharmacologicalContraindicationCodes.system, PharmacologicalContraindicationCodes.codes[RandomNumberInRange(0, Length(PharmacologicalContraindicationCodes.codes) - 1)]),
            ComfortMeasureCode: ComfortMeasureCodes.codes[RandomNumberInRange(0, Length(ComfortMeasureCodes.codes) - 1)],
            AntithromboticMedReq: BuildMedicationRequest(TestCaseId, AntithromboticMedReqStatus, AntithromboticMedReqIntent, true, false, false, AntithromboticMedReqMedicationConcept, PatientReference, EncounterReference, AntithromboticMedReqAuthoredOn, null, null, null),
            MedicationNotRequested: BuildMedicationNotRequested(TestCaseId + '-mnr', AntithromboticMedReqStatus, AntithromboticMedReqIntent, true, false, AntithromboticMedReqMedicationConcept, PatientReference, EncounterReference, AntithromboticMedReqAuthoredOn, null, ReasonCodeSet.system, ReasonCode),
            RejectedAntithromboticMedReq: BuildMedicationRequest(TestCaseId + '-rej-at', AntithromboticMedReqStatus, AntithromboticMedReqIntent, true, false, false, AntithromboticMedReqMedicationConcept, PatientReference, EncounterReference, AntithromboticMedReqAuthoredOn, null, null, null),
            TaskRejected: BuildTaskRejected(TestCaseId + '-task-rej', MedicationRequestReference, PatientReference, ReasonCodeSet.system, ReasonCode),
            PharmacologicalContraindicationMedReq: BuildMedicationRequest(TestCaseId + '-pharm-ci', AntithromboticMedReqStatus, AntithromboticMedReqIntent, true, false, false, PharmacologicalContraindicationMedicationConcept, PatientReference, EncounterReference, AntithromboticMedReqAuthoredOn, null, null, null),
            ComfortMeasureServiceRequest: BuildServiceRequest(TestCaseId + '-cm-sr', 'active', AntithromboticMedReqIntent, PatientReference, AntithromboticMedReqAuthoredOn, ComfortMeasureCodes.system, ComfortMeasureCode, EncounterReference),
            ComfortMeasureProcedure: BuildProcedure(TestCaseId + '-cm-proc', AntithromboticMedReqAuthoredOn, 'completed', ComfortMeasureCodes.system, ComfortMeasureCode, PatientReference, EncounterReference, AntithromboticMedReqAuthoredOn)
            return
                Tuple {
                    ThePatient: AdultPatient,
                    TheCondition: IschemicCondition,
                    TheEncounter: NonElectiveInpatientEncounter,
                    TheCoverage: PatientCoverage,
                    TheClaim: PrincipalDiagnosisClaim,
                    TheMedicationRequest: AntithromboticMedReq,
                    TheMedicationNotRequested: MedicationNotRequested,
                    TheRejectedMedicationRequest: RejectedAntithromboticMedReq,
                    TheTaskRejected: TaskRejected,
                    ThePharmacologicalContraindicationMedicationRequest: PharmacologicalContraindicationMedReq,
                    TheComfortMeasureServiceRequest: ComfortMeasureServiceRequest,
                    TheComfortMeasureProcedure: ComfortMeasureProcedure
                }

define BuildIneligibleTestCases:
    OtherPopulationsCount C
        let TestCaseId: BuildTestCaseId('ineligible', C),
            PatientReference: 'Patient/' + TestCaseId,
            IsMale: C <= (Last(OtherPopulationsCount) / 2),
            Result: BuildRandomTestCase(TestCaseId, C, PatientReference, IsMale, false)
            return { Result.ThePatient }

define BuildInInitialPopulationTestCases:
    OtherPopulationsCount C
        let TestCaseId: BuildTestCaseId('in-initial-population', C),
            PatientReference: 'Patient/' + TestCaseId,
            IsMale: C <= (Last(OtherPopulationsCount) / 2),
            Result: BuildRandomTestCase(TestCaseId, C, PatientReference, IsMale, false)
            return { Result.ThePatient } union { Result.TheCondition } union { Result.TheEncounter } union { Result.TheCoverage } union { Result.TheClaim }

define BuildInNumeratorTestCases:
    InNumeratorCount C
        let TestCaseId: BuildTestCaseId('in-numerator', C),
            PatientReference: 'Patient/' + TestCaseId,
            IsMale: C <= (Last(InNumeratorCount) / 2),
            Result: BuildRandomTestCase(TestCaseId, C, PatientReference, IsMale, false)
            return { Result.ThePatient } union { Result.TheCondition } union { Result.TheEncounter } union { Result.TheCoverage } union { Result.TheClaim } union { Result.TheMedicationRequest }

define BuildDenominatorExclusionDischargeTestCases:
    OtherPopulationsCount C
        let TestCaseId: BuildTestCaseId('denex-discharge', C),
            PatientReference: 'Patient/' + TestCaseId,
            IsMale: C <= (Last(OtherPopulationsCount) / 2),
            Result: BuildRandomTestCase(TestCaseId, C, PatientReference, IsMale, true)
            return { Result.ThePatient } union { Result.TheCondition } union { Result.TheEncounter } union { Result.TheCoverage } union { Result.TheClaim }

define BuildDenominatorExclusionComfortServiceRequestTestCases:
    OtherPopulationsCount C
        let TestCaseId: BuildTestCaseId('denex-cm-sr', C),
            PatientReference: 'Patient/' + TestCaseId,
            IsMale: C <= (Last(OtherPopulationsCount) / 2),
            Result: BuildRandomTestCase(TestCaseId, C, PatientReference, IsMale, false)
            return { Result.ThePatient } union { Result.TheCondition } union { Result.TheEncounter } union { Result.TheCoverage } union { Result.TheClaim } union { Result.TheComfortMeasureServiceRequest }

define BuildDenominatorExclusionComfortProcedureTestCases:
    OtherPopulationsCount C
        let TestCaseId: BuildTestCaseId('denex-cm-proc', C),
            PatientReference: 'Patient/' + TestCaseId,
            IsMale: C <= (Last(OtherPopulationsCount) / 2),
            Result: BuildRandomTestCase(TestCaseId, C, PatientReference, IsMale, false)
            return { Result.ThePatient } union { Result.TheCondition } union { Result.TheEncounter } union { Result.TheCoverage } union { Result.TheClaim } union { Result.TheComfortMeasureProcedure }

define BuildDenominatorExceptionMedicationNotRequestedTestCases:
    OtherPopulationsCount C
        let TestCaseId: BuildTestCaseId('denexc-mnr', C),
            PatientReference: 'Patient/' + TestCaseId,
            IsMale: C <= (Last(OtherPopulationsCount) / 2),
            Result: BuildRandomTestCase(TestCaseId, C, PatientReference, IsMale, false)
            return { Result.ThePatient } union { Result.TheCondition } union { Result.TheEncounter } union { Result.TheCoverage } union { Result.TheClaim } union { Result.TheMedicationNotRequested }

define BuildDenominatorExceptionTaskRejectedTestCases:
    OtherPopulationsCount C
        let TestCaseId: BuildTestCaseId('denexc-task', C),
            PatientReference: 'Patient/' + TestCaseId,
            IsMale: C <= (Last(OtherPopulationsCount) / 2),
            Result: BuildRandomTestCase(TestCaseId, C, PatientReference, IsMale, false)
            return { Result.ThePatient } union { Result.TheCondition } union { Result.TheEncounter } union { Result.TheCoverage } union { Result.TheClaim } union { Result.TheRejectedMedicationRequest } union { Result.TheTaskRejected }

define BuildDenominatorExceptionPharmacologicalContraindicationTestCases:
    OtherPopulationsCount C
        let TestCaseId: BuildTestCaseId('denexc-pharm', C),
            PatientReference: 'Patient/' + TestCaseId,
            IsMale: C <= (Last(OtherPopulationsCount) / 2),
            Result: BuildRandomTestCase(TestCaseId, C, PatientReference, IsMale, false)
            return { Result.ThePatient } union { Result.TheCondition } union { Result.TheEncounter } union { Result.TheCoverage } union { Result.TheClaim } union { Result.ThePharmacologicalContraindicationMedicationRequest }

define BuildTestCases:
    { BuildPractitioner(ProviderId) }
    union (flatten BuildIneligibleTestCases)
    union (flatten BuildInInitialPopulationTestCases)
    union (flatten BuildInNumeratorTestCases)
    union (flatten BuildDenominatorExclusionDischargeTestCases)
    union (flatten BuildDenominatorExclusionComfortServiceRequestTestCases)
    union (flatten BuildDenominatorExclusionComfortProcedureTestCases)
    union (flatten BuildDenominatorExceptionMedicationNotRequestedTestCases)
    union (flatten BuildDenominatorExceptionTaskRejectedTestCases)
    union (flatten BuildDenominatorExceptionPharmacologicalContraindicationTestCases)

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
                when resource is FHIR.MedicationRequest then 'MedicationRequest/'
                when resource is FHIR.ServiceRequest then 'ServiceRequest/'
                when resource is FHIR.Coverage then 'Coverage/'
                when resource is FHIR.Claim then 'Claim/'
                when resource is FHIR.Practitioner then 'Practitioner/'
                when resource is FHIR.Task then 'Task/'
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

define function BuildExtension(url String, value Choice<FHIR.base64Binary,FHIR.boolean,FHIR.canonical,FHIR.code,FHIR.date,FHIR.dateTime,FHIR.decimal,FHIR.id,FHIR.instant,FHIR.integer,FHIR.markdown,FHIR.oid,FHIR.positiveInt,FHIR.string,FHIR.time,FHIR.unsignedInt,FHIR.uri,FHIR.url,FHIR.uuid,FHIR.Address,FHIR.Age,FHIR.Annotation,FHIR.Attachment,FHIR.CodeableConcept,FHIR.Coding,FHIR.ContactPoint,FHIR.Count,FHIR.Distance,FHIR.Duration,FHIR.HumanName,FHIR.Identifier,FHIR.Money,FHIR.Period,FHIR.Quantity,FHIR.Range,FHIR.Ratio,FHIR.Reference,FHIR.SampledData,FHIR.Signature,FHIR.Timing,FHIR.ContactDetail,FHIR.Contributor,FHIR.DataRequirement,FHIR.Expression,FHIR.ParameterDefinition,FHIR.RelatedArtifact,FHIR.TriggerDefinition,FHIR.UsageContext,FHIR.Dosage,FHIR.Meta>):
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

define function BuildPatient(id String, firstName String, lastName String, gender String, birthDate Date, address List<String>):
    FHIR.Patient {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-patient'),
        extension: BuildPatientRaceAndEthnicityExtensions(RaceCategoryCodes[RandomNumberInRange(0, 4)], EthnicityCategoryCodes[RandomNumberInRange(0, 1)]),
        identifier: List<FHIR.Identifier> {
            FHIR.Identifier {
                system: FHIR.uri { value: 'urn:oid:1.2.36.146.595.217.0.1' },
                value: FHIR.string { value: '12345' }
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
                value: FHIR.string { value: firstName + '.' + lastName + '@gmail.com' },
                use: FHIR.ContactPointUse { value: 'home' }
            }
        },
        gender: FHIR.AdministrativeGender { value: gender },
        birthDate: FHIR.date { value: birthDate },
        deceased: FHIR.boolean { value: false },
        address: List<FHIR.Address> {
            FHIR.Address {
                line: List<FHIR.string> {
                    FHIR.string { value: address[0] }
                },
                city: FHIR.string { value: address[2] },
                state: FHIR.string { value: address[3] },
                postalCode: FHIR.string { value: address[1] },
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

define function BuildCondition(id String, codeSystem String, codeCode String, subject String, encounterReference String):
    FHIR.Condition {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-condition'),
        clinicalStatus: BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/condition-clinical', 'active'),
        verificationStatus: BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/condition-ver-status', 'confirmed'),
        category: List<FHIR.CodeableConcept> {
            BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/condition-category', 'encounter-diagnosis')
        },
        code: BuildCodeableConcept(codeSystem, codeCode),
        subject: FHIR.Reference { reference: FHIR.string { value: subject } },
        encounter: FHIR.Reference { reference: FHIR.string { value: encounterReference } }
    }

define function BuildEncounter(id String, status String, type String, subject String, periodStart DateTime, periodEnd DateTime, condition String, dischargeSystem String, dischargeCode String):
    FHIR.Encounter {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-encounter'),
        status: FHIR.EncounterStatus { value: status },
        class: BuildCoding('http://terminology.hl7.org/CodeSystem/v3-ActCode', 'IMP'),
        type: List<FHIR.CodeableConcept> {
            BuildCodeableConcept('http://snomed.info/sct', type)
        },
        subject: FHIR.Reference { reference: FHIR.string { value: subject } },
        period: FHIR.Period { start: FHIR.dateTime { value: periodStart }, end: FHIR.dateTime { value: periodEnd } },
        diagnosis: List<FHIR.Encounter.Diagnosis> {
            FHIR.Encounter.Diagnosis {
                condition: FHIR.Reference { reference: FHIR.string { value: condition } },
                rank: FHIR.positiveInt { value: 1 }
            }
        },
        hospitalization: if dischargeSystem is not null
            then FHIR.Encounter.Hospitalization {
                dischargeDisposition: BuildCodeableConcept(dischargeSystem, dischargeCode)
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
                    FHIR.string { value: 'CMS104' }
                }
            }
        }
    }

define function BuildCoverage(id String, patientReference String):
    FHIR.Coverage {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-coverage'),
        identifier: List<FHIR.Identifier> {
            FHIR.Identifier {
                system: FHIR.uri { value: 'http://example.org/mct/coverage-id' },
                value: FHIR.string { value: id }
            }
        },
        status: FHIR.CoverageStatus { value: 'active' },
        type: BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/coverage-selfpay', 'pay'),
        subscriber: FHIR.Reference { reference: FHIR.string { value: patientReference } },
        beneficiary: FHIR.Reference { reference: FHIR.string { value: patientReference } },
        relationship: BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/subscriber-relationship', 'self'),
        period: FHIR.Period {
            start: FHIR.dateTime { value: start of MeasurementPeriod },
            end: FHIR.dateTime { value: end of MeasurementPeriod }
        },
        payor: List<FHIR.Reference> {
            FHIR.Reference { reference: FHIR.string { value: patientReference } }
        }
    }

define function BuildClaim(id String, patientReference String, encounterReference String, providerReference String, coverageReference String, created DateTime, principalDiagnosisSystem String, principalDiagnosisCode String):
    FHIR.Claim {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-claim'),
        status: FHIR.ClaimStatus { value: 'active' },
        type: BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/claim-type', 'institutional'),
        use: FHIR.Use { value: 'claim' },
        patient: FHIR.Reference { reference: FHIR.string { value: patientReference } },
        created: FHIR.dateTime { value: created },
        provider: FHIR.Reference { reference: FHIR.string { value: providerReference } },
        priority: BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/processpriority', 'normal'),
        diagnosis: List<FHIR.Claim.Diagnosis> {
            FHIR.Claim.Diagnosis {
                sequence: FHIR.positiveInt { value: 1 },
                diagnosis: BuildCodeableConcept(principalDiagnosisSystem, principalDiagnosisCode),
                type: List<FHIR.CodeableConcept> {
                    BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/ex-diagnosistype', 'principal')
                }
            }
        },
        insurance: List<FHIR.Claim.Insurance> {
            FHIR.Claim.Insurance {
                sequence: FHIR.positiveInt { value: 1 },
                focal: FHIR.boolean { value: true },
                coverage: FHIR.Reference { reference: FHIR.string { value: coverageReference } }
            }
        },
        item: List<FHIR.Claim.Item> {
            FHIR.Claim.Item {
                sequence: FHIR.positiveInt { value: 1 },
                diagnosisSequence: List<FHIR.positiveInt> {
                    FHIR.positiveInt { value: 1 }
                },
                productOrService: BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/ex-USCLS', '99555'),
                encounter: List<FHIR.Reference> {
                    FHIR.Reference { reference: FHIR.string { value: encounterReference } }
                }
            }
        }
    }

define function BuildServiceRequest(id String, status String, intent String, subject String, authoredOn DateTime, codeSystem String, codeCode String, encounterReference String):
    FHIR.ServiceRequest {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-servicerequest'),
        status: FHIR.ServiceRequestStatus { value: status },
        intent: FHIR.ServiceRequestIntent { value: intent },
        code: BuildCodeableConcept(codeSystem, codeCode),
        subject: FHIR.Reference { reference: FHIR.string { value: subject } },
        encounter: FHIR.Reference { reference: FHIR.string { value: encounterReference } },
        authoredOn: FHIR.dateTime { value: authoredOn }
    }

define function BuildTaskRejected(id String, focusReference String, patientReference String, statusReasonSystem String, statusReasonCode String):
    FHIR.Task {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-taskrejected'),
        status: FHIR.TaskStatus { value: 'rejected' },
        intent: FHIR.TaskIntent { value: 'order' },
        code: BuildCodeableConcept('http://hl7.org/fhir/CodeSystem/task-code', 'fulfill'),
        focus: FHIR.Reference { reference: FHIR.string { value: focusReference } },
        statusReason: BuildCodeableConcept(statusReasonSystem, statusReasonCode),
        for: FHIR.Reference { reference: FHIR.string { value: patientReference } }
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

define function BuildMedicationRequest(id String, status String, intent String, isCommunity Boolean, isDischarge Boolean, doNotPerform Boolean, medication Choice<String, FHIR.CodeableConcept>, subject String, encounterReference String, authoredOn DateTime, requester String, reasonCodeSystem String, reasonCodeCode String):
    BuildMedicationRequestWithProfile(id, 'http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-medicationrequest', status, intent, isCommunity, isDischarge, doNotPerform, medication, subject, encounterReference, authoredOn, requester, reasonCodeSystem, reasonCodeCode)

define function BuildMedicationNotRequested(id String, status String, intent String, isCommunity Boolean, isDischarge Boolean, medication Choice<String, FHIR.CodeableConcept>, subject String, encounterReference String, authoredOn DateTime, requester String, reasonCodeSystem String, reasonCodeCode String):
    BuildMedicationRequestWithProfile(id, 'http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-medicationnotrequested', status, intent, isCommunity, isDischarge, true, medication, subject, encounterReference, authoredOn, requester, reasonCodeSystem, reasonCodeCode)

define function BuildMedicationRequestWithProfile(id String, profile String, status String, intent String, isCommunity Boolean, isDischarge Boolean, doNotPerform Boolean, medication Choice<String, FHIR.CodeableConcept>, subject String, encounterReference String, authoredOn DateTime, requester String, reasonCodeSystem String, reasonCodeCode String):
    FHIR.MedicationRequest {
        id: FHIR.id { value: id },
        meta: BuildMeta(profile),
        status: FHIR.MedicationRequestStatus { value: status },
        intent: FHIR.MedicationRequestIntent { value: intent },
        category: List<FHIR.CodeableConcept> {
            BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/medicationrequest-category',
                if isCommunity then 'community' else if isDischarge then 'discharge' else 'inpatient')
        },
        doNotPerform: FHIR.boolean { value: doNotPerform },
        medication: if medication is String then FHIR.Reference { reference: FHIR.string { value: medication } } else medication,
        subject: FHIR.Reference { reference: FHIR.string { value: subject } },
        encounter: FHIR.Reference { reference: FHIR.string { value: encounterReference } },
        authoredOn: FHIR.dateTime { value: authoredOn },
        requester:
            if requester is not null then FHIR.Reference { reference: FHIR.string { value: requester } } else null,
        reasonCode: if reasonCodeSystem is not null and reasonCodeCode is not null
            then List<FHIR.CodeableConcept> { BuildCodeableConcept(reasonCodeSystem, reasonCodeCode) }
            else null
    }

define Addresses:
    {
        { '10 Ninth Ramp', '77490', 'Glenarden', 'ID' },
        { '406 Silent Field Knoll', '19889', 'Brush Creek', 'MO' },
        { '982 Lagoon Gardens', '81128', 'Craigmont', 'MO' },
        { '728 Gentle Zephyr Landing', '46677', 'German', 'AK' },
        { '604 Middle Road', '56975', 'Niles village', 'TX' },
        { '513 S Oak', '65758', 'Central Islip', 'AL' },
        { '687 Iron Pony', '94664', 'Lawai', 'RI' },
        { '443 Fort Cove', '92886', 'Ogdensburg borough', 'WV' },
        { 'P.O. Box 69252', '42156', 'Darby ship', 'CT' },
        { '910 Thunder Oak Woods', '46682', 'Somerset', 'ND' },
        { '922 Emerald Forest', '53564', 'Oak Point', 'AZ' },
        { '349 Heather Manor', '41897', 'Portage village', 'IN' },
        { '309 Honey Lane', '68080', 'Westview', 'NY' },
        { '919 Rocky Vista', '94487', 'Sibley village', 'MN' },
        { '962 Quiet Cider Way', '40043', 'Ladera Heights', 'FL' },
        { '802 Treasure Drive', '08692', 'Mount Sinai', 'MA' },
        { '749 Rustic Treasure Underpass', '38716', 'Piney', 'AZ' },
        { '222 Rocky Port', '19570', 'Deerwood', 'OH' },
        { '727 Thunder Lake', '85271', 'Etna Green', 'VT' },
        { 'P.O. Box 96929', '26154', 'Mount Erie village', 'AR' },
        { 'P.O. Box 93558', '32655', 'McMullen', 'NC' },
        { '600 Cotton Fork', '86805', 'Roslyn', 'LA' },
        { 'P.O. Box 17703', '63506', 'Gentry village', 'WA' },
        { '54 Wishing Loaf', '44970', 'Cassville', 'DE' },
        { '972 Light Crossing', '88490', 'Westside', 'CO' },
        { '454 Club Viaduct', '08725', 'Lime Ridge village', 'CA' },
        { 'P.O. Box 71295', '27929', 'Cavour', 'AK' },
        { '88 Cinder Robin', '11508', 'Halls', 'SD' },
        { '470 Pine Path', '53055', 'Gardner village', 'RI' },
        { '851 Misty Blossom Landing', '13158', 'Tremontvillage', 'AZ' },
        { '354 Lake Fair', '38882', 'Lyford', 'CO' },
        { 'P.O. Box 36822', '36319', 'Montezuma village', 'SD' },
        { '620 Harvest Bear', '65730', 'Ackworth', 'WV' },
        { '431 Iron Hill Arcade', '03858', 'Holden Beach', 'OR' },
        { 'P.O. Box 34881', '28440', 'Oxoboxo River', 'MS' },
        { '204 Seventh Turnpike', '63938', 'Lava Hot Springs', 'AK' },
        { '296 Harvest Blossom Point', '73750', 'Cressona borough', 'OR' },
        { 'P.O. Box 47729', '30588', 'Clarksville borough', 'CT' },
        { '914 Cozy Camp Curve', '83363', 'Twain Harte', 'MA' },
        { '171 Heather Branch Mount', '28077', 'Okemos', 'TN' },
        { '599 Barn Valley', '03009', 'Muskegon Heights', 'IA' },
        { '461 Grand Approach', '23736', 'Wilkinson Heights', 'FL' },
        { '983 Goose Oval', '83996', 'Popponesset Island', 'IN' },
        { '19 SW Brook', '08977', 'Huguley', 'MS' },
        { 'P.O. Box 55789', '38127', 'Stockham village', 'SD' },
        { '170 Branch Crest', '00145', 'Mercer borough', 'NM' },
        { '312 Kennedy Bay', '50765', 'Heart Butte', 'OH' },
        { '257 Heather Crossing', '46813', 'Aromas', 'MO' },
        { '717 NE Walk', '17059', 'Williams', 'IA' },
        { '922 Blue Meadow', '44976', 'Loyalton', 'OR' },
        { '53 Pioneer Union', '13400', 'Wallace', 'WV' },
        { 'P.O. Box 57612', '47325', 'Huachuca', 'IA' },
        { '902 Cinder Bluff Glen', '60176', 'Zebulon', 'ME' },
        { '662 Middle Light', '19082', 'Bluffdale', 'NM' },
        { '886 Essex Landing', '04362', 'La Center', 'NC' },
        { '141 NW Freeway', '10332', 'Bryn Mawr-Skyway', 'IN' },
        { '728 Crystal Stream', '77410', 'Kaltag', 'WV' },
        { '617 Emerald Lawn', '34426', 'Wolsey', 'WY' },
        { '90 Quiet Spur', '39930', 'Aberdeen', 'MI' },
        { '814 Burning Stream Road', '66695', 'Fall River', 'WA' },
        { '199 Flat Knoll', '62160', 'Montreal', 'SC' },
        { '619 Elm Row', '88875', 'Othello', 'WY' },
        { 'P.O. Box 99303', '16478', 'Dalzell', 'VT' },
        { '782 Golden Sixth', '34905', 'Naknek', 'OR' },
        { '390 Panda Plaza', '52878', 'South Alamo', 'ME' },
        { '578 Cliff Dam', '05993', 'New Eucha', 'MT' },
        { '559 Easy Berry', '61967', 'Maybee village', 'NM' },
        { '483 Cozy Gardens', '28783', 'Rico', 'WY' },
        { '878 Noble Road', '88716', 'East Canton village', 'WA' },
        { 'P.O. Box 25512', '29384', 'North', 'MN' },
        { 'P.O. Box 96634', '09707', 'Hallam borough', 'TN' },
        { '170 Flat Bank', '70371', 'Mascot', 'NE' },
        { '400 Quaking Bluff', '95244', 'Bowdle', 'NJ' },
        { '504 Cozy Pond', '13446', 'Lake Isabella', 'AR' },
        { '44 Rocky Fillmore', '47121', 'Tornado', 'AR' },
        { 'P.O. Box 61088', '78671', 'Berea', 'OR' },
        { '295 Thunder Prairie', '31340', 'West Springfield', 'CT' },
        { '391 Rocky Goose Estate', '45762', 'Wynnewood', 'NM' },
        { '297 Jagged River Drive', '53279', 'Tajique', 'MS' },
        { '547 SW Ramp', '13003', 'Lake Waccamaw', 'WY' },
        { '549 Rustic Fort', '66814', 'Theodosia village', 'KY' },
        { 'P.O. Box 30055', '88191', 'Bon Air', 'UT' },
        { '526 Flat Cove', '52144', 'Bushnell', 'OK' },
        { '12 SE Pioneer', '22788', 'Seldovia Village', 'IL' },
        { '708 Mall Gardens', '11859', 'Centralborough', 'UT' },
        { '933 Quaking Cider', '94533', 'Oak Creek', 'MT' },
        { '156 Bluff Swale', '11707', 'Roy village', 'IN' },
        { '852 Cotton Estate', '53661', 'North Bethesda', 'TN' },
        { 'P.O. Box 47134', '95345', 'Zuni Pueblo', 'NY' },
        { '72 Quaking Cider', '54957', 'Mount Jackson', 'AZ' },
        { '46 Middle Skyway', '19408', 'Watterson Park', 'NC' },
        { '280 Fallen Fork', '41151', 'Mexia', 'ME' },
        { '75 Honey Pathway', '60072', 'Richwood village', 'WY' },
        { '404 Silver Landing', '10009', 'Flomaton', 'AL' },
        { '148 Club Hollow', '60791', 'Sunbury', 'MA' },
        { '731 Round Prairie', '67636', 'Gu-Win', 'MN' },
        { '398 Umber Log Bayoo', '83844', 'Victor', 'NJ' },
        { '791 Panda Falls', '92151', 'Cayuga', 'CA' },
        { '704 Jagged Beacon Bridge', '96647', 'New Buffalo', 'LA' },
        { '835 Island Overpass', '47947', 'Silsbee', 'VA' },
        { '81 Cedar Key', '34985', 'Dillsboro', 'ND' },
        { 'P.O. Box 61407', '37225', 'Maple Plain', 'AL' },
        { '38 Shady Bank', '46682', 'Towanda borough', 'OH' },
        { 'P.O. Box 15520', '00032', 'Fort Hunt', 'SD' },
        { '263 Misty Mountain', '52806', 'Ferron', 'MN' },
        { '448 Round Seventh Pass', '13284', 'New Rome village', 'PA' },
        { 'P.O. Box 50027', '75567', 'Eleanor', 'NE' },
        { '781 Blue Union', '96705', 'Spreckels', 'ID' },
        { 'P.O. Box 82415', '41579', 'Seaside', 'CA' },
        { '741 NW Station', '63100', 'Rothsay', 'WY' },
        { '78 Misty Fawn', '36961', 'Rocklake', 'KY' },
        { 'P.O. Box 76320', '43234', 'Cross Roads', 'OR' },
        { '942 Foggy Ninth', '99679', 'Cleora', 'NM' },
        { '289 Berry Row', '55729', 'Landover Hills', 'VA' },
        { '570 N Rest Plaza', '99001', 'Walnut Hill village', 'OR' },
        { '628 Cozy Creek', '68272', 'Lincoln Beach', 'KS' },
        { 'P.O. Box 59513', '88024', 'Fall Branch', 'MA' },
        { 'P.O. Box 14529', '87075', 'Orange Cove', 'UT' },
        { '334 Lock Track', '71610', 'McCune', 'NY' },
        { '831 Stony Point', '06774', 'Mansfield Center', 'ND' },
        { '966 Crystal Cove', '61205', 'Spotswood borough', 'CO' },
        { '938 Wishing Shore', '23458', 'Simsbury Center', 'SC' },
        { '373 Rise Crest', '03348', 'Brush Creek', 'SC' },
        { 'P.O. Box 88541', '22144', 'Menominee', 'OH' },
        { '961 Shady First', '71812', 'Kiryas Joel village', 'TN' },
        { 'P.O. Box 20276', '90636', 'Sodus village', 'NH' },
        { '89 Goose Passage', '18701', 'Detroit Beach', 'OK' },
        { 'P.O. Box 79973', '18960', 'Bloomsbury borough', 'AK' },
        { '744 Shady Butterfly', '24136', 'Retreat', 'VA' },
        { '716 Island Corner', '03290', 'Ansonville', 'MO' },
        { 'P.O. Box 41502', '82065', 'Iola village', 'MS' },
        { '806 Rustic Branch Bridge', '41431', 'Skokie village', 'ND' },
        { 'P.O. Box 27363', '37242', 'Dover', 'NE' },
        { '742 Elm Corner', '59636', 'Pahokee', 'WV' },
        { '923 Merry Fawn', '42404', 'Country Club', 'AL' },
        { '802 Fourth Hollow', '29438', 'TN Ridge', 'CA' },
        { '671 Tawny Oak Divide', '99036', 'Pewaukee village', 'PA' },
        { '790 Richmond Street', '55316', 'Northwest Harwinton', 'MS' },
        { '912 Silver Fillmore Curve', '02220', 'Oak Lawn village', 'WY' },
        { 'P.O. Box 86939', '06022', 'Ackworth', 'VT' },
        { '361 Apple Terrace', '08761', 'Homeland', 'ND' },
        { '469 Heather Spur Estate', '64767', 'Fisk', 'ND' },
        { '52 Rapid Edge', '37165', 'Miller village', 'FL' },
        { '404 Crescent Track', '83282', 'Platinum', 'ID' },
        { '620 Ninth Bayoo', '68504', 'Flora', 'MN' },
        { '796 Grand Panda Lawn', '34379', 'Greenhorn', 'VA' },
        { '264 Colonial Summit', '99959', 'Bluefield', 'TN' },
        { '539 Sunny Lock Meadow', '13191', 'Kilbourne village', 'NC' },
        { '87 Eighth Crossroad', '15278', 'Kechi', 'NE' },
        { '772 Wishing Squaw Dam', '68506', 'Guion', 'WI' },
        { '587 Cedar Highway', '47470', 'Merrill village', 'UT' },
        { '895 Bright Zephyr Swale', '00601', 'Chilchinbito', 'MI' },
        { '729 Little Court', '78523', 'Depew village', 'MT' },
        { '353 Fallen Bluff', '91404', 'Tonkawa', 'WV' },
        { 'P.O. Box 84279', '30823', 'McClusky', 'AZ' },
        { '350 Island Quay', '02701', 'Sandusky', 'CT' },
        { '88 Tawny Bear', '57972', 'Blooming Grove', 'AK' },
        { 'P.O. Box 82675', '00467', 'Almena village', 'AL' },
        { '728 SW Radial', '66807', 'Grandview Plaza', 'TN' },
        { '930 Cinder Oak Pike', '46375', 'North Yelm', 'HI' },
        { '124 Indian Ledge', '29511', 'Hidalgo', 'NH' },
        { '118 Colonial Run', '13642', 'Exline', 'NY' },
        { '71 Park Arcade', '47100', 'Elaine', 'NM' },
        { '810 Indian Spur Isle', '00216', 'Moscow borough', 'CT' },
        { '100 Noble Pine', '79561', 'Orleans', 'NY' },
        { '901 Tawny Overpass', '63155', 'Terre Hill borough', 'LA' },
        { '824 Quaking Trail', '79102', 'Miles', 'PA' },
        { '950 Leaf Gardens', '69435', 'Nehalem', 'RI' },
        { '743 Silent Grove Parade', '17511', 'Crosslake', 'NC' },
        { '110 Hidden Manor', '26643', 'Seth Ward', 'NM' },
        { '900 E Boulevard', '15432', 'McNab', 'NM' },
        { '690 Dewy Apple Road', '42493', 'Shipshewana', 'MD' },
        { 'P.O. Box 23589', '58979', 'Bentonvillage', 'SC' },
        { '616 Circle Ramp', '72835', 'Collinston village', 'SC' },
        { '416 Old Expressway', '61209', 'Blythe', 'GA' },
        { '474 Rocky Well', '69976', 'Arcade', 'LA' },
        { '397 Gate Knoll', '86700', 'Stover', 'PA' },
        { 'P.O. Box 85743', '94972', 'West Ocean', 'IL' },
        { 'P.O. Box 73534', '67250', 'East Aurora village', 'KY' },
        { '197 Noble Way', '64428', 'Twin Lakes', 'OK' },
        { '981 View Driveway', '56509', 'Satsop', 'NJ' },
        { '794 Tawny Log', '42050', 'Absecon', 'SD' },
        { '964 Red Quay', '59199', 'Webster village', 'NE' },
        { 'P.O. Box 32097', '10316', 'Cheboygan', 'ME' },
        { '444 Silver Beacon', '57229', 'Millington village', 'MD' },
        { '71 Sleepy Fillmore Road', '90588', 'Edcouch', 'DE' },
        { '368 High Spur', '60856', 'Martinton village', 'CO' },
        { '623 SE Ranch', '26055', 'Butler', 'OH' },
        { '528 Cedar Kennedy', '80550', 'Dundee village', 'NC' },
        { 'P.O. Box 39961', '87617', 'Kerman', 'ME' },
        { '565 Blossom Path', '38132', 'Seldovia Village', 'WV' },
        { '234 Wishing Wall Row', '03420', 'Security-Widefield', 'WI' },
        { '654 Stony Fort', '77573', 'Ephrata', 'WI' },
        { '101 High Place', '72056', 'Wardner', 'LA' },
        { '849 SE Motorway', '96123', 'Bally borough', 'SD' },
        { 'P.O. Box 81810', '83871', 'Ames village', 'NM' },
        { 'P.O. Box 83963', '44660', 'Ambler borough', 'LA' },
        { '50 Little Quail Plain', '07681', 'Chupadero', 'ID' },
        { 'P.O. Box 41085', '89926', 'Weedpatch', 'NC' },
        { '598 Golden Woods', '75126', 'Arcadia village', 'OR' }
    }
