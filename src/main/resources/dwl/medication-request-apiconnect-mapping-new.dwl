%dw 2.0
output application/json  skipNullOn="everywhere"
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
        id: payload01."ENC_MED_KEY",
        subject: {
          reference: "Patient" ++ "/" ++ payload01."PATIENT_ID"
        },
        identifier: [
          {
            use: "usual",
            value: payload01."MED_ORDER_ID",
            assigner: {
              display: payload01."SOURCE_PARTNER_NAME"
            }
          }
        ],
        context: {
          display: payload01."ENCOUNTER_ID"
        },
        intent: "order",
        priority: "routine",
        medicationCodeableConcept: {
          coding: [
            {
              code: payload01."MEDICATION_CODE",
              display: payload01."MEDICATION_NAME"
            }
          ],
          text: payload01."MEDICATION_NAME"
        },
        status: 
          if (payload01."MEDICATION_CATEGORY" == "Suspend")
            "on-hold"
          else (if (payload01."MEDICATION_CATEGORY" == "Verified")
            "active"
          else (if (payload01."MEDICATION_CATEGORY" == "Discontinued")
            "stopped"
          else (if (payload01."MEDICATION_CATEGORY" == "Completed")
            "completed"
          else (if (payload01."MEDICATION_CATEGORY" == "Dispensed")
            "active"
          else (if (payload01."MEDICATION_CATEGORY" == "Sent")
            "unknown"
          else (if (payload01."MEDICATION_CATEGORY" == "Canceled")
            "cancelled"
          else (if (payload01."MEDICATION_CATEGORY" == "Others")
            "unknown"
          else
            ""))))))),
        dispenseRequest: {
          validityPeriod: {
            start: 
              if (not payload01."MEDICATION_START_DATE" == null)
                payload01."MEDICATION_START_DATE" as Localdatetime {format: "yyyy-MM-dd'T'HH:mm:ss"} as String {format: "yyyy-MM-dd"}
              else
                null,
            end: 
              if (not payload01."MEDICATION_END_DATE" == null)
                payload01."MEDICATION_END_DATE" as Localdatetime {format: "yyyy-MM-dd'T'HH:mm:ss"} as String {format: "yyyy-MM-dd"}
              else
                null
          },
          numberOfRepeatsAllowed: payload01.REFILLS
        },
        dosageInstruction: [
          {
            doseQuantity: {
              unit: payload01."MEDICATION_QUANTITY"
            },
            route: {
              text: payload01.ROUTE
            },
            text: payload01.SIG
          }
        ],
        requester: {
          agent: {
            reference: 
              if (not payload01."MEDICATION_ORDERING_CAREGIVER" == null)
                "Practitioner/" ++ payload01."MEDICATION_ORDERING_CAREGIVER"
              else
                null
          }
        }
      }
    }
  }