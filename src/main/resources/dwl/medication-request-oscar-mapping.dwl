%dw 2.0
output application/json  
fun statusMapping(status) =
  if (status == "Taking")
    "active"
  else (if (status == "Void" or status == "Canceled" or status == "Declined")
    "cancelled"
  else (if (status == "Complete" or status == "Finished" or status == "Completed")
    "completed"
  else (if (status == "Hold" or status == "hold pending" or status == "Hold on to in order to start")
    "on-hold"
  else (if (status == "Discontinued" or status == "Stopped on own" or status == "Suspend" or status == "Discontinue" or status == "Stop" or status == "Stopped")
    "stopped"
  else
    ("unknown")))))
---
if (payload.status == 204)
  payload
else
  {
    resourceType: "Bundle",
    "type": "searchset",
    meta: {
      lastUpdated: now()
    },
    entry: payload map (payload01, indexOfPayload01) -> {
      fullUrl: 
        if (p("mule.env") == "prod")
          ("https://apiconnect.mountsinai.org/api/MedicationRequest/" ++ indexOfPayload01)
        else
          "https://apiconnect-dev.mountsinai.org/api/MedicationRequest/" ++ indexOfPayload01,
      resource: {
        resourceType: "MedicationRequest",
        intent: "order",
        priority: "routine",
        medicationCodeableConcept: {
          text: payload01.DESCRIPTION,
          coding: [
            {
              display: payload01.DESCRIPTION,
              code: payload01."MEDICATION_ID",
              version: payload01."MEDICATION_CODING_SYSTEM"
            }
          ]
        },
        subject: {
          reference: "MEDICAL_RECORD_NUMBER/" ++ payload01."MEDICAL_RECORD_NUMBER"
        },
        context: {
          reference: 
            if (not payload01."CSN_ID" == null)
              "CSN_ID/" ++ payload01."CSN_ID"
            else
              null
        },
        identifier: [
          {
            use: "official",
            value: payload01."MEDICATION_ORDER_ID"
          },
          {
            use: "usual",
            value: payload01."DATA_SOURCE_NAME"
          }
        ],
        category: {
          text: payload01."MEDICATION_ORDER_CLASS",
          coding: [
            {
              display: payload01."MEDICATION_ORDER_CLASS"
            }
          ]
        },
        status: statusMapping(payload01."MEDICATION_ORDER_STATUS"),
        authoredOn: 
          if (not payload01."MEDICATION_ORDER_DATE_TIME" == null)
            payload01."MEDICATION_ORDER_DATE_TIME" as Localdatetime {format: "yyyy-MM-dd'T'HH:mm:ss"} as String {format: "yyyy-MM-dd"}
          else
            null,
        dosageInstruction: [
          {
            text: payload01.SIG,
            route: {
              text: payload01.ROUTE,
              coding: [
                {
                  display: payload01.ROUTE
                }
              ]
            }
          }
        ],
        dispenseRequest: {
          numberOfRepeatsAllowed: payload01.REFILLS,
          quantity: {
            unit: payload01."DISPENSE_UNIT"
          },
          validityPeriod: {
            start: 
              if (not payload01."START_DATE" == null)
                payload01."START_DATE" as Localdatetime {format: "yyyy-MM-dd'T'HH:mm:ss"} as String {format: "yyyy-MM-dd"}
              else
                null,
            end: 
              if (not payload01."END_DATE" == null)
                payload01."END_DATE" as Localdatetime {format: "yyyy-MM-dd'T'HH:mm:ss"} as String {format: "yyyy-MM-dd"}
              else
                null
          }
        },
        extension: [
          {
            url: "http://hl7.org/fhir/StructureDefinition",
            valueCoding: {
              version: "entryDate",
              display: 
                if (not payload01."ENTRY_DATE" == null)
                  payload01."ENTRY_DATE" as Localdatetime {format: "yyyy-MM-dd'T'HH:mm:ss"} as String {format: "yyyy-MM-dd"}
                else
                  null
            }
          }
        ],
        requester: {
          agent: {
            reference: "Practitioner/" ++ payload01."ORDERING_PROVIDER_ID",
            display: payload01."ORDERING_PROVIDER_NAME"
          },
          modifierExtension: [
            {
              url: "http://hl7.org/fhir/StructureDefinition",
              valueCoding: {
                version: "requesterType",
                display: payload01."ORDERING_PROVIDER_TYPE"
              }
            }
          ]
        },
        note: [
          {
            text: payload01."MED_COMMENTS"
          }
        ]
      }
    }
  }