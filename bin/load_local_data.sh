#!/usr/bin/env bash

set -e
set -o pipefail

# Measurement period for these test cases: 2026-01-01 to 2026-12-31
#
# Facility A - 4 patients (one per CMS125 population category):
#   Patient/87f00b2a-f664-4b82-843e-559bf1f86520  not in initial population
#   Patient/dd6bd96f-3a4e-4796-bee0-1d31884e96d7  denominator only (no mammogram)
#   Patient/d4540640-2561-4ebd-b7c6-15878a4dc582  denominator exclusion
#   Patient/81dce125-8691-4625-ac6b-07fce0a45680  numerator (has qualifying mammogram)
curl --location 'http://localhost:8080/fhir' \
--header 'Content-Type: application/json' \
--data-raw '{
  "resourceType": "Bundle",
  "type": "transaction",
  "entry": [
    {
      "resource": {
        "resourceType": "Patient",
        "id": "87f00b2a-f664-4b82-843e-559bf1f86520",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-patient"
          ]
        },
        "extension": [
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-race",
            "extension": [
              {
                "url": "ombCategory",
                "valueCoding": {
                  "system": "urn:oid:2.16.840.1.113883.6.238",
                  "code": "2028-9",
                  "display": "Asian"
                }
              },
              {
                "url": "text",
                "valueString": "Asian"
              }
            ]
          },
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-sex",
            "valueCode": "248152002"
          },
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity",
            "extension": [
              {
                "url": "ombCategory",
                "valueCoding": {
                  "system": "urn:oid:2.16.840.1.113883.6.238",
                  "code": "2135-2",
                  "display": "Hispanic or Latino"
                }
              },
              {
                "url": "text",
                "valueString": "Hispanic or Latino"
              }
            ]
          }
        ],
        "identifier": [
          {
            "system": "http://hospital.smarthealthit.org",
            "value": "999999995"
          }
        ],
        "name": [
          {
            "family": "Bertha",
            "given": [
              "Betty"
            ]
          }
        ],
        "gender": "female",
        "birthDate": "1984-12-31"
      },
      "request": {
        "method": "PUT",
        "url": "Patient/87f00b2a-f664-4b82-843e-559bf1f86520"
      }
    },
    {
      "resource": {
        "resourceType": "Encounter",
        "id": "d8fb09ad-6f49-4064-895c-d5b9a867c6f2",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-encounter"
          ]
        },
        "status": "finished",
        "class": {
          "system": "http://terminology.hl7.org/CodeSystem/v3-ActCode",
          "code": "AMB",
          "display": "ambulatory"
        },
        "type": [
          {
            "coding": [
              {
                "system": "http://snomed.info/sct",
                "code": "185463005",
                "display": "Visit out of hours (procedure)"
              }
            ]
          }
        ],
        "subject": {
          "reference": "Patient/87f00b2a-f664-4b82-843e-559bf1f86520"
        },
        "period": {
          "start": "2027-01-01T00:00:00.000+00:00",
          "end": "2027-01-01T00:00:00.000+00:00"
        }
      },
      "request": {
        "method": "PUT",
        "url": "Encounter/d8fb09ad-6f49-4064-895c-d5b9a867c6f2"
      }
    },
    {
      "resource": {
        "resourceType": "Patient",
        "id": "dd6bd96f-3a4e-4796-bee0-1d31884e96d7",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-patient"
          ]
        },
        "extension": [
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-race",
            "extension": [
              {
                "url": "ombCategory",
                "valueCoding": {
                  "system": "urn:oid:2.16.840.1.113883.6.238",
                  "code": "2028-9",
                  "display": "Asian"
                }
              },
              {
                "url": "text",
                "valueString": "Asian"
              }
            ]
          },
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-sex",
            "valueCode": "248152002"
          },
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity",
            "extension": [
              {
                "url": "ombCategory",
                "valueCoding": {
                  "system": "urn:oid:2.16.840.1.113883.6.238",
                  "code": "2135-2",
                  "display": "Hispanic or Latino"
                }
              },
              {
                "url": "text",
                "valueString": "Hispanic or Latino"
              }
            ]
          }
        ],
        "identifier": [
          {
            "system": "http://hospital.smarthealthit.org",
            "value": "999999995"
          }
        ],
        "name": [
          {
            "family": "Bertha",
            "given": [
              "Betty"
            ]
          }
        ],
        "gender": "female",
        "birthDate": "1974-12-31"
      },
      "request": {
        "method": "PUT",
        "url": "Patient/dd6bd96f-3a4e-4796-bee0-1d31884e96d7"
      }
    },
    {
      "resource": {
        "resourceType": "Encounter",
        "id": "ab4b46d8-33f2-4f9d-be9d-555092b9d570",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-encounter"
          ]
        },
        "status": "finished",
        "class": {
          "system": "http://terminology.hl7.org/CodeSystem/v3-ActCode",
          "code": "AMB",
          "display": "ambulatory"
        },
        "type": [
          {
            "coding": [
              {
                "system": "http://snomed.info/sct",
                "code": "185463005",
                "display": "Visit out of hours (procedure)"
              }
            ]
          }
        ],
        "subject": {
          "reference": "Patient/dd6bd96f-3a4e-4796-bee0-1d31884e96d7"
        },
        "period": {
          "start": "2026-01-01T00:00:00.000+00:00",
          "end": "2026-01-01T00:00:00.000+00:00"
        }
      },
      "request": {
        "method": "PUT",
        "url": "Encounter/ab4b46d8-33f2-4f9d-be9d-555092b9d570"
      }
    },
    {
      "resource": {
        "resourceType": "Encounter",
        "id": "ab4b46d8-33f2-4f9d-be9d-555092b9d570.1",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-encounter"
          ]
        },
        "status": "finished",
        "class": {
          "system": "http://terminology.hl7.org/CodeSystem/v3-ActCode",
          "code": "AMB",
          "display": "ambulatory"
        },
        "type": [
          {
            "coding": [
              {
                "system": "http://snomed.info/sct",
                "code": "183452005",
                "display": "Emergency hospital admission (procedure)"
              }
            ]
          }
        ],
        "subject": {
          "reference": "Patient/dd6bd96f-3a4e-4796-bee0-1d31884e96d7"
        },
        "period": {
          "start": "2027-01-01T00:00:00.000+00:00",
          "end": "2027-01-01T00:00:00.000+00:00"
        },
        "hospitalization": {
          "dischargeDisposition": {
            "coding": [
              {
                "system": "http://snomed.info/sct",
                "code": "428371000124100",
                "display": "Discharge to healthcare facility for hospice care (procedure)"
              }
            ]
          }
        }
      },
      "request": {
        "method": "PUT",
        "url": "Encounter/ab4b46d8-33f2-4f9d-be9d-555092b9d570.1"
      }
    },
    {
      "resource": {
        "resourceType": "Patient",
        "id": "d4540640-2561-4ebd-b7c6-15878a4dc582",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-patient"
          ]
        },
        "extension": [
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-race",
            "extension": [
              {
                "url": "ombCategory",
                "valueCoding": {
                  "system": "urn:oid:2.16.840.1.113883.6.238",
                  "code": "2028-9",
                  "display": "Asian",
                  "userSelected": true
                }
              },
              {
                "url": "text",
                "valueString": "Asian"
              }
            ]
          },
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-sex",
            "valueCode": "248152002"
          },
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity",
            "extension": [
              {
                "url": "ombCategory",
                "valueCoding": {
                  "system": "urn:oid:2.16.840.1.113883.6.238",
                  "code": "2135-2",
                  "display": "Hispanic or Latino",
                  "userSelected": true
                }
              },
              {
                "url": "text",
                "valueString": "Hispanic or Latino"
              }
            ]
          }
        ],
        "identifier": [
          {
            "type": {
              "coding": [
                {
                  "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                  "code": "MR"
                }
              ]
            },
            "system": "http://hospital.smarthealthit.org",
            "value": "999999995"
          }
        ],
        "name": [
          {
            "family": "Bertha",
            "given": [
              "Betty"
            ]
          }
        ],
        "gender": "female",
        "birthDate": "1952-12-31"
      },
      "request": {
        "method": "PUT",
        "url": "Patient/d4540640-2561-4ebd-b7c6-15878a4dc582"
      }
    },
    {
      "resource": {
        "resourceType": "Encounter",
        "id": "0f9dad06-d212-4480-8dc5-cf58f8c94b00",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-encounter"
          ]
        },
        "status": "finished",
        "class": {
          "system": "http://terminology.hl7.org/CodeSystem/v3-ActCode",
          "code": "AMB",
          "display": "ambulatory"
        },
        "type": [
          {
            "coding": [
              {
                "system": "http://snomed.info/sct",
                "code": "185463005",
                "display": "Visit out of hours (procedure)"
              }
            ]
          }
        ],
        "subject": {
          "reference": "Patient/d4540640-2561-4ebd-b7c6-15878a4dc582"
        },
        "period": {
          "start": "2026-12-31T00:00:00.000+00:00",
          "end": "2026-12-31T23:59:59.000+00:00"
        }
      },
      "request": {
        "method": "PUT",
        "url": "Encounter/0f9dad06-d212-4480-8dc5-cf58f8c94b00"
      }
    },
    {
      "resource": {
        "resourceType": "MedicationRequest",
        "id": "d5bc4b11-5436-4035-a0f8-02e090801a36",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-medicationrequest"
          ]
        },
        "status": "active",
        "intent": "order",
        "doNotPerform": false,
        "medicationCodeableConcept": {
          "coding": [
            {
              "system": "http://www.nlm.nih.gov/research/umls/rxnorm",
              "code": "312836",
              "display": "rivastigmine 6 MG Oral Capsule"
            }
          ]
        },
        "subject": {
          "reference": "Patient/d4540640-2561-4ebd-b7c6-15878a4dc582"
        },
        "authoredOn": "2026-12-30T00:00:00.000+00:00",
        "requester": {
          "reference": "Practitioner/example"
        },
        "dispenseRequest": {
          "expectedSupplyDuration": {
            "value": 90,
            "system": "http://unitsofmeasure.org",
            "code": "days"
          }
        }
      },
      "request": {
        "method": "PUT",
        "url": "MedicationRequest/d5bc4b11-5436-4035-a0f8-02e090801a36"
      }
    },
    {
      "resource": {
        "resourceType": "DeviceRequest",
        "id": "3c1f9ef7-64be-4f08-b5e3-1ba765549173",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-devicerequest"
          ]
        },
        "modifierExtension": [
          {
            "url": "http://hl7.org/fhir/5.0/StructureDefinition/extension-DeviceRequest.doNotPerform",
            "valueBoolean": false
          }
        ],
        "status": "completed",
        "intent": "order",
        "codeCodeableConcept": {
          "coding": [
            {
              "system": "http://snomed.info/sct",
              "code": "183240000",
              "display": "Self-propelled wheelchair (physical object)"
            }
          ]
        },
        "subject": {
          "reference": "Patient/d4540640-2561-4ebd-b7c6-15878a4dc582"
        },
        "authoredOn": "2026-11-01T23:59:00.000+00:00"
      },
      "request": {
        "method": "PUT",
        "url": "DeviceRequest/3c1f9ef7-64be-4f08-b5e3-1ba765549173"
      }
    },
    {
      "resource": {
        "resourceType": "Patient",
        "id": "81dce125-8691-4625-ac6b-07fce0a45680",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-patient"
          ]
        },
        "extension": [
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-race",
            "extension": [
              {
                "url": "ombCategory",
                "valueCoding": {
                  "system": "urn:oid:2.16.840.1.113883.6.238",
                  "code": "2028-9",
                  "display": "Asian"
                }
              },
              {
                "url": "text",
                "valueString": "Asian"
              }
            ]
          },
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-sex",
            "valueCode": "248152002"
          },
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity",
            "extension": [
              {
                "url": "ombCategory",
                "valueCoding": {
                  "system": "urn:oid:2.16.840.1.113883.6.238",
                  "code": "2135-2",
                  "display": "Hispanic or Latino"
                }
              },
              {
                "url": "text",
                "valueString": "Hispanic or Latino"
              }
            ]
          }
        ],
        "identifier": [
          {
            "system": "http://hospital.smarthealthit.org",
            "value": "999999995"
          }
        ],
        "name": [
          {
            "family": "Bertha",
            "given": [
              "Betty"
            ]
          }
        ],
        "gender": "female",
        "birthDate": "1974-12-31"
      },
      "request": {
        "method": "PUT",
        "url": "Patient/81dce125-8691-4625-ac6b-07fce0a45680"
      }
    },
    {
      "resource": {
        "resourceType": "Encounter",
        "id": "b2be8677-d7a7-4142-a32c-42889c47a400",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-encounter"
          ]
        },
        "status": "finished",
        "class": {
          "system": "http://terminology.hl7.org/CodeSystem/v3-ActCode",
          "code": "AMB",
          "display": "ambulatory"
        },
        "type": [
          {
            "coding": [
              {
                "system": "http://snomed.info/sct",
                "code": "185463005",
                "display": "Visit out of hours (procedure)"
              }
            ]
          }
        ],
        "subject": {
          "reference": "Patient/81dce125-8691-4625-ac6b-07fce0a45680"
        },
        "period": {
          "start": "2026-01-01T00:00:00.000+00:00",
          "end": "2026-01-01T00:00:00.000+00:00"
        }
      },
      "request": {
        "method": "PUT",
        "url": "Encounter/b2be8677-d7a7-4142-a32c-42889c47a400"
      }
    },
    {
      "resource": {
        "resourceType": "Observation",
        "id": "34e9fa1d-79f8-47c3-87c6-32354e47f316",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-observation-clinical-result"
          ]
        },
        "status": "final",
        "category": [
          {
            "coding": [
              {
                "system": "http://terminology.hl7.org/CodeSystem/observation-category",
                "code": "imaging"
              }
            ]
          }
        ],
        "code": {
          "coding": [
            {
              "system": "http://loinc.org",
              "code": "24604-1",
              "display": "MG Breast Diagnostic Limited Views"
            }
          ]
        },
        "subject": {
          "reference": "Patient/81dce125-8691-4625-ac6b-07fce0a45680"
        },
        "effectivePeriod": {
          "start": "2026-12-31T23:59:59.000+00:00",
          "end": "2026-12-31T23:59:59.000+00:00"
        },
        "dataAbsentReason": {
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/data-absent-reason",
              "valueCode": "unknown"
            }
          ]
        }
      },
      "request": {
        "method": "PUT",
        "url": "Observation/34e9fa1d-79f8-47c3-87c6-32354e47f316"
      }
    }
  ]
}'

# Facility B - 4 patients (one per CMS125 population category):
#   Patient/aec15569-ccd3-4c5c-8e46-2bec68c03e72  not in initial population
#   Patient/f4d00e60-e525-4644-a397-4d7d970bcfdb  denominator only (no qualifying mammogram)
#   Patient/14193177-2f4e-4480-a471-87ff9d137a8b  denominator exclusion
#   Patient/6226b04f-5e2d-4977-9169-8e9451ffa939  numerator (has qualifying mammogram)
curl --location 'http://localhost:8082/fhir' \
--header 'Content-Type: application/json' \
--data-raw '{
  "resourceType": "Bundle",
  "type": "transaction",
  "entry": [
    {
      "resource": {
        "resourceType": "Patient",
        "id": "aec15569-ccd3-4c5c-8e46-2bec68c03e72",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-patient"
          ]
        },
        "extension": [
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-race",
            "extension": [
              {
                "url": "ombCategory",
                "valueCoding": {
                  "system": "urn:oid:2.16.840.1.113883.6.238",
                  "code": "2028-9",
                  "display": "Asian",
                  "userSelected": true
                }
              },
              {
                "url": "text",
                "valueString": "Asian"
              }
            ]
          },
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-sex",
            "valueCode": "248153007"
          },
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity",
            "extension": [
              {
                "url": "ombCategory",
                "valueCoding": {
                  "system": "urn:oid:2.16.840.1.113883.6.238",
                  "code": "2135-2",
                  "display": "Hispanic or Latino",
                  "userSelected": true
                }
              },
              {
                "url": "text",
                "valueString": "Hispanic or Latino"
              }
            ]
          }
        ],
        "identifier": [
          {
            "type": {
              "coding": [
                {
                  "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                  "code": "MR"
                }
              ]
            },
            "system": "http://hospital.smarthealthit.org",
            "value": "999999995"
          }
        ],
        "name": [
          {
            "family": "Bertha",
            "given": [
              "Betty"
            ]
          }
        ],
        "gender": "male",
        "birthDate": "1952-12-31"
      },
      "request": {
        "method": "PUT",
        "url": "Patient/aec15569-ccd3-4c5c-8e46-2bec68c03e72"
      }
    },
    {
      "resource": {
        "resourceType": "Encounter",
        "id": "c7288487-f3c2-4271-88f3-384aeaee1ab4",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-encounter"
          ]
        },
        "status": "finished",
        "class": {
          "system": "http://terminology.hl7.org/CodeSystem/v3-ActCode",
          "code": "AMB",
          "display": "ambulatory"
        },
        "type": [
          {
            "coding": [
              {
                "system": "http://www.ama-assn.org/go/cpt",
                "code": "99457",
                "display": "Remote physiologic monitoring treatment management services, clinical staff/physician/other qualified health care professional time in a calendar month requiring interactive communication with the patient/caregiver during the month; first 20 minutes"
              }
            ]
          }
        ],
        "subject": {
          "reference": "Patient/aec15569-ccd3-4c5c-8e46-2bec68c03e72"
        },
        "period": {
          "start": "2026-12-31T00:00:00.000+00:00",
          "end": "2026-12-31T23:59:59.000+00:00"
        }
      },
      "request": {
        "method": "PUT",
        "url": "Encounter/c7288487-f3c2-4271-88f3-384aeaee1ab4"
      }
    },
    {
      "resource": {
        "resourceType": "Coverage",
        "id": "0ca98f81-cfae-444e-a539-ac27ac7777df",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-coverage"
          ]
        },
        "identifier": [
          {
            "system": "http://benefitsinc.com/certificate",
            "value": "12345"
          }
        ],
        "status": "active",
        "type": {
          "coding": [
            {
              "system": "https://nahdo.org/sopt",
              "code": "59",
              "display": "Other Private Insurance"
            }
          ]
        },
        "policyHolder": {
          "reference": "Patient/aec15569-ccd3-4c5c-8e46-2bec68c03e72"
        },
        "subscriber": {
          "reference": "Patient/aec15569-ccd3-4c5c-8e46-2bec68c03e72"
        },
        "subscriberId": "12191",
        "beneficiary": {
          "reference": "Patient/aec15569-ccd3-4c5c-8e46-2bec68c03e72"
        },
        "dependent": "0",
        "relationship": {
          "coding": [
            {
              "system": "http://terminology.hl7.org/CodeSystem/subscriber-relationship",
              "code": "self"
            }
          ]
        },
        "period": {
          "start": "2023-01-01T06:00:00.000+00:00",
          "end": "2023-01-01T11:06:01.000+00:00"
        },
        "payor": [
          {
            "reference": "Patient/aec15569-ccd3-4c5c-8e46-2bec68c03e72"
          }
        ],
        "order": 9
      },
      "request": {
        "method": "PUT",
        "url": "Coverage/0ca98f81-cfae-444e-a539-ac27ac7777df"
      }
    },
    {
      "resource": {
        "resourceType": "Patient",
        "id": "f4d00e60-e525-4644-a397-4d7d970bcfdb",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-patient"
          ]
        },
        "extension": [
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-race",
            "extension": [
              {
                "url": "ombCategory",
                "valueCoding": {
                  "system": "urn:oid:2.16.840.1.113883.6.238",
                  "code": "2028-9",
                  "display": "Asian"
                }
              },
              {
                "url": "text",
                "valueString": "Asian"
              }
            ]
          },
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-sex",
            "valueCode": "248152002"
          },
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity",
            "extension": [
              {
                "url": "ombCategory",
                "valueCoding": {
                  "system": "urn:oid:2.16.840.1.113883.6.238",
                  "code": "2135-2",
                  "display": "Hispanic or Latino"
                }
              },
              {
                "url": "text",
                "valueString": "Hispanic or Latino"
              }
            ]
          }
        ],
        "identifier": [
          {
            "system": "http://hospital.smarthealthit.org",
            "value": "999999995"
          }
        ],
        "name": [
          {
            "family": "Bertha",
            "given": [
              "Betty"
            ]
          }
        ],
        "gender": "female",
        "birthDate": "1974-12-31"
      },
      "request": {
        "method": "PUT",
        "url": "Patient/f4d00e60-e525-4644-a397-4d7d970bcfdb"
      }
    },
    {
      "resource": {
        "resourceType": "Encounter",
        "id": "344ec536-2f6a-4b34-a4e1-74461778cd5a",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-encounter"
          ]
        },
        "status": "finished",
        "class": {
          "system": "http://terminology.hl7.org/CodeSystem/v3-ActCode",
          "code": "AMB",
          "display": "ambulatory"
        },
        "type": [
          {
            "coding": [
              {
                "system": "http://snomed.info/sct",
                "code": "185463005",
                "display": "Visit out of hours (procedure)"
              }
            ]
          }
        ],
        "subject": {
          "reference": "Patient/f4d00e60-e525-4644-a397-4d7d970bcfdb"
        },
        "period": {
          "start": "2026-01-01T00:00:00.000+00:00",
          "end": "2026-01-01T00:00:00.000+00:00"
        }
      },
      "request": {
        "method": "PUT",
        "url": "Encounter/344ec536-2f6a-4b34-a4e1-74461778cd5a"
      }
    },
    {
      "resource": {
        "resourceType": "Observation",
        "id": "d93c37fc-04bb-4c17-b48e-0e88e2c9eb36",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-observation-clinical-result"
          ]
        },
        "status": "final",
        "category": [
          {
            "coding": [
              {
                "system": "http://terminology.hl7.org/CodeSystem/observation-category",
                "code": "imaging"
              }
            ]
          }
        ],
        "code": {
          "coding": [
            {
              "system": "http://loinc.org",
              "code": "24604-1",
              "display": "MG Breast Diagnostic Limited Views"
            }
          ]
        },
        "subject": {
          "reference": "Patient/f4d00e60-e525-4644-a397-4d7d970bcfdb"
        },
        "effectivePeriod": {
          "start": "2027-01-01T00:00:00.000+00:00",
          "end": "2027-01-01T00:00:00.000+00:00"
        },
        "dataAbsentReason": {
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/data-absent-reason",
              "valueCode": "unknown"
            }
          ]
        }
      },
      "request": {
        "method": "PUT",
        "url": "Observation/d93c37fc-04bb-4c17-b48e-0e88e2c9eb36"
      }
    },
    {
      "resource": {
        "resourceType": "Patient",
        "id": "14193177-2f4e-4480-a471-87ff9d137a8b",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-patient"
          ]
        },
        "extension": [
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-race",
            "extension": [
              {
                "url": "ombCategory",
                "valueCoding": {
                  "system": "urn:oid:2.16.840.1.113883.6.238",
                  "code": "2028-9",
                  "display": "Asian"
                }
              },
              {
                "url": "text",
                "valueString": "Asian"
              }
            ]
          },
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-sex",
            "valueCode": "248152002"
          },
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity",
            "extension": [
              {
                "url": "ombCategory",
                "valueCoding": {
                  "system": "urn:oid:2.16.840.1.113883.6.238",
                  "code": "2135-2",
                  "display": "Hispanic or Latino"
                }
              },
              {
                "url": "text",
                "valueString": "Hispanic or Latino"
              }
            ]
          }
        ],
        "identifier": [
          {
            "system": "http://hospital.smarthealthit.org",
            "value": "999999995"
          }
        ],
        "name": [
          {
            "family": "Bertha",
            "given": [
              "Betty"
            ]
          }
        ],
        "gender": "female",
        "birthDate": "1974-12-31"
      },
      "request": {
        "method": "PUT",
        "url": "Patient/14193177-2f4e-4480-a471-87ff9d137a8b"
      }
    },
    {
      "resource": {
        "resourceType": "Encounter",
        "id": "7f45a961-1dc2-4880-bfc8-da63b47eeada",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-encounter"
          ]
        },
        "status": "finished",
        "class": {
          "system": "http://terminology.hl7.org/CodeSystem/v3-ActCode",
          "code": "AMB",
          "display": "ambulatory"
        },
        "type": [
          {
            "coding": [
              {
                "system": "http://snomed.info/sct",
                "code": "185463005",
                "display": "Visit out of hours (procedure)"
              }
            ]
          }
        ],
        "subject": {
          "reference": "Patient/14193177-2f4e-4480-a471-87ff9d137a8b"
        },
        "period": {
          "start": "2026-01-01T00:00:00.000+00:00",
          "end": "2026-01-01T00:00:00.000+00:00"
        }
      },
      "request": {
        "method": "PUT",
        "url": "Encounter/7f45a961-1dc2-4880-bfc8-da63b47eeada"
      }
    },
    {
      "resource": {
        "resourceType": "Observation",
        "id": "052d61a4-07ab-4cd1-93db-c3bdc08d29cc",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-observation-screening-assessment"
          ]
        },
        "status": "final",
        "category": [
          {
            "coding": [
              {
                "system": "http://terminology.hl7.org/CodeSystem/observation-category",
                "code": "survey"
              }
            ]
          }
        ],
        "code": {
          "coding": [
            {
              "system": "http://loinc.org",
              "code": "71007-9",
              "display": "Functional Assessment of Chronic Illness Therapy - Palliative Care Questionnaire (FACIT-Pal)"
            }
          ]
        },
        "subject": {
          "reference": "Patient/14193177-2f4e-4480-a471-87ff9d137a8b"
        },
        "effectivePeriod": {
          "start": "2026-01-01T00:00:00.000+00:00",
          "end": "2026-01-01T00:00:00.000+00:00"
        },
        "dataAbsentReason": {
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/data-absent-reason",
              "valueCode": "unknown"
            }
          ]
        }
      },
      "request": {
        "method": "PUT",
        "url": "Observation/052d61a4-07ab-4cd1-93db-c3bdc08d29cc"
      }
    },
    {
      "resource": {
        "resourceType": "Patient",
        "id": "6226b04f-5e2d-4977-9169-8e9451ffa939",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-patient"
          ]
        },
        "extension": [
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-race",
            "extension": [
              {
                "url": "ombCategory",
                "valueCoding": {
                  "system": "urn:oid:2.16.840.1.113883.6.238",
                  "code": "2028-9",
                  "display": "Asian"
                }
              },
              {
                "url": "text",
                "valueString": "Asian"
              }
            ]
          },
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-sex",
            "valueCode": "248152002"
          },
          {
            "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity",
            "extension": [
              {
                "url": "ombCategory",
                "valueCoding": {
                  "system": "urn:oid:2.16.840.1.113883.6.238",
                  "code": "2135-2",
                  "display": "Hispanic or Latino"
                }
              },
              {
                "url": "text",
                "valueString": "Hispanic or Latino"
              }
            ]
          }
        ],
        "identifier": [
          {
            "system": "http://hospital.smarthealthit.org",
            "value": "999999995"
          }
        ],
        "name": [
          {
            "family": "Bertha",
            "given": [
              "Betty"
            ]
          }
        ],
        "gender": "female",
        "birthDate": "1974-12-31"
      },
      "request": {
        "method": "PUT",
        "url": "Patient/6226b04f-5e2d-4977-9169-8e9451ffa939"
      }
    },
    {
      "resource": {
        "resourceType": "Encounter",
        "id": "ad357333-2b2e-449b-ba4e-33681c766cfe",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-encounter"
          ]
        },
        "status": "finished",
        "class": {
          "system": "http://terminology.hl7.org/CodeSystem/v3-ActCode",
          "code": "AMB",
          "display": "ambulatory"
        },
        "type": [
          {
            "coding": [
              {
                "system": "http://snomed.info/sct",
                "code": "185463005",
                "display": "Visit out of hours (procedure)"
              }
            ]
          }
        ],
        "subject": {
          "reference": "Patient/6226b04f-5e2d-4977-9169-8e9451ffa939"
        },
        "period": {
          "start": "2026-01-01T00:00:00.000+00:00",
          "end": "2026-01-01T00:00:00.000+00:00"
        }
      },
      "request": {
        "method": "PUT",
        "url": "Encounter/ad357333-2b2e-449b-ba4e-33681c766cfe"
      }
    },
    {
      "resource": {
        "resourceType": "Observation",
        "id": "d71d15aa-9db3-4377-97fb-a429711cf1f0",
        "meta": {
          "profile": [
            "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-observation-clinical-result"
          ]
        },
        "status": "final",
        "category": [
          {
            "coding": [
              {
                "system": "http://terminology.hl7.org/CodeSystem/observation-category",
                "code": "imaging"
              }
            ]
          }
        ],
        "code": {
          "coding": [
            {
              "system": "http://loinc.org",
              "code": "24604-1",
              "display": "MG Breast Diagnostic Limited Views"
            }
          ]
        },
        "subject": {
          "reference": "Patient/6226b04f-5e2d-4977-9169-8e9451ffa939"
        },
        "effectivePeriod": {
          "start": "2024-10-01T00:00:00.000+00:00",
          "end": "2024-10-01T00:00:00.000+00:00"
        },
        "dataAbsentReason": {
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/data-absent-reason",
              "valueCode": "unknown"
            }
          ]
        }
      },
      "request": {
        "method": "PUT",
        "url": "Observation/d71d15aa-9db3-4377-97fb-a429711cf1f0"
      }
    }
  ]
}'
