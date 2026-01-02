// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AI status notifier using Riverpod code generation.

@ProviderFor(AiStatus)
const aiStatusProvider = AiStatusProvider._();

/// AI status notifier using Riverpod code generation.
final class AiStatusProvider extends $NotifierProvider<AiStatus, AIStatus> {
  /// AI status notifier using Riverpod code generation.
  const AiStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiStatusHash();

  @$internal
  @override
  AiStatus create() => AiStatus();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AIStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AIStatus>(value),
    );
  }
}

String _$aiStatusHash() => r'12d6b1d53ddff27063329361ca267a6c607f0bca';

/// AI status notifier using Riverpod code generation.

abstract class _$AiStatus extends $Notifier<AIStatus> {
  AIStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AIStatus, AIStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AIStatus, AIStatus>,
              AIStatus,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
