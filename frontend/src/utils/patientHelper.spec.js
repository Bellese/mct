import { gatherPatientDisplayData } from './patientHelper'

describe('patientHelper', () => {
  describe('gatherPatientDisplayData', () => {
    it('should return necessary values for displaying patient info', () => {
      const { name, mrn, gender, birthDate} = gatherPatientDisplayData(fixtureData)
      expect(birthDate).toBe('1955-11-05')
      expect(name).toBe('Rick Jones')
      expect(gender).toBe('M')
      expect(mrn).toBe('9999999910')
    })
  })
})

const fixtureData = {
  "resourceType": "Patient",
  "id": "denom-EXM104",
  "meta": {
    "versionId": "1",
    "lastUpdated": "2020-01-29T16:25:09.734-07:00",
    "profile": [
      "http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient"
    ]
  },
  "text": {
    "status": "generated",
    "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\"><div class=\"hapiHeaderText\">Rick <b>JONES </b></div><table class=\"hapiPropertyTable\"><tbody><tr><td>Identifier</td><td>9999999910</td></tr><tr><td>Date of birth</td><td><span>05 November 1955</span></td></tr></tbody></table></div>"
  },
  "extension": [
    {
      "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-race",
      "extension": [
        {
          "url": "ombCategory",
          "valueCoding": {
            "system": "urn:oid:2.16.840.1.113883.6.238",
            "code": "2054-5",
            "display": "Black or African American"
          }
        }
      ]
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
        }
      ]
    }
  ],
  "identifier": [
    {
      "use": "usual",
      "type": {
        "coding": [
          {
            "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
            "code": "MR",
            "display": "Medical Record Number"
          }
        ]
      },
      "system": "http://hospital.smarthealthit.org",
      "value": "9999999910"
    }
  ],
  "name": [
    {
      "family": "Jones",
      "given": [
        "Rick"
      ]
    }
  ],
  "gender": "male",
  "birthDate": "1955-11-05"
}