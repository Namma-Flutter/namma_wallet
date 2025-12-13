import 'package:android_sms_reader/android_sms_reader.dart';
import 'package:flutter/foundation.dart';


Future<List<AndroidSMSMessage?>> initSMSRead() async {
  print("inside fun");
  bool isListening = false;
  List<AndroidSMSMessage> messages = [];
  Stream<AndroidSMSMessage>? smsStream;
  final granted = await AndroidSMSReader.requestPermissions();
  if (granted) {
    print("granted");
    final fetched = await AndroidSMSReader.fetchMessages(
      type: AndroidSMSType.inbox,
      start: 0,
      count: 20,
    );
    print(fetched.length);
    for (final element in fetched) {
      print(element.address);
      print(element.date);
      print(element.type);
      print(element.body);
    }
    return fetched;
    // if (isListening) return;
    // smsStream = AndroidSMSReader.observeIncomingMessages()
    // ..listen((AndroidSMSMessage message) {
    //   messages.insert(0, message); // insert latest at top
    // });
    // isListening = true;
  } else {
    if (kDebugMode) {
      print("SMS permission denied");
    }
    return [];
  }
}
