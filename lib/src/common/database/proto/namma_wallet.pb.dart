// This is a generated file - do not edit.
//
// Generated from proto/namma_wallet.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Ticket extends $pb.GeneratedMessage {
  factory Ticket({
    $fixnum.Int64? id,
    $core.String? ticketId,
    $core.String? primaryText,
    $core.String? secondaryText,
    $core.String? type,
    $core.String? startTime,
    $core.String? endTime,
    $core.String? location,
    $core.String? tags,
    $core.String? extras,
    $core.String? createdAt,
    $core.String? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (ticketId != null) result.ticketId = ticketId;
    if (primaryText != null) result.primaryText = primaryText;
    if (secondaryText != null) result.secondaryText = secondaryText;
    if (type != null) result.type = type;
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    if (location != null) result.location = location;
    if (tags != null) result.tags = tags;
    if (extras != null) result.extras = extras;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  Ticket._();

  factory Ticket.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Ticket.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Ticket',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nammawallet'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'ticketId')
    ..aOS(3, _omitFieldNames ? '' : 'primaryText')
    ..aOS(4, _omitFieldNames ? '' : 'secondaryText')
    ..aOS(5, _omitFieldNames ? '' : 'type')
    ..aOS(6, _omitFieldNames ? '' : 'startTime')
    ..aOS(7, _omitFieldNames ? '' : 'endTime')
    ..aOS(8, _omitFieldNames ? '' : 'location')
    ..aOS(9, _omitFieldNames ? '' : 'tags')
    ..aOS(10, _omitFieldNames ? '' : 'extras')
    ..aOS(11, _omitFieldNames ? '' : 'createdAt')
    ..aOS(12, _omitFieldNames ? '' : 'updatedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ticket clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ticket copyWith(void Function(Ticket) updates) =>
      super.copyWith((message) => updates(message as Ticket)) as Ticket;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Ticket create() => Ticket._();
  @$core.override
  Ticket createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Ticket getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Ticket>(create);
  static Ticket? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get ticketId => $_getSZ(1);
  @$pb.TagNumber(2)
  set ticketId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTicketId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTicketId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get primaryText => $_getSZ(2);
  @$pb.TagNumber(3)
  set primaryText($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPrimaryText() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrimaryText() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get secondaryText => $_getSZ(3);
  @$pb.TagNumber(4)
  set secondaryText($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSecondaryText() => $_has(3);
  @$pb.TagNumber(4)
  void clearSecondaryText() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get type => $_getSZ(4);
  @$pb.TagNumber(5)
  set type($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasType() => $_has(4);
  @$pb.TagNumber(5)
  void clearType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get startTime => $_getSZ(5);
  @$pb.TagNumber(6)
  set startTime($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStartTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearStartTime() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get endTime => $_getSZ(6);
  @$pb.TagNumber(7)
  set endTime($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasEndTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearEndTime() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get location => $_getSZ(7);
  @$pb.TagNumber(8)
  set location($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLocation() => $_has(7);
  @$pb.TagNumber(8)
  void clearLocation() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get tags => $_getSZ(8);
  @$pb.TagNumber(9)
  set tags($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTags() => $_has(8);
  @$pb.TagNumber(9)
  void clearTags() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get extras => $_getSZ(9);
  @$pb.TagNumber(10)
  set extras($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasExtras() => $_has(9);
  @$pb.TagNumber(10)
  void clearExtras() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get createdAt => $_getSZ(10);
  @$pb.TagNumber(11)
  set createdAt($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasCreatedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearCreatedAt() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get updatedAt => $_getSZ(11);
  @$pb.TagNumber(12)
  set updatedAt($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasUpdatedAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearUpdatedAt() => $_clearField(12);
}

class TicketBackup extends $pb.GeneratedMessage {
  factory TicketBackup({
    $core.int? schemaVersion,
    $core.Iterable<Ticket>? tickets,
  }) {
    final result = create();
    if (schemaVersion != null) result.schemaVersion = schemaVersion;
    if (tickets != null) result.tickets.addAll(tickets);
    return result;
  }

  TicketBackup._();

  factory TicketBackup.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TicketBackup.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TicketBackup',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nammawallet'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'schemaVersion')
    ..pPM<Ticket>(2, _omitFieldNames ? '' : 'tickets',
        subBuilder: Ticket.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TicketBackup clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TicketBackup copyWith(void Function(TicketBackup) updates) =>
      super.copyWith((message) => updates(message as TicketBackup))
          as TicketBackup;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TicketBackup create() => TicketBackup._();
  @$core.override
  TicketBackup createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TicketBackup getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TicketBackup>(create);
  static TicketBackup? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get schemaVersion => $_getIZ(0);
  @$pb.TagNumber(1)
  set schemaVersion($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSchemaVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearSchemaVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<Ticket> get tickets => $_getList(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
