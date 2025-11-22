import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import 'impact_screen.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leaderboard & Impact'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Students'),
              Tab(text: 'Cafeterias'),
              Tab(text: 'Impact'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _StudentsLeaderboard(),
            _CafeteriasLeaderboard(),
            ImpactScreen(),
          ],
        ),
      ),
    );
  }
}

class _StudentsLeaderboard extends StatelessWidget {
  const _StudentsLeaderboard();

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestoreService.getTopStudents(limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final student = snapshot.data![index];
            final rank = index + 1;
            final points = student['points'] ?? 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRankColor(rank),
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(student['name'] ?? 'Unknown'),
                subtitle: Text('Student ID: ${student['studentId'] ?? 'N/A'}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$points pts',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey[400]!;
    if (rank == 3) return Colors.brown[300]!;
    return Colors.blue;
  }
}

class _CafeteriasLeaderboard extends StatelessWidget {
  const _CafeteriasLeaderboard();

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestoreService.getTopCafeterias(limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final cafeteria = snapshot.data![index];
            final rank = index + 1;
            final points = cafeteria['points'] ?? 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRankColor(rank),
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(cafeteria['organizationName'] ?? 'Unknown'),
                subtitle: Text(cafeteria['location'] ?? ''),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$points pts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey[400]!;
    if (rank == 3) return Colors.brown[300]!;
    return Colors.green;
  }
}

