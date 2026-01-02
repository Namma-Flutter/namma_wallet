/// AI status provider with Riverpod code generation.
///
/// Tracks the status of on-device AI services.
library;

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_status_provider.g.dart';

/// Immutable state class for AI service status.
@immutable
class AIStatus {
  const AIStatus({
    this.isGemmaSupported = true,
    this.errorMessage,
  });

  final bool isGemmaSupported;
  final String? errorMessage;

  AIStatus copyWith({
    bool? isGemmaSupported,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AIStatus(
      isGemmaSupported: isGemmaSupported ?? this.isGemmaSupported,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// AI status notifier using Riverpod code generation.
@Riverpod(keepAlive: true)
class AiStatus extends _$AiStatus {
  @override
  AIStatus build() => const AIStatus();

  void setGemmaSupport({required bool supported, String? error}) {
    state = state.copyWith(
      isGemmaSupported: supported,
      errorMessage: error,
      clearError: error == null,
    );
  }
}
