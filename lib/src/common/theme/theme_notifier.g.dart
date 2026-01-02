// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Theme mode notifier using Riverpod code generation.
/// Named ThemeModeNotifier to avoid conflict with Flutter's Theme and AppTheme.

@ProviderFor(ThemeModeNotifier)
const themeModeProvider = ThemeModeNotifierProvider._();

/// Theme mode notifier using Riverpod code generation.
/// Named ThemeModeNotifier to avoid conflict with Flutter's Theme and AppTheme.
final class ThemeModeNotifierProvider
    extends $NotifierProvider<ThemeModeNotifier, ThemeState> {
  /// Theme mode notifier using Riverpod code generation.
  /// Named ThemeModeNotifier to avoid conflict with Flutter's Theme and AppTheme.
  const ThemeModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeNotifierHash();

  @$internal
  @override
  ThemeModeNotifier create() => ThemeModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeState>(value),
    );
  }
}

String _$themeModeNotifierHash() => r'c2e016d5a128b71585454e76ebd1e03959763792';

/// Theme mode notifier using Riverpod code generation.
/// Named ThemeModeNotifier to avoid conflict with Flutter's Theme and AppTheme.

abstract class _$ThemeModeNotifier extends $Notifier<ThemeState> {
  ThemeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ThemeState, ThemeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeState, ThemeState>,
              ThemeState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
