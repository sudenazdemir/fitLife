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

  // Cinsiyet seçimi için değişken
  String? _selectedGender;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialProfile?.name ?? '');
    _goalController =
        TextEditingController(text: widget.initialProfile?.goal ?? '');
    
    // Eğer düzenleme modundaysak ve modelde gender varsa buraya ekleyebilirsin
    // _selectedGender = widget.initialProfile?.gender; 
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;

    // Cinsiyet seçimi kontrolü
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a gender identity.')),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    setState(() {
      _isSaving = true;
    });

    final name = _nameController.text.trim();
    final goal = _goalController.text.trim().isEmpty
        ? null
        : _goalController.text.trim();

    // NOT: UserProfile modeline 'gender' alanını eklemeyi unutma!
    final profile = UserProfile(
      name: name,
      avatar: null, 
      goal: goal,
      // gender: _selectedGender, // Modeline bu alanı eklediğinde burayı aç
    );

    final repo = ref.read(userProfileRepositoryProvider);

    try {
      await repo.saveProfile(profile);

      messenger.showSnackBar(
        SnackBar(content: Text('Profile saved. Welcome, $name!')),
      );

      router.pop(); 
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
    final colorScheme = theme.colorScheme;

    final isEdit = widget.initialProfile != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Profile' : 'Set Up Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView( // Klavye açılınca taşmayı önlemek için scroll
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Update your profile' : 'Let’s personalize FitLife',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'To give you the best experience, we need to know a little about you.',
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 32),

                // --- ⚧ GENDER SELECTION SECTION ---
                Text(
                  'Gender Identity',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGenderCard(
                      context,
                      label: 'Female',
                      icon: Icons.female,
                      value: 'Female',
                      color: Colors.pinkAccent,
                    ),
                    _buildGenderCard(
                      context,
                      label: 'Male',
                      icon: Icons.male,
                      value: 'Male',
                      color: Colors.blueAccent,
                    ),
                    _buildGenderCard(
                      context,
                      label: 'Non-Binary',
                      icon: Icons.transgender, // veya Icons.circle_outlined
                      value: 'Non-Binary',
                      color: Colors.purpleAccent,
                    ),
                  ],
                ),
                // -----------------------------------

                const SizedBox(height: 32),

                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g. Sude',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _goalController,
                  decoration: InputDecoration(
                    labelText: 'Fitness goal (optional)',
                    hintText: 'e.g. Build strength, lose fat...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.flag_outlined),
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _onSavePressed,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEdit ? 'Save Changes' : 'Start Journey'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 🎨 Custom Gender Card Widget (Referans Görsele Uygun) ---
  Widget _buildGenderCard(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String value,
    required Color color,
  }) {
    final isSelected = _selectedGender == value;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected 
                  ? color.withValues(alpha: 0.2) 
                  : colorScheme.surfaceContainerHighest,
              border: isSelected
                  ? Border.all(color: color, width: 3) // Seçilince kalın çerçeve
                  : Border.all(color: Colors.transparent, width: 3),
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2)]
                  : [],
            ),
            child: Icon(
              icon,
              size: 32,
              color: isSelected ? color : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}