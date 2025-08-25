import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'job_details_screen.dart';

class AllJobsScreen extends StatefulWidget {
  const AllJobsScreen({super.key});

  @override
  State<AllJobsScreen> createState() => _AllJobsScreenState();
}

class _AllJobsScreenState extends State<AllJobsScreen> {
  final List<Map<String, dynamic>> _jobs = [
    {
      'title': 'Senior Flutter Developer',
      'company': 'TechCorp Solutions',
      'location': 'Bangalore',
      'type': 'Full-time',
      'salary': '₹12,00,000 - ₹18,00,000',
      'category': 'Software Development',
      'posted': '2 days ago',
      'logo': 'TC',
    },
    {
      'title': 'Data Analyst',
      'company': 'DataFlow Inc',
      'location': 'Mumbai',
      'type': 'Full-time',
      'salary': '₹8,00,000 - ₹12,00,000',
      'category': 'Data Science',
      'posted': '1 day ago',
      'logo': 'DF',
    },
    {
      'title': 'UI/UX Designer',
      'company': 'Creative Studios',
      'location': 'Delhi',
      'type': 'Contract',
      'salary': '₹10,00,000 - ₹15,00,000',
      'category': 'Design',
      'posted': '3 days ago',
      'logo': 'CS',
    },
    {
      'title': 'Marketing Manager',
      'company': 'Growth Marketing',
      'location': 'Hyderabad',
      'type': 'Full-time',
      'salary': '₹9,00,000 - ₹14,00,000',
      'category': 'Marketing',
      'posted': '5 days ago',
      'logo': 'GM',
    },
    {
      'title': 'Sales Representative',
      'company': 'SalesForce Pro',
      'location': 'Chennai',
      'type': 'Full-time',
      'salary': '₹6,00,000 - ₹10,00,000',
      'category': 'Sales',
      'posted': '1 week ago',
      'logo': 'SP',
    },
    {
      'title': 'Customer Success Manager',
      'company': 'Support Hub',
      'location': 'Pune',
      'type': 'Full-time',
      'salary': '₹7,00,000 - ₹12,00,000',
      'category': 'Customer Service',
      'posted': '4 days ago',
      'logo': 'SH',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Title
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: Text(
                  'All Jobs',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            
            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xFFE5E5E5),
                    width: 1.w,
                  ),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search jobs...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade500,
                      size: 20.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                  onChanged: (value) {
                    // TODO: Implement search functionality
                    setState(() {
                      // Filter jobs based on search query
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 10.h),
            
            // Jobs List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _jobs.length,
                itemBuilder: (context, index) {
                  final job = _jobs[index];
                  return Container(
                    child: _buildJobCard(job),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsScreen(job: job),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFE5E5E5),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Company Logo
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      job['logo'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                
                // Job Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['title'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        job['company'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF666666),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                

              ],
            ),
            SizedBox(height: 16.h),
            
            // Job Details Row
            Row(
              children: [
                _buildJobDetail(Icons.location_on_outlined, job['location']),
                SizedBox(width: 16.w),
                _buildJobDetail(Icons.work_outline, job['type']),
                SizedBox(width: 16.w),
                _buildJobDetail(Icons.access_time, job['posted']),
              ],
            ),
            SizedBox(height: 12.h),
            
            // Salary
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                job['salary'],
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: const Color(0xFF999999),
        ),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            color: const Color(0xFF666666),
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
