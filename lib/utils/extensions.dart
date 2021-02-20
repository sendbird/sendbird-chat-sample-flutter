import 'package:intl/intl.dart';

extension DateUtil on int {
  String readableTimestamp() {
    final formatter = new DateFormat('HH:mm a');
    final date = new DateTime.fromMicrosecondsSinceEpoch(this);
    return formatter.format(date);
  }
}
