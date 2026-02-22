// This is a generated file - do not edit.
//
// Generated from proto/namma_wallet.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use ticketDescriptor instead')
const Ticket$json = {
  '1': 'Ticket',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'ticket_id', '3': 2, '4': 1, '5': 9, '10': 'ticketId'},
    {'1': 'primary_text', '3': 3, '4': 1, '5': 9, '10': 'primaryText'},
    {'1': 'secondary_text', '3': 4, '4': 1, '5': 9, '10': 'secondaryText'},
    {'1': 'type', '3': 5, '4': 1, '5': 9, '10': 'type'},
    {'1': 'start_time', '3': 6, '4': 1, '5': 9, '10': 'startTime'},
    {'1': 'end_time', '3': 7, '4': 1, '5': 9, '10': 'endTime'},
    {'1': 'location', '3': 8, '4': 1, '5': 9, '10': 'location'},
    {'1': 'tags', '3': 9, '4': 1, '5': 9, '10': 'tags'},
    {'1': 'extras', '3': 10, '4': 1, '5': 9, '10': 'extras'},
    {'1': 'created_at', '3': 11, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 12, '4': 1, '5': 9, '10': 'updatedAt'},
  ],
};

/// Descriptor for `Ticket`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ticketDescriptor = $convert.base64Decode(
    'CgZUaWNrZXQSDgoCaWQYASABKANSAmlkEhsKCXRpY2tldF9pZBgCIAEoCVIIdGlja2V0SWQSIQ'
    'oMcHJpbWFyeV90ZXh0GAMgASgJUgtwcmltYXJ5VGV4dBIlCg5zZWNvbmRhcnlfdGV4dBgEIAEo'
    'CVINc2Vjb25kYXJ5VGV4dBISCgR0eXBlGAUgASgJUgR0eXBlEh0KCnN0YXJ0X3RpbWUYBiABKA'
    'lSCXN0YXJ0VGltZRIZCghlbmRfdGltZRgHIAEoCVIHZW5kVGltZRIaCghsb2NhdGlvbhgIIAEo'
    'CVIIbG9jYXRpb24SEgoEdGFncxgJIAEoCVIEdGFncxIWCgZleHRyYXMYCiABKAlSBmV4dHJhcx'
    'IdCgpjcmVhdGVkX2F0GAsgASgJUgljcmVhdGVkQXQSHQoKdXBkYXRlZF9hdBgMIAEoCVIJdXBk'
    'YXRlZEF0');

@$core.Deprecated('Use ticketBackupDescriptor instead')
const TicketBackup$json = {
  '1': 'TicketBackup',
  '2': [
    {'1': 'schema_version', '3': 1, '4': 1, '5': 5, '10': 'schemaVersion'},
    {
      '1': 'tickets',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.nammawallet.Ticket',
      '10': 'tickets'
    },
  ],
};

/// Descriptor for `TicketBackup`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ticketBackupDescriptor = $convert.base64Decode(
    'CgxUaWNrZXRCYWNrdXASJQoOc2NoZW1hX3ZlcnNpb24YASABKAVSDXNjaGVtYVZlcnNpb24SLQ'
    'oHdGlja2V0cxgCIAMoCzITLm5hbW1hd2FsbGV0LlRpY2tldFIHdGlja2V0cw==');
