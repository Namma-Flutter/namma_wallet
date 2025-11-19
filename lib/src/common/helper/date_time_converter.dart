import 'package:intl/intl.dart';

String getDate(DateTime dt) {
  // Convert to local time before formatting to
  // handle UTC datetimes from database
  final local = dt.toLocal();
  return DateFormat('hh:mm a').format(local).toLowerCase(); // 10:00 am
}

String getTime(DateTime dt) {
  // Convert to local time before formatting to handle
  // UTC datetimes from database
  final local = dt.toLocal();
  return DateFormat('dd/MM/yyyy').format(local); // 03/11/2025
}
