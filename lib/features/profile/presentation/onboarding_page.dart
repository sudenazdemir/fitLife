import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/profile/domain/models/user_profile.dart';
import 'package:fitlife/features/profile/domain/providers/user_profile_providers.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key, this.initialProfile});

  final UserProfile? initialProfile;

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _goalController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialProfile?.name ?? '');
    _goalController =
        TextEditingController(text: widget.initialProfile?.goal ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    setState(() {
      _isSaving = true;
    });

    final name = _nameController.text.trim();
    final goal = _goalController.text.trim().isEmpty
        ? null
        : _goalController.text.trim();

    final profile = UserProfile(
      name: name,
      avatar: null, // ileride avatar seçimi eklenebilir
      goal: goal,
    );

    final repo = ref.read(userProfileRepositoryProvider);

    try {
      await repo.saveProfile(profile);

      messenger.showSnackBar(
        SnackBar(content: Text('Profile saved. Welcome, $name!')),
      );

      router.pop(); // ProfilePage'e geri dön
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final isEdit = widget.initialProfile != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Profile' : 'Set Up Profile'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Update your profile' : 'Let’s personalize FitLife',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You can change this later from the Profile page.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g. Sude',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _goalController,
                  decoration: const InputDecoration(
                    labelText: 'Fitness goal (optional)',
                    hintText: 'e.g. Build strength, lose fat...',
                  ),
                ),

                const Spacer(),

                SafeArea(
                  top: false,
                  minimum: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSaving ? null : _onSavePressed,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(isEdit ? 'Save Changes' : 'Save Profile'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
