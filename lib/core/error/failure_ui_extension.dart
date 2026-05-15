import 'package:flutter/material.dart';
import 'package:medical_rep/core/error/app_failure.dart';
import 'package:medical_rep/core/error/result.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/features/Auth/views/LoginView.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// User action after [AppFailure.showFailureDialog] closes.
enum FailureDialogResult {
  dismissed,
  retried,
  reAuthed,
}

typedef FailureReAuthHandler = Future<void> Function(BuildContext context);

/// Shows a dialog for any [AppFailure] using [title], [message], [isRetryable],
/// and [requiresReAuth] — no per-subtype UI switches required.
extension AppFailureUi on AppFailure {
  Future<FailureDialogResult> showFailureDialog(
    BuildContext context, {
    VoidCallback? onRetry,
    FailureReAuthHandler? onRequiresReAuth,
  }) async {
    if (!context.mounted) return FailureDialogResult.dismissed;

    final result = await showDialog<FailureDialogResult>(
      context: context,
      barrierDismissible: !requiresReAuth,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: _failureDialogActions(
            dialogContext,
            onRetry: onRetry,
          ),
        );
      },
    );

    final resolved = result ?? FailureDialogResult.dismissed;

    if (!context.mounted) return resolved;

    switch (resolved) {
      case FailureDialogResult.reAuthed:
        await (onRequiresReAuth ?? defaultFailureReAuthHandler)(context);
      case FailureDialogResult.retried:
        onRetry?.call();
      case FailureDialogResult.dismissed:
        break;
    }

    return resolved;
  }

  List<Widget> _failureDialogActions(
    BuildContext dialogContext, {
    VoidCallback? onRetry,
  }) {
    if (requiresReAuth) {
      return [
        FilledButton(
          onPressed: () => Navigator.pop(
            dialogContext,
            FailureDialogResult.reAuthed,
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
          ),
          child: const Text('Log in'),
        ),
      ];
    }

    if (isRetryable) {
      return [
        TextButton(
          onPressed: () => Navigator.pop(
            dialogContext,
            FailureDialogResult.dismissed,
          ),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            dialogContext,
            FailureDialogResult.retried,
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
          ),
          child: const Text('Retry'),
        ),
      ];
    }

    return [
      FilledButton(
        onPressed: () => Navigator.pop(
          dialogContext,
          FailureDialogResult.dismissed,
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
        ),
        child: const Text('OK'),
      ),
    ];
  }
}

/// Signs out and navigates to the login screen (default for [UnauthorizedFailure]).
Future<void> defaultFailureReAuthHandler(BuildContext context) async {
  await Supabase.instance.client.auth.signOut();
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    (_) => false,
  );
}

extension ResultFailureUi<T> on Result<T> {
  /// Runs [onSuccess] or shows a failure dialog for any [AppFailure] in [Failure].
  Future<R?> whenWithFailureDialog<R>({
    required BuildContext context,
    required Future<R> Function(T data) onSuccess,
    VoidCallback? onRetry,
    FailureReAuthHandler? onRequiresReAuth,
    R? valueOnFailure,
  }) async {
    return switch (this) {
      Success(:final data) => await onSuccess(data),
      Failure(:final failure) => () async {
          await failure.showFailureDialog(
            context,
            onRetry: onRetry,
            onRequiresReAuth: onRequiresReAuth,
          );
          return valueOnFailure;
        }(),
    };
  }
}
