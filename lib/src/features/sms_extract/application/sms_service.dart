
import 'package:android_sms_reader/android_sms_reader.dart';

 Future<void> _initPlugin() async {
    final granted = await AndroidSMSReader.requestPermissions();
    if (granted) {
      await _loadInitialMessages();
      _startSmsStream();
    } else {
      if (kDebugMode) {
        print("SMS permission denied");
      }
    }
  }

  Future<void> _loadInitialMessages() async {
    final fetched = await AndroidSMSReader.fetchMessages(
      type: AndroidSMSType.inbox,
      start: 0,
      count: 20, 
      
    );
    setState(() {
      messages = fetched;
    });
  }

  void _startSmsStream() {
    if (isListening) return;
    smsStream = AndroidSMSReader.observeIncomingMessages();
    smsStream!.listen((AndroidSMSMessage message) {
      setState(() {
        messages.insert(0, message); // insert latest at top
      });
    });
    isListening = true;
  }