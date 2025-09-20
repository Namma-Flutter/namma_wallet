import 'package:intl/intl.dart';

String getDate(DateTime dt) {
  return DateFormat('hh:mm a').format(dt).toLowerCase(); // 10:00 am
}

String getTime(DateTime dt) {
  return DateFormat('dd/MM/yyyy').format(dt); // 03/11/2025
}
