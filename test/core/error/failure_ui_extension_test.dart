import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_rep/core/error/app_failure.dart';
import 'package:medical_rep/core/error/failure_ui_extension.dart';
import 'package:medical_rep/core/error/result.dart';

void main() {
  Future<void> pumpHarness(
    WidgetTester tester, {
    required AppFailure failure,
    VoidCallback? onRetry,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => failure.showFailureDialog(
                    context,
                    onRetry: onRetry,
                    onRequiresReAuth: (_) async {},
                  ),
                  child: const Text('Show'),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows title and message for GeneralFailure', (tester) async {
    const failure = GeneralFailure(message: 'Something went wrong');
    await pumpHarness(tester, failure: failure);

    expect(find.text('Error'), findsOneWidget);
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('shows Retry for retryable failures', (tester) async {
    const failure = NoInternetFailure();
    await pumpHarness(tester, failure: failure);

    expect(find.text('No internet'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('shows Log in for session expiry', (tester) async {
    const failure = UnauthorizedFailure();
    await pumpHarness(tester, failure: failure);

    expect(find.text('Session expired'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('OK'), findsNothing);
  });

  testWidgets('invokes onRetry when Retry is tapped', (tester) async {
    var retried = false;
    const failure = ServerFailure();
    await pumpHarness(
      tester,
      failure: failure,
      onRetry: () => retried = true,
    );

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(retried, isTrue);
  });

  testWidgets('covers every concrete AppFailure subtype', (tester) async {
    const failures = <AppFailure>[
      NoInternetFailure(),
      TimeoutFailure(),
      UnauthorizedFailure(),
      ForbiddenFailure(),
      ServerFailure(),
      PayloadTooLargeFailure(),
      LocalDbFailure(title: 'Local', message: 'db issue'),
      FakeGpsDetectedFailure(),
      GeofencingFailure(),
      DuplicateVisitFailure(),
      MissingRequiredDataFailure(missing: 'notes'),
      PermissionFailure(title: 'Permission', message: 'denied'),
      GeneralFailure(message: 'generic'),
    ];

    for (final failure in failures) {
      await tester.pumpWidget(const SizedBox.shrink());
      await pumpHarness(tester, failure: failure);
      expect(find.text(failure.title), findsOneWidget);
      expect(find.text(failure.message), findsOneWidget);

      if (failure.requiresReAuth) {
        await tester.tap(find.text('Log in'));
      } else if (failure.isRetryable) {
        await tester.tap(find.text('Cancel'));
      } else {
        await tester.tap(find.text('OK'));
      }
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Result.whenWithFailureDialog shows dialog on Failure', (tester) async {
    const Result<void> result = Failure(NoInternetFailure());
    var successCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await result.whenWithFailureDialog(
                    context: context,
                    onSuccess: (_) async {
                      successCalled = true;
                    },
                  );
                },
                child: const Text('Run'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Run'));
    await tester.pumpAndSettle();

    expect(successCalled, isFalse);
    expect(find.text('No internet'), findsOneWidget);
  });
}
