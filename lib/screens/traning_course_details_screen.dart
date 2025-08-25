import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TraningCourseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> course;
  
  const TraningCourseDetailsScreen({
    super.key,
    required this.course,
  });

  @override
  State<TraningCourseDetailsScreen> createState() => _TraningCourseDetailsScreenState();
}

class _TraningCourseDetailsScreenState extends State<TraningCourseDetailsScreen> {
  Map<String, dynamic>? _selectedSchedule;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Compact header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  FButton(
                    onPress: () => Navigator.of(context).pop(),
                    style: FButtonStyle.outline,
                    child: Icon(
                      Icons.arrow_back,
                      size: 16.sp,
                      color: const Color(0xFF666666),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Course Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),

            // Compact content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Image - very compact
                    Container(
                      width: double.infinity,
                      height: 120.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        image: DecorationImage(
                          image: NetworkImage(widget.course['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Course Title
                    Text(
                      widget.course['title'],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Course Tags - inline
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            widget.course['category'],
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            widget.course['level'],
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Course Description
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      widget.course['description'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF666666),
                        height: 1.4,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),

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
                        SizedBox(width: 16.w),
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
                    SizedBox(height: 16.h),

                    // Available Schedules
                    Text(
                      'Available Schedules',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    ...widget.course['schedules'].map<Widget>((schedule) {
                      bool isSelected = _selectedSchedule == schedule;
                      return Container(
                        margin: EdgeInsets.only(bottom: 6.h),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedSchedule = schedule;
                            });
                          },
                          borderRadius: BorderRadius.circular(6.r),
                          child: Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: isSelected 
                                    ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.2),
                                width: isSelected ? 1.5.w : 0.5.w,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        schedule['time'],
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1A1A1A),
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'Starts: ${schedule['startDate']} • ${schedule['seats']} seats',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: const Color(0xFF666666),
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Radio<Map<String, dynamic>>(
                                  value: schedule,
                                  groupValue: _selectedSchedule,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSchedule = value;
                                    });
                                  },
                                  activeColor: Theme.of(context).colorScheme.primary,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                    SizedBox(height: 60.h), // Minimal space for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedSchedule != null
          ? Container(
              margin: EdgeInsets.only(bottom: 8.h),
              child: FButton(
                onPress: () => _showPurchaseDialog(context, widget.course, _selectedSchedule!),
                style: FButtonStyle.primary,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Purchase Course - ₹${widget.course['cost']}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSimpleDetail(IconData icon, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18.sp,
            color: color,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF666666),
                    fontSize: 11.sp,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, Map<String, dynamic> course, Map<String, dynamic> schedule) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 4,
          child: Container(
            constraints: BoxConstraints(maxWidth: 350.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Simple header
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Purchase Confirmation',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Simple content
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Course: ${course['title']}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Schedule: ${schedule['time']}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF666666),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Start Date: ${schedule['startDate']}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF666666),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Cost:',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '₹${course['cost']}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
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
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FButton(
                        onPress: () => Navigator.of(context).pop(),
                        style: FButtonStyle.outline,
                        child: Text('Cancel'),
                      ),
                      SizedBox(width: 8.w),
                      FButton(
                        onPress: () {
                          Navigator.of(context).pop();
                          _processPurchase(course, schedule);
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

  void _processPurchase(Map<String, dynamic> course, Map<String, dynamic> schedule) {
    // TODO: Implement actual purchase logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                'Successfully purchased ${course['title']} for ${schedule['time']}',
                style: TextStyle(fontSize: 12.sp),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.r),
        ),
      ),
    );
    
    // Navigate back to courses screen
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }
}
