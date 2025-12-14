import 'package:android_sms_reader/android_sms_reader.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/ai/fallback_parser/application/gemma_service.dart';


Future<List<AndroidSMSMessage?>> initSMSParse() async {
  final getIt = GetIt.instance;
  final granted = await AndroidSMSReader.requestPermissions();
  if (granted) {
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
    final gemmaService= GemmaService(logger: getIt<ILogger>());
   await gemmaService.init();
   await gemmaService.parseBatch(fetched.map((e)=>e.body).toList());
    return fetched;
  } else {
    if (kDebugMode) {
      print("SMS permission denied");
    }
    return [];
  }
}
