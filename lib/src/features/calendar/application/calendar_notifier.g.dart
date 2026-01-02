// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Calendar notifier using Riverpod code generation.
/// Services are injected via GetIt.

@ProviderFor(Calendar)
const calendarProvider = CalendarProvider._();

/// Calendar notifier using Riverpod code generation.
/// Services are injected via GetIt.
final class CalendarProvider
    extends $NotifierProvider<Calendar, CalendarState> {
  /// Calendar notifier using Riverpod code generation.
  /// Services are injected via GetIt.
  const CalendarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarHash();

  @$internal
  @override
  Calendar create() => Calendar();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarState>(value),
    );
  }
}

String _$calendarHash() => r'e20c41f89e9ede0b7399b569cab6045c74c93c1b';

/// Calendar notifier using Riverpod code generation.
/// Services are injected via GetIt.

abstract class _$Calendar extends $Notifier<CalendarState> {
  CalendarState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CalendarState, CalendarState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CalendarState, CalendarState>,
              CalendarState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
