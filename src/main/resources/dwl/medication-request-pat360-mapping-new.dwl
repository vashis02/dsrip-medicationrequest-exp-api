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
        id: payload01."ENC_MED_KEY" default "",
        subject: {
          reference: "Patient" ++ "/" ++ payload01."PATIENT_ID"
        },
        identifier: [
          {
            use: "usual",
            value: payload01."MED_ORDER_ID" default "",
            assigner: {
              display: payload01."SOURCE_PARTNER_NAME" default ""
            }
          }
        ],
        context: {
          display: payload01."ENCOUNTER_ID" default ""
        },
        intent: "order",
        priority: "routine",
        medicationCodeableConcept: {
          coding: [
            {
              code: payload01."MEDICATION_CODE" default "",
              display: payload01."MEDICATION_NAME" default ""
            }
          ],
          text: payload01."MEDICATION_NAME" default ""
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
                toUTC(payload01."MEDICATION_START_DATE")
              else
                "",
            end: 
              if (not payload01."MEDICATION_END_DATE" == null)
                toUTC(payload01."MEDICATION_END_DATE")
              else
                ""
          },
          numberOfRepeatsAllowed: payload01.REFILLS default ""
        },
        dosageInstruction: [
          {
            doseQuantity: {
              unit: payload01."MEDICATION_QUANTITY" default ""
            },
            route: {
              text: payload01.ROUTE default ""
            },
            text: payload01.SIG default ""
          }
        ],
        requester: {
          agent: {
            reference: "Practitioner/" ++ payload01."MEDICATION_ORDERING_CAREGIVER"
          }
        }
      }
    }
  }