# Share Feature

This feature enables the Namma Wallet app to receive shared content from other apps on Android.

## Supported Content Types

The app can receive and process:

- **Text** (SMS messages, plain text)
- **Images** (screenshots, photos, QR codes)
- **PDFs** (tickets, boarding passes, documents)

## User Flow

1. User shares content from another app (SMS, Gallery, Files, etc.)
2. Namma Wallet appears in the share sheet
3. User selects Namma Wallet
4. App shows a modal with content type options:
   - Travel Ticket (train, bus, flight)
   - Event Pass (concerts, events)
   - QR Code (any QR code ticket)
   - Document (boarding pass, voucher)
5. User selects the appropriate type
6. App processes the content accordingly

## Implementation

### Files

- `presentation/share_content_view.dart` - Modal UI for selecting content type
- `application/share_handler_service.dart` - Service for processing shared content

### Android Configuration

The `AndroidManifest.xml` includes intent filters for:
- `android.intent.action.SEND` with `application/pdf`
- `android.intent.action.SEND` with `image/*`
- `android.intent.action.SEND` with `text/plain`
- `android.intent.action.SEND_MULTIPLE` for multiple files

### Integration

The share functionality is integrated in `lib/src/app.dart` via the `SharingIntentService` which:
1. Listens for incoming share intents
2. Processes the shared file/content
3. Shows the share content modal
4. Routes to appropriate processing based on user selection

## TODO

- [ ] Implement PDF ticket extraction
- [ ] Implement image OCR/QR scanning
- [ ] Implement event pass processing
- [ ] Implement document processing
- [ ] Add support for multiple file sharing
- [ ] Add preview of shared content in modal
