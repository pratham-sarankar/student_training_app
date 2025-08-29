import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final theme = context.theme;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Compact header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    // Course Image - very compact
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(widget.course['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Course Title
                    Text(
                      widget.course['title'],
                      style: theme.typography.xl.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Course Tags - inline
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: theme.colors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(height: 12),

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

                    // Available Schedules
                    Text(
                      'Available Schedules',
                      style: theme.typography.lg.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ...widget.course['schedules'].map<Widget>((schedule) {
                      bool isSelected = _selectedSchedule == schedule;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedSchedule = schedule;
                            });
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? theme.colors.primary.withOpacity(0.05)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected 
                                    ? theme.colors.primary.withOpacity(0.3)
                                    : theme.colors.border.withOpacity(0.2),
                                width: isSelected ? 1.5 : 0.5,
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
                                        style: theme.typography.sm.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme.colors.foreground,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Starts: ${schedule['startDate']} • ${schedule['seats']} seats',
                                        style: theme.typography.sm.copyWith(
                                          color: theme.colors.mutedForeground,
                                          fontSize: 12,
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
                                  activeColor: theme.colors.primary,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 60), // Minimal space for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedSchedule != null
          ? Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: FButton(
                onPress: () => _showPurchaseDialog(context, widget.course, _selectedSchedule!),
                style: FButtonStyle.primary,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        size: 16,
                        color: theme.colors.primaryForeground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Purchase Course - ₹${widget.course['cost']}',
                        style: theme.typography.sm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colors.primaryForeground,
                          fontSize: 13,
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
    final theme = context.theme;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: color,
          ),
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

  void _showPurchaseDialog(BuildContext context, Map<String, dynamic> course, Map<String, dynamic> schedule) {
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
                      Icon(
                        Icons.shopping_cart,
                        color: theme.colors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Purchase Confirmation',
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
                      const SizedBox(height: 4),
                      Text(
                        'Schedule: ${schedule['time']}',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Start Date: ${schedule['startDate']}',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Cost:',
                              style: theme.typography.sm.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '₹${course['cost']}',
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
              size: 16,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Successfully purchased ${course['title']} for ${schedule['time']}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
    
    // Navigate back to courses screen
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }
}
