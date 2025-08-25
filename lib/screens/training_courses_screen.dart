import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'traning_course_details_screen.dart';

class TrainingCoursesScreen extends StatefulWidget {
  const TrainingCoursesScreen({super.key});

  @override
  State<TrainingCoursesScreen> createState() => _TrainingCoursesScreenState();
}

class _TrainingCoursesScreenState extends State<TrainingCoursesScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Technology', 'Design', 'Business', 'Marketing'];
  
  final List<Map<String, dynamic>> _courses = [
    {
      'title': 'Flutter Development Fundamentals',
      'category': 'Technology',
      'description': 'Learn Flutter from scratch and build beautiful mobile applications for iOS and Android.',
      'cost': 99.99,
      'duration': '8 weeks',
      'level': 'Beginner',
      'image': 'https://elements-resized.envatousercontent.com/envato-dam-assets-production/EVA/TRX/2b/0b/38/42/89/v1_E10/E107OQSH.JPG?w=1600&cf_fit=scale-down&mark-alpha=18&mark=https%3A%2F%2Felements-assets.envato.com%2Fstatic%2Fwatermark4.png&q=85&format=auto&s=65dd1c957cd287a87f8117a41cedb3edb353b9f9bfc6b1e352c9b8f94e95154c',
      'schedules': [
        {'time': 'Mon, Wed 6:00 PM', 'seats': 15, 'startDate': '2024-02-01'},
        {'time': 'Tue, Thu 7:00 PM', 'seats': 12, 'startDate': '2024-02-15'},
        {'time': 'Sat 10:00 AM', 'seats': 20, 'startDate': '2024-02-10'},
      ],
    },
    {
      'title': 'UI/UX Design Masterclass',
      'category': 'Design',
      'description': 'Master the principles of user interface and user experience design.',
      'cost': 149.99,
      'duration': '6 weeks',
      'level': 'Intermediate',
      'image': 'https://elements-resized.envatousercontent.com/envato-dam-assets-production/EVA/TRX/2b/0b/38/42/89/v1_E10/E107OQSH.JPG?w=1600&cf_fit=scale-down&mark-alpha=18&mark=https%3A%2F%2Felements-assets.envato.com%2Fstatic%2Fwatermark4.png&q=85&format=auto&s=65dd1c957cd287a87f8117a41cedb3edb353b9f9bfc6b1e352c9b8f94e95154c',
      'schedules': [
        {'time': 'Mon, Wed 7:00 PM', 'seats': 18, 'startDate': '2024-02-05'},
        {'time': 'Sat 2:00 PM', 'seats': 25, 'startDate': '2024-02-12'},
      ],
    },
    {
      'title': 'Data Science with Python',
      'category': 'Technology',
      'description': 'Learn data analysis, machine learning, and statistical modeling with Python.',
      'cost': 199.99,
      'duration': '10 weeks',
      'level': 'Advanced',
      'image': 'https://elements-resized.envatousercontent.com/envato-dam-assets-production/EVA/TRX/2b/0b/38/42/89/v1_E10/E107OQSH.JPG?w=1600&cf_fit=scale-down&mark-alpha=18&mark=https%3A%2F%2Felements-assets.envato.com%2Fstatic%2Fwatermark4.png&q=85&format=auto&s=65dd1c957cd287a87f8117a41cedb3edb353b9f9bfc6b1e352c9b8f94e95154c',
      'schedules': [
        {'time': 'Tue, Thu 6:30 PM', 'seats': 10, 'startDate': '2024-02-08'},
        {'time': 'Sun 11:00 AM', 'seats': 15, 'startDate': '2024-02-18'},
      ],
    },
    {
      'title': 'Digital Marketing Strategy',
      'category': 'Marketing',
      'description': 'Develop comprehensive digital marketing strategies for business growth.',
      'cost': 129.99,
      'duration': '5 weeks',
      'level': 'Beginner',
      'image': 'https://elements-resized.envatousercontent.com/envato-dam-assets-production/EVA/TRX/2b/0b/38/42/89/v1_E10/E107OQSH.JPG?w=1600&cf_fit=scale-down&mark-alpha=18&mark=https%3A%2F%2Felements-assets.envato.com%2Fstatic%2Fwatermark4.png&q=85&format=auto&s=65dd1c957cd287a87f8117a41cedb3edb353b9f9bfc6b1e352c9b8f94e95154c',
      'schedules': [
        {'time': 'Wed, Fri 6:00 PM', 'seats': 22, 'startDate': '2024-02-03'},
        {'time': 'Sat 9:00 AM', 'seats': 30, 'startDate': '2024-02-20'},
      ],
    },
    {
      'title': 'Business Analytics',
      'category': 'Business',
      'description': 'Learn to analyze business data and make data-driven decisions.',
      'cost': 179.99,
      'duration': '7 weeks',
      'level': 'Intermediate',
      'image': 'https://elements-resized.envatousercontent.com/envato-dam-assets-production/EVA/TRX/2b/0b/38/42/89/v1_E10/E107OQSH.JPG?w=1600&cf_fit=scale-down&mark-alpha=18&mark=https%3A%2F%2Felements-assets.envato.com%2Fstatic%2Fwatermark4.png&q=85&format=auto&s=65dd1c957cd287a87f8117a41cedb3edb353b9f9bfc6b1e352c9b8f94e95154c',
      'schedules': [
        {'time': 'Mon, Thu 7:30 PM', 'seats': 16, 'startDate': '2024-02-06'},
        {'time': 'Sun 3:00 PM', 'seats': 20, 'startDate': '2024-02-25'},
      ],
    },
  ];

  List<Map<String, dynamic>> get _filteredCourses {
    if (_selectedCategory == 'All') {
      return _courses;
    }
    return _courses.where((course) => course['category'] == _selectedCategory).toList();
  }

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
                  'Training Courses',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),

            // Category Filter using Forui FButtons
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              child: SingleChildScrollView(
                clipBehavior: Clip.none,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((category) {
                    bool isSelected = _selectedCategory == category;
                    int courseCount = category == 'All' 
                        ? _courses.length 
                        : _courses.where((course) => course['category'] == category).length;
                                         return Container(
                       margin: EdgeInsets.only(right: 12.w),
                       decoration: isSelected ? BoxDecoration(
                         borderRadius: BorderRadius.circular(8.r),
                         boxShadow: [
                           BoxShadow(
                             color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                             blurRadius: 8,
                             offset: const Offset(0, 2),
                           ),
                         ],
                       ) : null,
                       child: FButton(
                         onPress: () {
                           setState(() {
                             _selectedCategory = category;
                           });
                         },
                         style: isSelected ? FButtonStyle.primary : FButtonStyle.outline,
                         child: Text(
                           '$category ($courseCount)',
                           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                             fontWeight: FontWeight.w700,
                             color: isSelected 
                                 ? Colors.white
                                 : const Color(0xFF666666),
                           ),
                         ),
                       ),
                     );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Results Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${_filteredCourses.length} courses',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF666666),
                    ),
                  ),
                  if (_selectedCategory != 'All')
                    Text(
                      'Filtered by: $_selectedCategory',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // Courses List
            Expanded(
              child: _filteredCourses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No courses found for "$_selectedCategory"',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Try selecting a different category',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      itemCount: _filteredCourses.length,
                      itemBuilder: (context, index) {
                        final course = _filteredCourses[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          child: _buildCourseCard(context, course),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Map<String, dynamic> course) {
    return GestureDetector(
      onTap: () => _navigateToCourseDetails(course),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
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
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Image
                  Container(
                    width: 80.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      image: DecorationImage(
                        image: NetworkImage(course['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  
                  // Course Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course['title'],
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A1A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                course['category'],
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                course['level'],
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
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
              
              SizedBox(height: 12.h),
              
              // Course Description (shortened)
              Text(
                course['description'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF666666),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: 8.h),
              // View Details hint
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Tap to view details',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12.sp,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }




  void _navigateToCourseDetails(Map<String, dynamic> course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TraningCourseDetailsScreen(course: course),
      ),
    );
  }

}
