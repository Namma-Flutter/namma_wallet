import 'package:dart_mappable/dart_mappable.dart';

part 'movie_ticket_model.mapper.dart';

@MappableClass()
class MovieTicketModel with MovieTicketModelMappable {
  const MovieTicketModel({
    this.bookingId,
    this.movieName,
    this.theatreName,
    this.screen,
    this.seats,
    this.showDateTime,
    this.language,
    this.format,        // 2D / 3D / IMAX
    this.price,
    this.provider,      // BookMyShow, PVR, INOX, District…
    this.qrData,
  });

  final String? bookingId;
  final String? movieName;
  final String? theatreName;
  final String? screen;
  final String? seats;          // "A12, A13" or "F7"
  final DateTime? showDateTime;
  final String? language;
  final String? format;
  final double? price;
  final String? provider;
  final String? qrData;
}