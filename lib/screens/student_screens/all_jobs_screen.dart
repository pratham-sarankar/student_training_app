import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:learn_work/screens/student_screens/job_details_screen.dart';
import 'package:learn_work/screens/student_screens/edit_profile_screen.dart';
import '../../models/job.dart';
import '../../models/user.dart';
import '../../services/job_service.dart';
import '../../services/user_service.dart';
import '../../widgets/shimmer_loading.dart';
import 'package:shimmer/shimmer.dart';

class AllJobsScreen extends StatefulWidget {
  const AllJobsScreen({super.key});

  @override
  State<AllJobsScreen> createState() => _AllJobsScreenState();
}

class _AllJobsScreenState extends State<AllJobsScreen> {
  final JobService _jobService = JobService();
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isInitialized = false;
  UserModel? _currentUser;
  String _currentLocation = 'Getting location...';
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _initializeJobs();
    _loadCurrentUser();
    _getCurrentLocation();
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

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _userService.getCurrentUserDataWithFallback();
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentLocation = 'Location services disabled';
          _isLoadingLocation = false;
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentLocation = 'Location permission denied';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocation = 'Location permission permanently denied';
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Convert coordinates to readable address
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String location = '';

          // Build location string with local, city format
          String local = '';
          String city = '';

          // Get local area (subLocality or neighborhood)
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            local = place.subLocality!;
          } else if (place.thoroughfare != null &&
              place.thoroughfare!.isNotEmpty) {
            local = place.thoroughfare!;
          }

          // Get city (locality or administrative area)
          if (place.locality != null && place.locality!.isNotEmpty) {
            city = place.locality!;
          } else if (place.administrativeArea != null &&
              place.administrativeArea!.isNotEmpty) {
            city = place.administrativeArea!;
          }

          // Combine local and city
          if (local.isNotEmpty && city.isNotEmpty) {
            location = '$local, $city';
          } else if (city.isNotEmpty) {
            location = city;
          } else if (local.isNotEmpty) {
            location = local;
          } else {
            location = 'Unknown location';
          }

          setState(() {
            _currentLocation = location;
            _isLoadingLocation = false;
          });
        } else {
          setState(() {
            _currentLocation = 'Unknown location';
            _isLoadingLocation = false;
          });
        }
      } catch (e) {
        print('Error getting address: $e');
        setState(() {
          _currentLocation = 'Unknown location';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _currentLocation = 'Error getting location';
        _isLoadingLocation = false;
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
    final theme = Theme.of(context);

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: theme.colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // App Bar with App Name and User Avatar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App Name and Location
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gradspark',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              _isLoadingLocation
                                  ? SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: Shimmer.fromColors(
                                      baseColor:
                                          theme
                                              .colorScheme
                                              .surfaceContainerHighest,
                                      highlightColor: theme
                                          .colorScheme
                                          .surfaceContainerHighest
                                          .withValues(alpha: 0.6),
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  )
                                  : Text(
                                    _currentLocation,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // User Avatar
                    _buildUserAvatar(theme),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Search jobs...',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.colorScheme.onSurfaceVariant,
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
              const SizedBox(height: 16),

              // Jobs List with Carousel
              Expanded(
                child:
                    _isInitialized
                        ? _buildJobsListWithCarousel(theme)
                        : _buildShimmerLoading(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditProfileScreen()),
        );
      },
      child:
          _currentUser?.photoUrl != null && _currentUser!.photoUrl!.isNotEmpty
              ? CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(_currentUser!.photoUrl!),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              )
              : CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  _currentUser?.initials ?? 'U',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
    );
  }

  Widget _buildJobsListWithCarousel(ThemeData theme) {
    if (_searchQuery.isEmpty) {
      return StreamBuilder<List<Job>>(
        stream: _jobService.getJobs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading(Theme.of(context));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading jobs: ${snapshot.error}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No jobs available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Banner Carousel
              _buildBannerCarousel(theme),
              const SizedBox(height: 16),
              // Jobs
              ...jobs.map((job) => Container(child: _buildJobCard(job))),
            ],
          );
        },
      );
    } else {
      return StreamBuilder<List<Job>>(
        stream: _jobService.searchJobs(_searchQuery),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading(Theme.of(context));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error searching jobs: ${snapshot.error}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No jobs found for "$_searchQuery"',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try different keywords or check spelling',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Banner Carousel
              _buildBannerCarousel(theme),
              const SizedBox(height: 16),
              // Jobs
              ...jobs.map((job) => Container(child: _buildJobCard(job))),
            ],
          );
        },
      );
    }
  }

  Widget _buildJobCard(Job job) {
    final theme = Theme.of(context);

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
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline, width: 1),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
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
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      job.logo.isNotEmpty && job.logo.startsWith('http')
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              job.logo,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primary,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    job.company.isNotEmpty
                                        ? job.company
                                            .substring(0, 1)
                                            .toUpperCase()
                                        : 'C',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                          : Center(
                            child: Text(
                              job.company.isNotEmpty
                                  ? job.company.substring(0, 1).toUpperCase()
                                  : 'C',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
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
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                job.salary,
                style: TextStyle(
                  color: theme.colorScheme.primary,
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
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBannerCarousel(ThemeData theme) {
    return _CarouselWidget(theme: theme);
  }

  Widget _buildShimmerLoading(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Banner Carousel placeholder
        Container(
          height: MediaQuery.of(context).size.width * 0.85 * (9 / 16),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 16),
        // Job cards shimmer
        ...List.generate(5, (index) => ShimmerLoading.jobCardShimmer(theme)),
      ],
    );
  }
}

class _CarouselWidget extends StatefulWidget {
  final ThemeData theme;

  const _CarouselWidget({required this.theme});

  @override
  State<_CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<_CarouselWidget> {
  int _currentCarouselIndex = 0;

  // Random image URLs for the carousel
  final List<String> randomImages = [
    'https://tse3.mm.bing.net/th/id/OIP.E-8vX505ECdMwROR-dUXvAAAAA?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://thumbs.dreamstime.com/b/education-vector-trendy-banner-design-concept-modern-style-thin-line-art-icons-gradient-colors-background-93713303.jpg',
    'https://i.pinimg.com/originals/a7/d9/66/a7d96663c07fc0c8bd0dc22b7f56b986.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            clipBehavior: Clip.none,
            height:
                MediaQuery.of(context).size.width *
                0.85 *
                (9 / 16), // 16:9 aspect ratio
            viewportFraction: 0.85, // Same as original job card spacing
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            enlargeFactor: 0.1,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
          items:
              randomImages.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.fill,
                          width: double.infinity,
                          height:
                              MediaQuery.of(context).size.width *
                              0.85 *
                              (9 / 16),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: double.infinity,
                              height:
                                  MediaQuery.of(context).size.width *
                                  0.85 *
                                  (9 / 16),
                              decoration: BoxDecoration(
                                color:
                                    widget
                                        .theme
                                        .colorScheme
                                        .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height:
                                  MediaQuery.of(context).size.width *
                                  0.85 *
                                  (9 / 16),
                              decoration: BoxDecoration(
                                color:
                                    widget
                                        .theme
                                        .colorScheme
                                        .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color:
                                          widget
                                              .theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Failed to load image',
                                      style: widget.theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color:
                                                widget
                                                    .theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
        ),
        const SizedBox(height: 12),
        // Dotted indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              randomImages.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentCarouselIndex == entry.key
                            ? widget.theme.colorScheme.primary
                            : widget.theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.3),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
