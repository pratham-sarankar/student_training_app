import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:provider/provider.dart';
import '../../widgets/course_avatar.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../../utils/payment_config.dart';
import '../../models/course.dart';

class TraningCourseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> course;

  const TraningCourseDetailsScreen({super.key, required this.course});

  @override
  State<TraningCourseDetailsScreen> createState() =>
      _TraningCourseDetailsScreenState();
}

class _TraningCourseDetailsScreenState
    extends State<TraningCourseDetailsScreen> {
  late Razorpay _razorpay;
  final UserService _userService = UserService();
  UserModel? _currentUser;
  bool _isLoadingUser = true;
  late Course courseObj;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadUser();
    courseObj = Course.fromMap(widget.course, widget.course['id'] ?? '');
  }

  Future<void> _loadUser() async {
    setState(() => _isLoadingUser = true);
    final user = await _userService.getCurrentUserData();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoadingUser = false;
      });
    }
  }

  String get _enrollmentId {
    if (courseObj.id.isEmpty) return courseObj.domain;
    // Combine ID and recommendedCourses to make it unique per sub-course/program
    return '${courseObj.id}_${courseObj.recommendedCourses}';
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;

    setState(() => _isLoadingUser = true);

    try {
      await _userService.enrollInCourse(_enrollmentId);
    } catch (e) {
      debugPrint('Error enrolling in course: $e');
    }

    if (!mounted) return;
    await _loadUser();

    if (!mounted) return;
    _showSuccessFeedback();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet: ${response.walletName}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showSuccessFeedback() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Successfully enrolled in ${courseObj.recommendedCourses}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      FButton(
                        onPress: () => Navigator.of(context).pop(),
                        style: FButtonStyle.outline,
                        child: Icon(
                          Icons.arrow_back,
                          size: 16,
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Course Details',
                        style: theme.typography.lg.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colors.foreground,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CourseAvatar(
                              title: courseObj.recommendedCourses,
                              size: 60,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    courseObj.recommendedCourses,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.typography.xl.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colors.foreground,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    courseObj.domain,
                                    style: theme.typography.sm.copyWith(
                                      color: theme.colors.mutedForeground,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      courseObj.type,
                                      style: theme.typography.sm.copyWith(
                                        color: theme.colors.primary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Description Section
                        Text(
                          'Course Modules / Topics',
                          style: theme.typography.lg.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colors.foreground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Comprehensive training on ${courseObj.recommendedCourses} in ${courseObj.domain}.',
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.mutedForeground,
                            height: 1.5,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Course Specific Details
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailCard(
                                Icons.access_time_filled,
                                'Duration',
                                courseObj.duration,
                                Colors.indigo,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDetailCard(
                                Icons.payments,
                                'Course Cost',
                                '₹${courseObj.cost}',
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Mode, Days, Timing
                        _buildSectionHeader(context, 'Schedule Information'),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          context,
                          Icons.devices,
                          'Mode',
                          courseObj.mode,
                        ),
                        _buildInfoRow(
                          context,
                          Icons.calendar_month,
                          'Days',
                          courseObj.days,
                        ),
                        _buildInfoRow(
                          context,
                          Icons.query_builder,
                          'Timing',
                          courseObj.timing,
                        ),

                        const SizedBox(height: 24),

                        // Free Demo Highlight
                        if (courseObj.hasFreeDemo)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.amber.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.stars, color: Colors.amber),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Free Demo Available!',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber,
                                        ),
                                      ),
                                      Text(
                                        'Only for job oriented courses.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Bar
            Positioned(
              bottom: 12,
              left: 16,
              right: 16,
              child: Builder(
                builder: (context) {
                  if (_isLoadingUser) {
                    return Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: theme.colors.primary.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    );
                  }

                  final isEnrolled =
                      _currentUser?.enrolledCourses.contains(_enrollmentId) ??
                      false;

                  return GestureDetector(
                    onTap:
                        isEnrolled ? null : () => _showPurchaseDialog(context),
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: isEnrolled ? Colors.grey : theme.colors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colors.primary.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isEnrolled ? Icons.check_circle : Icons.school,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isEnrolled
                                  ? 'ENROLLED'
                                  : 'ENROLL NOW ₹${courseObj.enrollmentFee}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.typography.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          Text(
            value,
            style: theme.typography.sm.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colors.foreground,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = context.theme;
    return Text(
      title,
      style: theme.typography.base.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colors.foreground,
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colors.mutedForeground),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          Text(
            value,
            style: theme.typography.sm.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context) {
    final theme = context.theme;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Enrollment Fee'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You are about to enroll in:'),
                const SizedBox(height: 4),
                Text(
                  courseObj.domain,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Fee: ₹${courseObj.enrollmentFee}',
                    style: theme.typography.xl.copyWith(
                      color: theme.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _processPurchase();
                },
                child: const Text('Pay & Enroll'),
              ),
            ],
          ),
    );
  }

  void _processPurchase() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in to enroll.')));
      return;
    }

    final userModel = await _userService.getUserById(user.uid);

    final options = {
      'key': PaymentConfig.razorpayKey,
      'amount': (courseObj.enrollmentFee * 100).toInt(),
      'name': 'Gradspark Training',
      'description': 'Enrollment for ${courseObj.recommendedCourses}',
      'prefill': {
        'contact': userModel?.phoneNumber ?? '',
        'email': userModel?.email ?? user.email ?? '',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
    }
  }
}
