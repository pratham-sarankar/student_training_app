import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:provider/provider.dart';
import '../../widgets/course_avatar.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _userService.getCurrentUserData();
    if (mounted) {
      setState(() => _currentUser = user);
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final courseId =
        widget.course['id'] ??
        widget.course['title']; // Fallback to title if id missing
    await _userService.enrollInCourse(courseId);
    await _loadUser();
    _showSuccessFeedback();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Failed: ${response.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('External Wallet: ${response.walletName}'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _showSuccessFeedback() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Successfully enrolled in ${widget.course['title']}',
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
    }

    // Navigate back after a delay
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
                // Compact header
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

                // Compact content
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
                              title: widget.course['title'],
                              size: 60,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.course['title'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.typography.xl.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colors.foreground,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Course Tags - inline
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colors.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          widget.course['category'],
                                          style: theme.typography.sm.copyWith(
                                            color: theme.colors.primary,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          widget.course['level'],
                                          style: theme.typography.sm.copyWith(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Course Description
                        Text(
                          'Description',
                          style: theme.typography.lg.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colors.foreground,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.course['description'],
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.mutedForeground,
                            height: 1.4,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Course Details - simple row
                        Row(
                          children: [
                            Expanded(
                              child: _buildSimpleDetail(
                                Icons.access_time,
                                'Duration',
                                widget.course['duration'],
                                const Color(0xFF6366F1),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSimpleDetail(
                                Icons.attach_money,
                                'Cost',
                                '₹${widget.course['cost']}',
                                const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Tentative Start Date & Free Demo
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colors.primary.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: theme.colors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tentative Start Date',
                                        style: theme.typography.xs.copyWith(
                                          color: theme.colors.mutedForeground,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.course['tentativeStartDate'] ??
                                            'To be announced',
                                        style: theme.typography.sm.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme.colors.foreground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.play_circle_outline,
                                    size: 16,
                                    color: theme.colors.mutedForeground,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'This course includes a Free Demo',
                                    style: theme.typography.sm.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: theme.colors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 60), // Minimal space for FAB
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Builder(
              builder: (context) {
                final isEnrolled =
                    _currentUser?.enrolledCourses.contains(
                      widget.course['id'] ?? widget.course['title'],
                    ) ??
                    false;

                return Positioned(
                  bottom: 12,
                  left: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap:
                        isEnrolled
                            ? null
                            : () => _showPurchaseDialog(context, widget.course),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color:
                            isEnrolled
                                ? Colors.green.withValues(alpha: 0.8)
                                : theme.colors.primary,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colors.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
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
                              size: 18,
                              color: theme.colors.primaryForeground,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEnrolled
                                  ? 'Enrolled'
                                  : 'Enroll Now ₹${widget.course['enrollmentFee']}',
                              style: theme.typography.sm.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colors.primaryForeground,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleDetail(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  style: theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colors.foreground,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, Map<String, dynamic> course) {
    final theme = context.theme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 350),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Simple header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.school, color: theme.colors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Enrollment Confirmation',
                        style: theme.typography.lg.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Simple content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Course: ${course['title']}',
                        style: theme.typography.sm.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Enrollment Fee:',
                              style: theme.typography.sm.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '₹${widget.course['enrollmentFee']}',
                              style: theme.typography.lg.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Simple actions
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FButton(
                        onPress: () => Navigator.of(context).pop(),
                        style: FButtonStyle.outline,
                        child: Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FButton(
                        onPress: () {
                          Navigator.of(context).pop();
                          _processPurchase(course);
                        },
                        style: FButtonStyle.primary,
                        child: Text('Confirm'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _processPurchase(Map<String, dynamic> course) async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in to enroll.')));
      return;
    }

    // Try to get more user details if available
    final userModel = await _userService.getUserById(user.uid);

    final options = {
      'key': 'rzp_test_YOUR_KEY_HERE', // Replace with your actual key
      'amount': (widget.course['enrollmentFee'] ?? 0) * 100, // Amount in paise
      'name': 'Gradspark Training',
      'description': 'Enrollment for ${course['title']}',
      'prefill': {
        'contact': userModel?.phoneNumber ?? '',
        'email': userModel?.email ?? user.email ?? '',
      },
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
    }
  }
}
