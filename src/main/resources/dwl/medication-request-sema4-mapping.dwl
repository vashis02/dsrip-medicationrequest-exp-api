%dw 2.0
output application/json  
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
      fullUrl: "https://apiconnect-dev.mountsinai.org/api/MedicationRequest/" ++ indexOfPayload01,
      resource: {
        resourceType: "MedicationRequest",
        intent: "order",
        priority: "routine",
        medicationCodeableConcept: {
          text: payload01.DESCRIPTION,
          coding: [
            {
              display: payload01.DESCRIPTION,
              code: payload01."MEDICATION_ID"
            }
          ]
        },
        subject: {
          reference: "MEDICAL_RECORD_NUMBER/" ++ payload01."MEDICAL_RECORD_NUMBER"
        },
        context: {
          display: payload01."CSN_ID"
        },
        identifier: [
          {
            use: "official",
            value: payload01."MEDICATION_ORDER_ID"
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
        status: 
          if (payload01."MEDICATION_ORDER_STATUS" == "Others")
            "unknown"
          else (if (payload01."MEDICATION_ORDER_STATUS" == "Suspend")
            "stopped"
          else (if (payload01."MEDICATION_ORDER_STATUS" == "Verified")
            "unknown"
          else (if (payload01."MEDICATION_ORDER_STATUS" == "Pending Verify")
            "unknown"
          else (if (payload01."MEDICATION_ORDER_STATUS" == "Discontinued")
            "stopped"
          else (if (payload01."MEDICATION_ORDER_STATUS" == "Completed")
            "completed"
          else (if (payload01."MEDICATION_ORDER_STATUS" == "Dispensed")
            "unknown"
          else (if (payload01."MEDICATION_ORDER_STATUS" == "Sent")
            "unknown"
          else (if (payload01."MEDICATION_ORDER_STATUS" == "Canceled")
            "cancelled"
          else
            "unknown")))))))),
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
          performer: {
            display: payload01."MEDICATION_ORDER_FACILITY"
          },
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
            url: "http://www.mountsinai.org/",
            valueCoding: {
              code: "entryDate",
              display: 
                if (not payload01."ENTRY_DATE" == null)
                  payload01."ENTRY_DATE" as Localdatetime {format: "yyyy-MM-dd'T'HH:mm:ss"} as String {format: "yyyy-MM-dd"}
                else
                  null
            }
          },
          {
            url: "http://www.mountsinai.org/",
            valueCoding: {
              code: "refillsRemaining",
              display: payload01."REFILLS_REMAINING"
            }
          }
        ],
        requester: {
          agent: {
            reference: "Practitioner/" ++ payload01.NAME
          }
        },
        note: [
          {
            text: payload01."MED_COMMENTS"
          }
        ]
      }
    }
  }