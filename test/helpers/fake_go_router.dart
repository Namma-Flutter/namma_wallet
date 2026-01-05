import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

class FakeGoRouter extends Mock implements GoRouter {
  @override
  dynamic noSuchMethod(
    Invocation invocation, {
    Object? returnValue,
    Object? returnValueForMissingStub,
  }) {
    if (invocation.memberName == #canPop) {
      return true;
    }
    if (invocation.memberName == #pop) {
      return null;
    }
    return super.noSuchMethod(
      invocation,
      returnValue: returnValue,
      returnValueForMissingStub: returnValueForMissingStub,
    );
  }
}

/// This implementation is based on Guillaume Bernos's article
/// https://guillaume.bernos.dev/testing-go-router-2/
/// Modified to handle dialog contexts properly
class MockGoRouterProvider extends StatelessWidget {
  const MockGoRouterProvider({
    required this.goRouter,
    required this.child,
    super.key,
  });

  /// The mock router used to mock navigation calls.
  final GoRouter goRouter;

  /// The child [Widget] to render.
  final Widget child;

  @override
  Widget build(BuildContext context) => InheritedGoRouter(
    goRouter: goRouter,
    child: Builder(
      builder: (context) => child,
    ),
  );
}
