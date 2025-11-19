# Share Feature Usage Guide

## For Users

### How to Share Content to Namma Wallet

1. **From SMS App**
   - Open a ticket SMS
   - Tap Share button
   - Select "Namma Wallet"
   - Choose "Travel Ticket"

2. **From Gallery/Photos**
   - Open a ticket screenshot or QR code
   - Tap Share button
   - Select "Namma Wallet"
   - Choose appropriate type (Travel Ticket, Event Pass, or QR Code)

3. **From Files/Downloads**
   - Open a PDF ticket
   - Tap Share button
   - Select "Namma Wallet"
   - Choose "Travel Ticket" or "Document"

4. **From Email**
   - Open email with ticket attachment
   - Tap attachment
   - Tap Share button
   - Select "Namma Wallet"
   - Choose appropriate type

## For Developers

### Adding Share Functionality to a Screen

```dart
import 'package:namma_wallet/src/features/share/presentation/share_content_view.dart';

// Show the share modal
showShareContentModal(
  context,
  onShare: (type, title) {
    // Handle the selected type
    print('User selected: $title');
    
    // Process based on type
    switch (type) {
      case ShareContentType.ticket:
        // Process as ticket
        break;
      case ShareContentType.event:
        // Process as event
        break;
      case ShareContentType.qr:
        // Process as QR code
        break;
      case ShareContentType.document:
        // Process as document
        break;
    }
  },
);
```

### Processing Shared Files

```dart
import 'package:namma_wallet/src/features/share/application/share_handler_service.dart';

final shareHandler = ShareHandlerService(logger: logger);

// Process a shared file
final content = await shareHandler.processSharedFile(filePath);

// Check content type
if (content.type == SharedContentType.pdf) {
  // Handle PDF
} else if (content.type == SharedContentType.image) {
  // Handle image
} else if (content.type == SharedContentType.text) {
  // Handle text
}
```

### Testing the Share Modal

Add the test button to any screen:

```dart
import 'package:namma_wallet/src/features/share/presentation/share_test_button.dart';

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Test Screen')),
    body: Center(child: Text('Test')),
    floatingActionButton: const ShareTestButton(),
  );
}
```

## Content Type Guidelines

### Travel Ticket
Use for:
- Train tickets (IRCTC, local trains)
- Bus tickets (TNSTC, SETC, private buses)
- Flight tickets
- Metro tickets

### Event Pass
Use for:
- Concert tickets
- Movie tickets
- Sports event tickets
- Conference passes

### QR Code
Use for:
- Any QR code-based ticket
- Digital passes with QR codes
- Parking tickets with QR codes

### Document
Use for:
- Boarding passes
- Vouchers
- Coupons
- General documents with ticket info

## Troubleshooting

### Share Option Not Appearing
- Ensure the app is installed
- Check if the content type is supported (PDF, image, or text)
- Restart the app

### Modal Not Showing
- Check logs for errors
- Ensure navigation context is available
- Verify sharing intent service is initialized

### Content Not Processing
- Check file permissions
- Verify file format is supported
- Check logs for detailed error messages
