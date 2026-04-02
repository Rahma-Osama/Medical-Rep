import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/core/widgets/custom_button_widget.dart';
import '../../viewmodels/login_cubit.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoginCubit>();

    return Transform.translate(
      offset: const Offset(0, -24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(28, 36, 28, 40),
        child: Form(
          key: cubit.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSecureBadge(),
              const SizedBox(height: 28),
              _buildEmailField(cubit),
              const SizedBox(height: 20),
              _buildPasswordField(context, cubit),
              // const SizedBox(height: 8),
              const SizedBox(height: 24),
              _buildSignInButton(context, cubit),
              const SizedBox(height: 28),
              const Divider(thickness: 0.5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecureBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3, backgroundColor: AppColors.secondaryColor),
          const SizedBox(width: 6),
          Text(
            "Secure sign in",
            style: AppTextStyle.hint.copyWith(color: AppColors.secondaryColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(LoginCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("EMAIL ADDRESS", style: AppTextStyle.label),
        const SizedBox(height: 8),
        TextFormField(
          controller: cubit.emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (val) {
            if (val == null || val.isEmpty) return "Email is required";
            if (!val.contains('@')) return "Enter a valid email";
            return null;
          },
          decoration: InputDecoration(
            hintText: "your@email.com",
            hintStyle: AppTextStyle.hint,
            prefixIcon: Icon(Icons.email_outlined, color: AppColors.grayColor, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context, LoginCubit cubit) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (prev, curr) => curr is LoginInitial,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("PASSWORD", style: AppTextStyle.label),
            const SizedBox(height: 8),
            TextFormField(
              controller: cubit.passwordController,
              obscureText: cubit.obscurePassword,
              validator: (val) {
                if (val == null || val.isEmpty) return "Password is required";
                if (val.length < 6) return "Minimum 6 characters";
                return null;
              },
              decoration: InputDecoration(
                hintText: "••••••••",
                hintStyle: AppTextStyle.hint,
                prefixIcon: Icon(Icons.lock_outline, color: AppColors.grayColor, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    cubit.obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.grayColor,
                    size: 20,
                  ),
                  onPressed: cubit.togglePasswordVisibility,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildSignInButton(BuildContext context, LoginCubit cubit) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          // TODO: Navigate to home
        }
        if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.errorColor),
          );
        }
      },
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: state is LoginLoading
              ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
              : CustomElevatedButton(
            text: "Sign In",
            onPressed: cubit.login,
          ),
        );
      },
    );
  }



}