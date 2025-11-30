import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learn_work/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learn_work/widgets/shimmer_loading.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  String _selectedGender = 'Prefer not to say';
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _isDataLoading = true;

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() async {
    setState(() {
      _isDataLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Try to load user data from Firestore first
        final userService = UserService();
        final userModel = await userService.getCurrentUserDataWithFallback();

        if (userModel != null) {
          // Load data from Firestore
          setState(() {
            _emailController.text = userModel.email;
            _firstNameController.text = userModel.firstName;
            _lastNameController.text = userModel.lastName;
            _phoneController.text = userModel.phoneNumber ?? '';
            _bioController.text = userModel.bio ?? '';
            _selectedGender = userModel.gender ?? 'Prefer not to say';
            _selectedDate = userModel.dateOfBirth;
          });
        } else {
          // Fallback to Firebase Auth and SharedPreferences
          final prefs = await SharedPreferences.getInstance();

          setState(() {
            _emailController.text = user.email ?? '';

            // Parse display name if it exists
            if (user.displayName != null && user.displayName!.isNotEmpty) {
              final nameParts = user.displayName!.split(' ');
              if (nameParts.length >= 2) {
                _firstNameController.text = nameParts[0];
                _lastNameController.text = nameParts.sublist(1).join(' ');
              } else if (nameParts.length == 1) {
                _firstNameController.text = nameParts[0];
                _lastNameController.text = '';
              }
            }

            // Load other profile data from SharedPreferences
            _phoneController.text = prefs.getString('phoneNumber') ?? '';
            _bioController.text = prefs.getString('bio') ?? '';
            _selectedGender = prefs.getString('gender') ?? 'Prefer not to say';
            _selectedDate =
                prefs.getString('dateOfBirth') != null
                    ? DateTime.parse(prefs.getString('dateOfBirth')!)
                    : null;
          });
        }
      }
    } catch (e) {
      print('Error loading profile data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDataLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: theme.colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: theme.colorScheme.onSurface,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Edit Profile',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
              onPressed: _isDataLoading ? null : _loadProfileData,
            ),
          ],
        ),
        body: SafeArea(
          child:
              _isDataLoading
                  ? ShimmerLoading.profileShimmer(context)
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Picture Section
                          Center(
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.1),
                                        border: Border.all(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.2),
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        size: 50,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: theme.colorScheme.surface,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.camera_alt,
                                          size: 16,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: _changeProfilePicture,
                                  child: Text(
                                    'Change Photo',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Personal Information Section
                          _buildSectionTitle('Personal Information'),
                          const SizedBox(height: 16),

                          // First Name and Last Name Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _firstNameController,
                                  label: 'First Name',
                                  hint: 'Enter first name',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'First name is required';
                                    }
                                    if (value.trim().length < 2) {
                                      return 'First name must be at least 2 characters';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _lastNameController,
                                  label: 'Last Name',
                                  hint: 'Enter last name',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Last name is required';
                                    }
                                    if (value.trim().length < 2) {
                                      return 'Last name must be at least 2 characters';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Email Field
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hint: 'Enter email address',
                            keyboardType: TextInputType.emailAddress,
                            enabled:
                                false, // Email cannot be changed from profile
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Phone Field
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            hint: 'Enter phone number',
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Phone number is required';
                              }
                              if (value.trim().length < 10) {
                                return 'Phone number must be at least 10 digits';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Gender Selection
                          _buildDropdownField(
                            label: 'Gender',
                            value: _selectedGender,
                            items: _genderOptions,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Date of Birth
                          _buildDateField(
                            label: 'Date of Birth',
                            selectedDate: _selectedDate,
                            onDateSelected: (date) {
                              setState(() {
                                _selectedDate = date;
                              });
                            },
                          ),
                          if (_selectedDate == null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Date of birth is required',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),

                          // Bio
                          _buildTextField(
                            controller: _bioController,
                            label: 'Bio',
                            hint: 'Tell us about yourself',
                            maxLines: 4,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Bio is required';
                              }
                              if (value.length < 10) {
                                return 'Bio must be at least 10 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _saveProfile,
                              child:
                                  _isLoading
                                      ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                theme.colorScheme.onPrimary,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        'Save Changes',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  theme.colorScheme.onPrimary,
                                            ),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Cancel Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () => Navigator.of(context).pop(),
                              child: Text(
                                'Cancel',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items:
              items
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime?) onDateSelected,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context, onDateSelected),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? DateFormat('dd/MM/yyyy').format(selectedDate)
                        : 'Select Date',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      onDateSelected(picked);
    }
  }

  void _changeProfilePicture() {
    // TODO: Implement image picker functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image picker functionality coming soon'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // Additional validation for date
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select your date of birth'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Update profile in Firestore using UserService
          final userService = UserService();
          await userService.updateUserProfile(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            bio: _bioController.text.trim(),
            gender: _selectedGender,
            dateOfBirth: _selectedDate,
          );

          // Update display name in Firebase Auth
          final fullName =
              '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
                  .trim();
          await user.updateDisplayName(fullName);

          // Save to SharedPreferences as backup
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('phoneNumber', _phoneController.text.trim());
          await prefs.setString('bio', _bioController.text.trim());
          await prefs.setString('gender', _selectedGender);
          if (_selectedDate != null) {
            await prefs.setString(
              'dateOfBirth',
              DateFormat('yyyy-MM-dd').format(_selectedDate!),
            );
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate back to profile screen
            Navigator.of(context).pop();
          }
        } else {
          throw Exception('User not found');
        }
      } catch (e) {
        print('Error updating profile: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
