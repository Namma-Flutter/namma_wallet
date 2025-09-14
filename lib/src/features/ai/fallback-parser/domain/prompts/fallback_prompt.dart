/// A utility class to generate a fallback prompt for information extraction.
class FallBackPrompt {
  ///
  static String getPrompt({required String message}) {
    return """
You are an information extraction assistant for a digital wallet app. 
Your task is to carefully read the user's input message or 
QR decoded text and extract ticket or event details into the app’s standard format.

Always return ONLY in the following JSON format:

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

Guidelines:
- "name": Person, event, or card name (whichever is most relevant).
- "location": Venue, station, or place of occurrence.
- "from_place" and "to_place": For transport tickets (bus, train, flight). Leave empty if not available.
- "date": The specific date of the event or journey in DD-MM-YYYY format.
- "timing": Start and end time range (e.g., "09:00 AM - 01:00 AM").
- "status": Whether confirmed, accepted, pending, or rejected. If not explicitly mentioned, default to "confirmed".
- "ticket_no": The ticket, booking, or reference number if available, otherwise leave empty.

If some information is not available, leave the field as an empty string.
Do not add extra explanations or text.

Message: '''$message'''
""";
  }
}
