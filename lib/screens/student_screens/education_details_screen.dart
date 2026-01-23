import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:learn_work/services/education_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:learn_work/widgets/shimmer_loading.dart';
import 'package:file_picker/file_picker.dart';

class EducationDetailsScreen extends StatefulWidget {
  const EducationDetailsScreen({super.key});

  @override
  State<EducationDetailsScreen> createState() => _EducationDetailsScreenState();
}

class _EducationDetailsScreenState extends State<EducationDetailsScreen> {
  final _educationService = EducationService();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isSaving = false;

  // Form controllers
  bool _isCurrentlyPursuing = false;
  String? _selectedHighestEducation;
  String? _selectedDegree;
  String? _selectedSpecialization;
  String? _collegeName;
  DateTime? _completionDate;
  String? _selectedMedium;
  final List<String> _selectedCareerGoals = [];
  String? _resumeFileName;

  // Dropdown options
  static const List<String> _highestEducationOptions = [
    'Graduate',
    'Post-Graduate',
  ];

  static const List<String> _degreeOptions = [
    'M.Tech/ ME',
    'B.Tech/ BE',
    'MBA',
    'MCA',
    'BBA',
    'BCA',
    'B.A',
    'B.Com',
    'B.Sc',
    'BBM',
    'Others',
  ];

  static const List<String> _specializationOptions = [
    'Marketing',
    'Finance',
    'Human Resource',
    'Business Management',
    'Business Administration',
    'Accounting',
    'Computer Science',
    'Others',
  ];

  static const List<String> _collegeOptions = [
    'B.R.A. Bihar University, Muzaffarpur',
    'B.N. Mandal University, Madhepura',
    'Jai Prakash University, Chapra',
    'Purnea University, Purnea',
    'Munger University, Munger',
    'Patliputra University, Patna',
    'Aryabhatta Knowledge University, Patna',
    'Veer Kunwar Singh University, Ara',
    'T.M. Bhagalpur University, Bhagalpur',
    'Patna University, Patna',
    'Magadh University, Bodh Gaya',
    'L.N. Mithila University, Darbhanga',
    'B.N. College, Patna',
    'Magadh Mahila College, Patna',
    'Patna College, Patna',
    'Patna Science College, Patna',
    'Patna Women\'s College, Patna',
    'J D Women\'s College, Patna',
    'Gaya College, Gaya',
    'A N College, Patna',
    'T P S College, Patna',
    'L.S. College, Muzaffarpur',
    'M.D.D.M College, Muzaffarpur',
    'M.P.S. Science College, Muzaffarpur',
    'L.N. Mishra College of Business Management, Muzaffarpur',
    'L N Mishra Institute of Economic Development and Social Change, Patna',
    'Indian Institute of Business Management, Patna',
    'CIMAGE, Patna',
    'IMPACT College, Patna',
    'Others',
  ];

  static const List<String> _mediumOptions = ['English', 'Hindi'];

  static const List<String> _careerGoalOptions = [
    'Job/ Career',
    'Internship',
    'Higher Education',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentEducation();
  }

  Future<void> _loadCurrentEducation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final education = await _educationService.getCurrentUserEducation();
      if (education != null) {
        setState(() {
          _isCurrentlyPursuing = education.isCurrentlyPursuing;
          _selectedHighestEducation = education.highestEducation;
          _selectedDegree = education.degree;
          _selectedSpecialization = education.specialization;
          _collegeName = education.collegeName;
          _completionDate =
              education.completionYear != null
                  ? DateTime(education.completionYear!, 1, 1)
                  : null;
          _selectedMedium = education.medium;
          _selectedCareerGoals.clear();
          _selectedCareerGoals.addAll(education.careerGoals);
          _resumeFileName = education.resumeFileName;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load education details: $e'),
            backgroundColor: context.theme.colors.destructive,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickResume() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        // Since we are not uploading to Firebase, we just store the file name
        // In a real app without cloud storage, you might copy the file to app directory
        // but for this requirement, we'll just track the name.
        setState(() {
          _resumeFileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick resume: $e'),
            backgroundColor: context.theme.colors.destructive,
          ),
        );
      }
    }
  }

  Future<void> _saveEducation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _educationService.updateEducation(
        isCurrentlyPursuing: _isCurrentlyPursuing,
        highestEducation: _selectedHighestEducation,
        degree: _selectedDegree,
        specialization: _selectedSpecialization,
        collegeName: _collegeName,
        completionYear: _completionDate?.year,
        medium: _selectedMedium,
        careerGoals: _selectedCareerGoals,
        resumeFileName: _resumeFileName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Education details saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save education details: $e'),
            backgroundColor: context.theme.colors.destructive,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: theme.colors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colors.foreground),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Education Details',
            style: theme.typography.lg.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colors.foreground,
            ),
          ),
          centerTitle: true,
        ),
        body:
            _isLoading
                ? ShimmerLoading.educationShimmer(context)
                : SafeArea(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colors.primary.withValues(
                                alpha: 0.05,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.school,
                                    size: 20,
                                    color: theme.colors.primaryForeground,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Education Information',
                                        style: theme.typography.lg.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme.colors.foreground,
                                        ),
                                      ),
                                      Text(
                                        'Tell us about your educational background',
                                        style: theme.typography.sm.copyWith(
                                          color: theme.colors.mutedForeground,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Currently Pursuing Education
                          _buildSectionTitle('Currently Pursuing Education'),
                          const SizedBox(height: 8),
                          _buildYesNoSelector(
                            value: _isCurrentlyPursuing,
                            onChanged: (value) {
                              setState(() {
                                _isCurrentlyPursuing = value;
                              });
                            },
                          ),
                          const SizedBox(height: 24),

                          // Highest Education
                          _buildSectionTitle('Highest Education'),
                          const SizedBox(height: 8),
                          _buildDropdownField(
                            value: _selectedHighestEducation,
                            items: _highestEducationOptions,
                            hint: 'Select your highest education',
                            onChanged: (value) {
                              setState(() {
                                _selectedHighestEducation = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your highest education';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Degree
                          _buildSectionTitle('Degree'),
                          const SizedBox(height: 8),
                          _buildDropdownField(
                            value: _selectedDegree,
                            items: _degreeOptions,
                            hint: 'Select your degree',
                            onChanged: (value) {
                              setState(() {
                                _selectedDegree = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your degree';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Specialization
                          _buildSectionTitle('Specialization'),
                          const SizedBox(height: 8),
                          _buildDropdownField(
                            value: _selectedSpecialization,
                            items: _specializationOptions,
                            hint: 'Select your specialization',
                            onChanged: (value) {
                              setState(() {
                                _selectedSpecialization = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your specialization';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // College Name
                          _buildSectionTitle('College Name'),
                          const SizedBox(height: 8),
                          _buildDropdownField(
                            value: _collegeName,
                            items: _collegeOptions,
                            hint: 'Select your college',
                            onChanged: (value) {
                              setState(() {
                                _collegeName = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your college';
                              }
                              return null;
                            },
                          ),

                          // const SizedBox(height: 24),

                          // // Completion Date
                          // _buildSectionTitle('Completion Date'),
                          // const SizedBox(height: 8),
                          // _buildDateField(
                          //   value: _completionDate,
                          //   hint: 'Select completion date',
                          //   onChanged: (value) {
                          //     setState(() {
                          //       _completionDate = value;
                          //     });
                          //   },
                          //   validator: (value) {
                          //     if (value == null) {
                          //       return 'Please select completion date';
                          //     }
                          //     final currentDate = DateTime.now();
                          //     final minDate = DateTime(1950, 1, 1);
                          //     final maxDate = DateTime(
                          //       currentDate.year + 5,
                          //       12,
                          //       31,
                          //     );
                          //     if (value.isBefore(minDate) ||
                          //         value.isAfter(maxDate)) {
                          //       return 'Please select a valid date between 1950 and ${currentDate.year + 5}';
                          //     }
                          //     return null;
                          //   },
                          // ),
                          // const SizedBox(height: 24),

                          // // Medium
                          // _buildSectionTitle('Medium'),
                          // const SizedBox(height: 8),
                          // _buildDropdownField(
                          //   value: _selectedMedium,
                          //   items: _mediumOptions,
                          //   hint: 'Select your medium',
                          //   onChanged: (value) {
                          //     setState(() {
                          //       _selectedMedium = value;
                          //     });
                          //   },
                          //   validator: (value) {
                          //     if (value == null || value.isEmpty) {
                          //       return 'Please select your medium';
                          //     }
                          //     return null;
                          //   },
                          // ),
                          // const SizedBox(height: 24),

                          // // Career Goals
                          // _buildSectionTitle('I am looking for'),
                          // const SizedBox(height: 8),
                          // _buildMultiSelectField(
                          //   selectedItems: _selectedCareerGoals,
                          //   items: _careerGoalOptions,
                          //   onChanged: (selectedItems) {
                          //     setState(() {
                          //       _selectedCareerGoals.clear();
                          //       _selectedCareerGoals.addAll(selectedItems);
                          //     });
                          //   },
                          //   validator: (value) {
                          //     if (_selectedCareerGoals.isEmpty) {
                          //       return 'Please select at least one career goal';
                          //     }
                          //     return null;
                          //   },
                          // ),
                          const SizedBox(height: 24),
                          // Resume Upload
                          _buildSectionTitle('Resume'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: theme.colors.border),
                              borderRadius: BorderRadius.circular(12),
                              color: theme.colors.background,
                            ),
                            child: Column(
                              children: [
                                if (_resumeFileName != null)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: theme.colors.primary.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.description,
                                          color: theme.colors.primary,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _resumeFileName!,
                                            style: theme.typography.sm.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: theme.colors.foreground,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            color: theme.colors.destructive,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _resumeFileName = null;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                SizedBox(
                                  width: double.infinity,
                                  child: FButton(
                                    style: FButtonStyle.outline,
                                    onPress: _pickResume,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.upload_file,
                                          size: 18,
                                          color: theme.colors.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _resumeFileName != null
                                              ? 'Change Resume'
                                              : 'Upload Resume',
                                          style: theme.typography.sm.copyWith(
                                            color: theme.colors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (_resumeFileName == null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Supported formats: PDF, DOC, DOCX',
                                          style: theme.typography.xs.copyWith(
                                            color: theme.colors.mutedForeground,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: () async {
                                            final url = Uri.parse(
                                              'https://cvmaker.com/',
                                            );
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(
                                                url,
                                                mode:
                                                    LaunchMode
                                                        .externalApplication,
                                              );
                                            }
                                          },
                                          child: Text(
                                            'Don\'t have a resume? Create one free with CV Maker',
                                            style: theme.typography.xs.copyWith(
                                              color: theme.colors.primary,
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FButton(
                              style: FButtonStyle.primary,
                              onPress: _isSaving ? null : _saveEducation,
                              child:
                                  _isSaving
                                      ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                theme.colors.primaryForeground,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        'Save Education Details',
                                        style: theme.typography.sm.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme.colors.primaryForeground,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = context.theme;
    return Text(
      title,
      style: theme.typography.sm.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colors.foreground,
      ),
    );
  }

  Widget _buildYesNoSelector({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = context.theme;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: value ? theme.colors.primary : theme.colors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: value ? theme.colors.primary : theme.colors.border,
                  width: 1,
                ),
              ),
              child: Text(
                'Yes',
                textAlign: TextAlign.center,
                style: theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      value
                          ? theme.colors.primaryForeground
                          : theme.colors.foreground,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: !value ? theme.colors.primary : theme.colors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: !value ? theme.colors.primary : theme.colors.border,
                  width: 1,
                ),
              ),
              child: Text(
                'No',
                textAlign: TextAlign.center,
                style: theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      !value
                          ? theme.colors.primaryForeground
                          : theme.colors.foreground,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    final theme = context.theme;

    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      items:
          items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.sm.copyWith(
                  color: theme.colors.foreground,
                ),
              ),
            );
          }).toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: theme.typography.sm.copyWith(
          color: theme.colors.mutedForeground,
        ),
        filled: true,
        fillColor: theme.colors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colors.destructive),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      dropdownColor: theme.colors.background,
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: theme.colors.mutedForeground,
      ),
    );
  }

  Widget _buildMultiSelectField({
    required List<String> selectedItems,
    required List<String> items,
    required ValueChanged<List<String>> onChanged,
    String? Function(String?)? validator,
  }) {
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children:
                items.map((item) {
                  final isSelected = selectedItems.contains(item);
                  return GestureDetector(
                    onTap: () {
                      final newSelection = List<String>.from(selectedItems);
                      if (isSelected) {
                        newSelection.remove(item);
                      } else {
                        newSelection.add(item);
                      }
                      onChanged(newSelection);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? theme.colors.primary.withValues(alpha: 0.1)
                                : theme.colors.background,
                        border: Border(
                          bottom: BorderSide(
                            color: theme.colors.border,
                            width:
                                items.indexOf(item) == items.length - 1 ? 0 : 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color:
                                isSelected
                                    ? theme.colors.primary
                                    : theme.colors.mutedForeground,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item,
                              style: theme.typography.sm.copyWith(
                                color:
                                    isSelected
                                        ? theme.colors.primary
                                        : theme.colors.foreground,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
        if (validator != null && validator(null) != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16),
            child: Text(
              validator(null)!,
              style: theme.typography.sm.copyWith(
                color: theme.colors.destructive,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDateField({
    required DateTime? value,
    required String hint,
    required ValueChanged<DateTime?> onChanged,
    String? Function(DateTime?)? validator,
  }) {
    final theme = context.theme;

    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime(DateTime.now().year + 5, 12, 31),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: theme.colors.primary,
                  onPrimary: theme.colors.primaryForeground,
                  surface: theme.colors.background,
                  onSurface: theme.colors.foreground,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.border),
          borderRadius: BorderRadius.circular(8),
          color: theme.colors.background,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value != null
                    ? '${_getMonthName(value.month)} ${value.year}'
                    : hint,
                style: theme.typography.sm.copyWith(
                  color:
                      value != null
                          ? theme.colors.foreground
                          : theme.colors.mutedForeground,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: theme.colors.mutedForeground,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
