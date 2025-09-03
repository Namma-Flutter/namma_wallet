class TicketModel {
  final String corporation;
  final String service;
  final String pnrNo;
  final String from;
  final String to;
  final String tripCode;
  final String journeyDate;
  final String time;
  final List<String> seatNumbers;
  final String ticketClass;
  final String boardingAt;

  TicketModel({
    required this.corporation,
    required this.service,
    required this.pnrNo,
    required this.from,
    required this.to,
    required this.tripCode,
    required this.journeyDate,
    required this.time,
    required this.seatNumbers,
    required this.ticketClass,
    required this.boardingAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      corporation: json['corporation'] ?? '',
      service: json['service'] ?? '',
      pnrNo: json['pnr_no'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      tripCode: json['trip_code'] ?? '',
      journeyDate: json['journey_date'] ?? '',
      time: json['time'] ?? '',
      seatNumbers: List<String>.from(json['seat_numbers'] ?? []),
      ticketClass: json['class'] ?? '',
      boardingAt: json['boarding_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'corporation': corporation,
      'service': service,
      'pnr_no': pnrNo,
      'from': from,
      'to': to,
      'trip_code': tripCode,
      'journey_date': journeyDate,
      'time': time,
      'seat_numbers': seatNumbers,
      'class': ticketClass,
      'boarding_at': boardingAt,
    };
  }

  @override
  String toString() {
    return 'TicketModel{'
        'corporation: $corporation, '
        'service: $service, '
        'pnrNo: $pnrNo, '
        'from: $from, '
        'to: $to, '
        'tripCode: $tripCode, '
        'journeyDate: $journeyDate, '
        'time: $time, '
        'seatNumbers: $seatNumbers, '
        'ticketClass: $ticketClass, '
        'boardingAt: $boardingAt, '
        '}';
  }
}
