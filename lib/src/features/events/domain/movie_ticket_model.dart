import 'package:dart_mappable/dart_mappable.dart';

part 'movie_ticket_model.mapper.dart';

@MappableClass()
class MovieTicketModel with MovieTicketModelMappable {
  const MovieTicketModel({
    this.bookingId,
    this.movieName,
    this.certificate,
    this.theatreName,
    this.screen,
    this.seats,
    this.showDateTime,
    this.language,
    this.format,
    this.price,
    this.provider,
    this.qrData,
  });

  final String? bookingId;
  final String? movieName;
  final String? certificate;
  final String? theatreName;
  final String? screen;
  final String? seats;
  final DateTime? showDateTime;
  final String? language;
  final String? format;
  final double? price;
  final String? provider;
  final String? qrData;
}
