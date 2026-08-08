// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'movie_ticket_model.dart';

class MovieTicketModelMapper extends ClassMapperBase<MovieTicketModel> {
  MovieTicketModelMapper._();

  static MovieTicketModelMapper? _instance;
  static MovieTicketModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MovieTicketModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MovieTicketModel';

  static String? _$bookingId(MovieTicketModel v) => v.bookingId;
  static const Field<MovieTicketModel, String> _f$bookingId = Field(
    'bookingId',
    _$bookingId,
    opt: true,
  );
  static String? _$movieName(MovieTicketModel v) => v.movieName;
  static const Field<MovieTicketModel, String> _f$movieName = Field(
    'movieName',
    _$movieName,
    opt: true,
  );
  static String? _$certificate(MovieTicketModel v) => v.certificate;
  static const Field<MovieTicketModel, String> _f$certificate = Field(
    'certificate',
    _$certificate,
    opt: true,
  );
  static String? _$theatreName(MovieTicketModel v) => v.theatreName;
  static const Field<MovieTicketModel, String> _f$theatreName = Field(
    'theatreName',
    _$theatreName,
    opt: true,
  );
  static String? _$screen(MovieTicketModel v) => v.screen;
  static const Field<MovieTicketModel, String> _f$screen = Field(
    'screen',
    _$screen,
    opt: true,
  );
  static String? _$seats(MovieTicketModel v) => v.seats;
  static const Field<MovieTicketModel, String> _f$seats = Field(
    'seats',
    _$seats,
    opt: true,
  );
  static DateTime? _$showDateTime(MovieTicketModel v) => v.showDateTime;
  static const Field<MovieTicketModel, DateTime> _f$showDateTime = Field(
    'showDateTime',
    _$showDateTime,
    opt: true,
  );
  static String? _$language(MovieTicketModel v) => v.language;
  static const Field<MovieTicketModel, String> _f$language = Field(
    'language',
    _$language,
    opt: true,
  );
  static String? _$format(MovieTicketModel v) => v.format;
  static const Field<MovieTicketModel, String> _f$format = Field(
    'format',
    _$format,
    opt: true,
  );
  static double? _$price(MovieTicketModel v) => v.price;
  static const Field<MovieTicketModel, double> _f$price = Field(
    'price',
    _$price,
    opt: true,
  );
  static String? _$provider(MovieTicketModel v) => v.provider;
  static const Field<MovieTicketModel, String> _f$provider = Field(
    'provider',
    _$provider,
    opt: true,
  );
  static String? _$qrData(MovieTicketModel v) => v.qrData;
  static const Field<MovieTicketModel, String> _f$qrData = Field(
    'qrData',
    _$qrData,
    opt: true,
  );

  @override
  final MappableFields<MovieTicketModel> fields = const {
    #bookingId: _f$bookingId,
    #movieName: _f$movieName,
    #certificate: _f$certificate,
    #theatreName: _f$theatreName,
    #screen: _f$screen,
    #seats: _f$seats,
    #showDateTime: _f$showDateTime,
    #language: _f$language,
    #format: _f$format,
    #price: _f$price,
    #provider: _f$provider,
    #qrData: _f$qrData,
  };

  static MovieTicketModel _instantiate(DecodingData data) {
    return MovieTicketModel(
      bookingId: data.dec(_f$bookingId),
      movieName: data.dec(_f$movieName),
      certificate: data.dec(_f$certificate),
      theatreName: data.dec(_f$theatreName),
      screen: data.dec(_f$screen),
      seats: data.dec(_f$seats),
      showDateTime: data.dec(_f$showDateTime),
      language: data.dec(_f$language),
      format: data.dec(_f$format),
      price: data.dec(_f$price),
      provider: data.dec(_f$provider),
      qrData: data.dec(_f$qrData),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MovieTicketModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MovieTicketModel>(map);
  }

  static MovieTicketModel fromJson(String json) {
    return ensureInitialized().decodeJson<MovieTicketModel>(json);
  }
}

mixin MovieTicketModelMappable {
  String toJson() {
    return MovieTicketModelMapper.ensureInitialized()
        .encodeJson<MovieTicketModel>(this as MovieTicketModel);
  }

  Map<String, dynamic> toMap() {
    return MovieTicketModelMapper.ensureInitialized()
        .encodeMap<MovieTicketModel>(this as MovieTicketModel);
  }

  MovieTicketModelCopyWith<MovieTicketModel, MovieTicketModel, MovieTicketModel>
  get copyWith =>
      _MovieTicketModelCopyWithImpl<MovieTicketModel, MovieTicketModel>(
        this as MovieTicketModel,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MovieTicketModelMapper.ensureInitialized().stringifyValue(
      this as MovieTicketModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return MovieTicketModelMapper.ensureInitialized().equalsValue(
      this as MovieTicketModel,
      other,
    );
  }

  @override
  int get hashCode {
    return MovieTicketModelMapper.ensureInitialized().hashValue(
      this as MovieTicketModel,
    );
  }
}

extension MovieTicketModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MovieTicketModel, $Out> {
  MovieTicketModelCopyWith<$R, MovieTicketModel, $Out>
  get $asMovieTicketModel =>
      $base.as((v, t, t2) => _MovieTicketModelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MovieTicketModelCopyWith<$R, $In extends MovieTicketModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? bookingId,
    String? movieName,
    String? certificate,
    String? theatreName,
    String? screen,
    String? seats,
    DateTime? showDateTime,
    String? language,
    String? format,
    double? price,
    String? provider,
    String? qrData,
  });
  MovieTicketModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MovieTicketModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MovieTicketModel, $Out>
    implements MovieTicketModelCopyWith<$R, MovieTicketModel, $Out> {
  _MovieTicketModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MovieTicketModel> $mapper =
      MovieTicketModelMapper.ensureInitialized();
  @override
  $R call({
    Object? bookingId = $none,
    Object? movieName = $none,
    Object? certificate = $none,
    Object? theatreName = $none,
    Object? screen = $none,
    Object? seats = $none,
    Object? showDateTime = $none,
    Object? language = $none,
    Object? format = $none,
    Object? price = $none,
    Object? provider = $none,
    Object? qrData = $none,
  }) => $apply(
    FieldCopyWithData({
      if (bookingId != $none) #bookingId: bookingId,
      if (movieName != $none) #movieName: movieName,
      if (certificate != $none) #certificate: certificate,
      if (theatreName != $none) #theatreName: theatreName,
      if (screen != $none) #screen: screen,
      if (seats != $none) #seats: seats,
      if (showDateTime != $none) #showDateTime: showDateTime,
      if (language != $none) #language: language,
      if (format != $none) #format: format,
      if (price != $none) #price: price,
      if (provider != $none) #provider: provider,
      if (qrData != $none) #qrData: qrData,
    }),
  );
  @override
  MovieTicketModel $make(CopyWithData data) => MovieTicketModel(
    bookingId: data.get(#bookingId, or: $value.bookingId),
    movieName: data.get(#movieName, or: $value.movieName),
    certificate: data.get(#certificate, or: $value.certificate),
    theatreName: data.get(#theatreName, or: $value.theatreName),
    screen: data.get(#screen, or: $value.screen),
    seats: data.get(#seats, or: $value.seats),
    showDateTime: data.get(#showDateTime, or: $value.showDateTime),
    language: data.get(#language, or: $value.language),
    format: data.get(#format, or: $value.format),
    price: data.get(#price, or: $value.price),
    provider: data.get(#provider, or: $value.provider),
    qrData: data.get(#qrData, or: $value.qrData),
  );

  @override
  MovieTicketModelCopyWith<$R2, MovieTicketModel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MovieTicketModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

