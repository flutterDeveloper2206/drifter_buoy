import 'package:drifter_buoy/core/utils/widgets/app_elevated_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_flushbar.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile/general_user_profile_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile_update/general_user_update_profile_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile_update/general_user_update_profile_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile_update/general_user_update_profile_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/profile/profile_card.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/profile/profile_labeled_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserProfileEditForm extends StatelessWidget {
  final String userId;
  final TextEditingController firstNameController;
  final TextEditingController middleNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final ValueNotifier<bool> isEditingNotifier;

  const GeneralUserProfileEditForm({
    super.key,
    required this.userId,
    required this.firstNameController,
    required this.middleNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.isEditingNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<GeneralUserUpdateProfileBloc, GeneralUserUpdateProfileState>(
      builder: (context, updateState) {
        final isUpdating = updateState is GeneralUserUpdateProfileLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GeneralUserProfileCard(
              data: GeneralUserProfileData(
                userId: userId,
                firstName: firstNameController.text.trim(),
                middleName: middleNameController.text.trim(),
                lastName: lastNameController.text.trim(),
                fullName:
                    '${firstNameController.text.trim()} ${middleNameController.text.trim()} ${lastNameController.text.trim()}'
                        .replaceAll(RegExp(r'\s+'), ' ')
                        .trim(),
                email: emailController.text.trim(),
                role: '',
                phone: phoneController.text.trim(),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Profile',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF23282D),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GeneralUserProfileLabeledTextField(
                    label: 'First Name',
                    controller: firstNameController,
                    enabled: !isUpdating,
                  ),
                  const SizedBox(height: 12),
                  GeneralUserProfileLabeledTextField(
                    label: 'Middle Name',
                    controller: middleNameController,
                    enabled: !isUpdating,
                  ),
                  const SizedBox(height: 12),
                  GeneralUserProfileLabeledTextField(
                    label: 'Last Name',
                    controller: lastNameController,
                    enabled: !isUpdating,
                  ),
                  const SizedBox(height: 12),
                  GeneralUserProfileLabeledTextField(
                    label: 'Mobile Number',
                    controller: phoneController,
                    enabled: !isUpdating,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  GeneralUserProfileLabeledTextField(
                    label: 'Email Address',
                    controller: emailController,
                    enabled: !isUpdating,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: AppElevatedButton(
                          loading: false,
                          onPressed: isUpdating
                              ? null
                              : () => isEditingNotifier.value = false,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF23282D),
                            disabledForegroundColor:
                                const Color(0xFF23282D).withValues(alpha: 0.65),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppElevatedButton(
                          loading: isUpdating,
                          onPressed: isUpdating
                              ? null
                              : () {
                                  final firstName = firstNameController.text.trim();
                                  final middleName = middleNameController.text.trim();
                                  final lastName = lastNameController.text.trim();
                                  final phone = phoneController.text.trim();
                                  final email = emailController.text.trim();

                                  if (firstName.isEmpty) {
                                    AppFlushbar.error(
                                      'First name is required',
                                      context: context,
                                    );
                                    return;
                                  }
                                  if (lastName.isEmpty) {
                                    AppFlushbar.error(
                                      'Last name is required',
                                      context: context,
                                    );
                                    return;
                                  }
                                  if (phone.isEmpty) {
                                    AppFlushbar.error(
                                      'Phone is required',
                                      context: context,
                                    );
                                    return;
                                  }
                                  if (email.isEmpty || !email.contains('@')) {
                                    AppFlushbar.error(
                                      'Enter a valid email',
                                      context: context,
                                    );
                                    return;
                                  }

                                  context.read<GeneralUserUpdateProfileBloc>().add(
                                        UpdateGeneralUserProfileRequested(
                                          userId: userId,
                                          firstName: firstName,
                                          middleName: middleName,
                                          lastName: lastName,
                                          mobileNumber: phone,
                                          emailAddress: email,
                                        ),
                                      );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF256BBB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

