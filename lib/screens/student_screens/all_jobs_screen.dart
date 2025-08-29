import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_work/screens/student_screens/job_details_screen.dart';
import '../../models/job.dart';
import '../../services/job_service.dart';

class AllJobsScreen extends StatefulWidget {
  const AllJobsScreen({super.key});

  @override
  State<AllJobsScreen> createState() => _AllJobsScreenState();
}

class _AllJobsScreenState extends State<AllJobsScreen> {
  final JobService _jobService = JobService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeJobs();
  }

  Future<void> _initializeJobs() async {
    try {
      await _jobService.initializeSampleJobs();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing jobs: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        body: SafeArea(
          child: Column(
            children: [
              // Header Title
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'All Jobs',
                    style: theme.typography.lg.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colors.foreground,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colors.muted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colors.border,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Search jobs...',
                      hintStyle: TextStyle(
                        color: theme.colors.mutedForeground,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.colors.mutedForeground,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              
              // Jobs List
              Expanded(
                child: _isInitialized
                    ? _buildJobsList()
                    : Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colors.primary),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobsList() {
    if (_searchQuery.isEmpty) {
      return StreamBuilder<List<Job>>(
        stream: _jobService.getJobs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(context.theme.colors.primary),
              ),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading jobs: ${snapshot.error}',
                style: TextStyle(
                  color: context.theme.colors.destructive,
                  fontSize: 16,
                ),
              ),
            );
          }
          
          final jobs = snapshot.data ?? [];
          
          if (jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 64,
                    color: context.theme.colors.mutedForeground,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No jobs available',
                    style: TextStyle(
                      fontSize: 18,
                      color: context.theme.colors.foreground,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Container(
                child: _buildJobCard(job),
              );
            },
          );
        },
      );
    } else {
      return StreamBuilder<List<Job>>(
        stream: _jobService.searchJobs(_searchQuery),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(context.theme.colors.primary),
              ),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error searching jobs: ${snapshot.error}',
                style: TextStyle(
                  color: context.theme.colors.destructive,
                  fontSize: 16,
                ),
              ),
            );
          }
          
          final jobs = snapshot.data ?? [];
          
          if (jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: context.theme.colors.mutedForeground,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No jobs found for "$_searchQuery"',
                    style: TextStyle(
                      fontSize: 18,
                      color: context.theme.colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try different keywords or check spelling',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Container(
                child: _buildJobCard(job),
              );
            },
          );
        },
      );
    }
  }

  Widget _buildJobCard(Job job) {
    final theme = context.theme;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsScreen(job: job.toMap()),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colors.foreground.withOpacity(0.05),
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      job.logo,
                      style: TextStyle(
                        color: theme.colors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Job Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: theme.typography.lg.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Job Details Row
            Row(
              children: [
                _buildJobDetail(Icons.location_on_outlined, job.location),
                const SizedBox(width: 16),
                _buildJobDetail(Icons.work_outline, job.type),
                const SizedBox(width: 16),
                _buildJobDetail(Icons.access_time, job.posted),
              ],
            ),
            const SizedBox(height: 12),
            
            // Salary
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                job.salary,
                style: TextStyle(
                  color: theme.colors.primary,
                  fontSize: 12,
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
    final theme = context.theme;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colors.mutedForeground,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: theme.colors.mutedForeground,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
