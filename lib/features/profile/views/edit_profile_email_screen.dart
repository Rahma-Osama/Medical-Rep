import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/error/failure_ui_extension.dart';
import 'package:medical_rep/core/services/services.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/core/widgets/custom_button_widget.dart';
import 'package:medical_rep/core/widgets/custom_snackbar_widget.dart';
import 'package:medical_rep/features/profile/domain/repositories/profile_repository.dart';
import 'package:medical_rep/features/profile/domain/usecases/update_profile_email_usecase.dart';
import 'package:medical_rep/features/profile/viewmodels/edit_profile_email_cubit.dart';
import 'package:medical_rep/features/profile/viewmodels/edit_profile_email_state.dart';
import 'package:medical_rep/features/profile/views/widgets/profile_header.dart';

class EditProfileEmailScreen extends StatefulWidget {
  const EditProfileEmailScreen({
    super.key,
    required this.currentEmail,
  });

  final String currentEmail;

  @override
  State<EditProfileEmailScreen> createState() => _EditProfileEmailScreenState();
}

class _EditProfileEmailScreenState extends State<EditProfileEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final initial = widget.currentEmail == '—' ? '' : widget.currentEmail;
    _emailController = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditProfileEmailCubit(
        UpdateProfileEmailUseCase(getIt<ProfileRepository>()),
      ),
      child: BlocConsumer<EditProfileEmailCubit, EditProfileEmailState>(
        listenWhen: (prev, curr) =>
            curr is EditProfileEmailSuccess ||
            (curr is EditProfileEmailReady && curr.failure != null),
        listener: (context, state) {
          if (state case EditProfileEmailSuccess(:final email, :final pendingConfirmation)) {
            AppSnackBar.showSuccess(
              context: context,
              title: pendingConfirmation ? 'Confirm your email' : 'Email updated',
              message: pendingConfirmation
                  ? 'We sent a confirmation link to $email. Your profile updates after you confirm.'
                  : 'Your email was saved to your account.',
            );
            Navigator.of(context).pop(true);
          }
          if (state case EditProfileEmailReady(:final failure?)) {
            failure.showFailureDialog(context);
          }
        },
        builder: (context, state) {
          final isLoading = state is EditProfileEmailSubmitting;

          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ProfileHeader(title: 'Edit email'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Update the email address linked to your account.',
                            style: AppTextStyle.hint.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          Text('EMAIL ADDRESS', style: AppTextStyle.label),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            enabled: !isLoading,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              final trimmed = value?.trim() ?? '';
                              if (trimmed.isEmpty) {
                                return 'Email is required';
                              }
                              if (!trimmed.contains('@') ||
                                  !trimmed.contains('.')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'your@email.com',
                              hintStyle: AppTextStyle.hint,
                              filled: true,
                              fillColor: AppColors.whiteColor,
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppColors.grayColor,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          CustomElevatedButton(
                            text: isLoading ? 'Saving…' : 'Save email',
                            onPressed: isLoading
                                ? null
                                : () => _onSave(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onSave(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<EditProfileEmailCubit>().submit(_emailController.text);
  }
}
