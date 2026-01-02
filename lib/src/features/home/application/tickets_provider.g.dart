// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tickets_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for all tickets (async)

@ProviderFor(allTickets)
const allTicketsProvider = AllTicketsProvider._();

/// Provider for all tickets (async)

final class AllTicketsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Ticket>>,
          List<Ticket>,
          FutureOr<List<Ticket>>
        >
    with $FutureModifier<List<Ticket>>, $FutureProvider<List<Ticket>> {
  /// Provider for all tickets (async)
  const AllTicketsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allTicketsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allTicketsHash();

  @$internal
  @override
  $FutureProviderElement<List<Ticket>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Ticket>> create(Ref ref) {
    return allTickets(ref);
  }
}

String _$allTicketsHash() => r'8e2f2196941eb5ff8427ebb95b07c241ee62dc8b';
