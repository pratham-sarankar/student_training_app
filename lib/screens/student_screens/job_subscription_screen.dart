import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobSubscriptionScreen extends StatefulWidget {
  const JobSubscriptionScreen({super.key});

  @override
  State<JobSubscriptionScreen> createState() => _JobSubscriptionScreenState();
}

class _JobSubscriptionScreenState extends State<JobSubscriptionScreen> {
  bool _isSubscribed = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: const Color(0xFF1A1A1A),
              size: 20.sp,
            ),
          ),
          title: Text(
            'Job Subscription',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                      width: 1.w,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 32.sp,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Stay Updated with Job Opportunities',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Get notified about new job postings, career opportunities, and industry updates directly to your email.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
      
                // Subscription Status
                Text(
                  'Subscription Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 12.h),
      
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: _isSubscribed 
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: _isSubscribed 
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.15),
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isSubscribed ? Icons.check_circle : Icons.cancel_outlined,
                        color: _isSubscribed 
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isSubscribed ? 'Subscribed' : 'Not Subscribed',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _isSubscribed 
                                  ? 'You\'re receiving job updates and notifications'
                                  : 'Subscribe to start receiving job opportunities',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF666666),
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
      
                // Benefits Section
                Text(
                  'What You\'ll Get',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 12.h),
      
                _buildBenefitCard(
                  icon: Icons.email_outlined,
                  title: 'Direct Email Updates',
                  description: 'Job postings sent directly to your inbox',
                ),
                SizedBox(height: 8.h),
      
                _buildBenefitCard(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Admin Posts',
                  description: 'Automatic notifications when admins post new opportunities',
                ),
                SizedBox(height: 8.h),
      
                _buildBenefitCard(
                  icon: Icons.schedule_outlined,
                  title: 'Timely Notifications',
                  description: 'Stay ahead with early access to new opportunities',
                ),
                SizedBox(height: 20.h),
      
                // Action Buttons
                if (_isSubscribed) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: FButton(
                      onPress: () {
                        setState(() {
                          _isSubscribed = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Successfully unsubscribed from job updates'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: Text(
                        'Unsubscribe',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: FButton(
                      onPress: () {
                        setState(() {
                          _isSubscribed = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Successfully subscribed to job updates'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: Text(
                        'Subscribe Now',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(
              icon,
              size: 20.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF666666),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
