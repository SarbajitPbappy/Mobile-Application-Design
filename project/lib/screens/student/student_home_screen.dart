import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/surplus_provider.dart';
import '../../models/surplus_post_model.dart';
import 'post_details_screen.dart';
import 'student_reservations_screen.dart';
import 'student_profile_screen.dart';
import '../../screens/leaderboard_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    // Load posts when screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final surplusProvider = Provider.of<SurplusProvider>(context, listen: false);
      surplusProvider.loadActivePosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Surplus Food'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LeaderboardScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'all', label: Text('All')),
                      ButtonSegment(value: 'veg', label: Text('Veg')),
                      ButtonSegment(
                        value: 'nonVeg',
                        label: Text('Non-Veg'),
                      ),
                    ],
                    selected: {_selectedFilter},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedFilter = newSelection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<SurplusProvider>(
              builder: (context, surplusProvider, _) {
                if (surplusProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final posts = _filterPosts(
                  surplusProvider.activePosts,
                  _selectedFilter,
                );

                if (posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No surplus food available',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return _SurplusPostCard(post: posts[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'My Reservations',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StudentReservationsScreen(),
              ),
            );
          }
        },
      ),
    );
  }

  List<SurplusPostModel> _filterPosts(
    List<SurplusPostModel> posts,
    String filter,
  ) {
    if (filter == 'all') return posts;
    if (filter == 'veg') {
      return posts.where((p) => p.category == FoodCategory.veg).toList();
    }
    return posts.where((p) => p.category == FoodCategory.nonVeg).toList();
  }
}

class _SurplusPostCard extends StatelessWidget {
  final SurplusPostModel post;

  const _SurplusPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostDetailsScreen(post: post),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: post.category == FoodCategory.veg
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      post.category == FoodCategory.veg ? 'Veg' : 'Non-Veg',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (post.description != null && post.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  post.description!,
                  style: TextStyle(color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.restaurant, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${post.availablePortions} portions available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      post.pickupLocation,
                      style: TextStyle(color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Until ${_formatTime(post.endTime)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

