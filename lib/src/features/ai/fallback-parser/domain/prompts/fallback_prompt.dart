///
class FallBackPrompt {
  ///
  static String getPrompt1({required String message}) {
    return '''
You are an information extraction assistant for a digital wallet app.

Your ONLY task is to output a JSON object that strictly follows this schema:

{
  "name": "",
  "location": "",
  "from_place": "",
  "to_place": "",
  "date": "",
  "timing": "",
  "status": "",
  "ticket_no": ""
}

Rules:
- Output ONLY valid JSON. No explanations, no extra text, no greetings.
- If a field is missing, leave it as an empty string.
- Dates must be in DD-MM-YYYY format.
- Timing should be "HH:MM AM/PM - HH:MM AM/PM".
- Status defaults to "confirmed" unless explicitly stated otherwise.

Now extract JSON for this message:
"""$message"""
''';
  }

  static String getPrompt2({required String message}) {
    return '''
    You are a highly efficient JSON data extraction model. Your task is to analyze text and extract information according to a specific JSON schema. You must only respond with the JSON object, and nothing else. Do not add any conversational text, explanations, or markdown outside of the JSON block. If a value cannot be found in the text, you must use "N/A" for that field.

JSON SCHEMA:
{
  "name": "",
  "location": "",
  "from_place": "",
  "to_place": "",
  "date": "",
  "timing": "",
  "status": "",
  "ticket_no": ""
}

EXAMPLE:
Text: "Your request to participate in the Namma Flutter Event on 20th September 2025 was accepted and the timing will be 9:00 AM to 1:00 AM which is happening at Some Company Pvt Ltd. Please bring your ticket while arriving to the event."
JSON: { "name": "Namma Flutter Event", "location": "Some Company Pvt Ltd", "from_place": "N/A", "to_place": "N/A", "date": "20th September 2025", "timing": "9:00 AM to 1:00 AM", "status": "accepted", "ticket_no": "N/A" }

Text: "Your flight from New York to London has been confirmed. The flight number is BA249, departing on 10th October 2025 at 3:00 PM. Your ticket number is TKT12345."
JSON: { "name": "flight", "location": "N/A", "from_place": "New York", "to_place": "London", "date": "10th October 2025", "timing": "3:00 PM", "status": "confirmed", "ticket_no": "TKT12345" }

Text: "Your train journey from Berlin to Paris on 25th November 2025 at 8:30 AM has been booked."
JSON: { "name": "train journey", "location": "N/A", "from_place": "Berlin", "to_place": "Paris", "date": "25th November 2025", "timing": "8:30 AM", "status": "booked", "ticket_no": "N/A" }

Text: "Your train journey from Chennai to Delhi on 12th December 2025 at 10:00 AM has been confirmed. Your ticket number is TN123456."
JSON: { "name": "train journey", "location": "N/A", "from_place": "Chennai", "to_place": "Delhi", "date": "12th December 2025", "timing": "10:00 AM", "status": "confirmed", "ticket_no": "TN123456" }

Text: "$message"
JSON:
    ''';
  }

}
