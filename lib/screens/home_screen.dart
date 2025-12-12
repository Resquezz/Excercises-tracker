import 'package:excercises_tracker/blocs/trainings_bloc.dart';
import 'package:excercises_tracker/repositories/trainings_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../tabs/trainings_tab.dart';
import '../tabs/statistics_tab.dart';
import '../tabs/settings_tab.dart';
import 'package:excercises_tracker/repositories/storage_repository.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late StreamSubscription<User?> _userSubscription;
  String _displayName = 'User';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    _displayName = FirebaseAuth.instance.currentUser?.displayName ?? 'User';

    _userSubscription = FirebaseAuth.instance.userChanges().listen((User? user) {
      if (user != null && mounted) {
        setState(() {
          _displayName = user.displayName ?? 'User';
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hi, $_displayName!',
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: Icon(Icons.fitness_center,
                    color: _tabController.index == 0 ? Colors.green : Colors.white),
                child: Text('Trainings',
                    style: TextStyle(
                        color:
                        _tabController.index == 0 ? Colors.green : Colors.white)),
              ),
              Tab(
                icon: Icon(Icons.bar_chart,
                    color: _tabController.index == 1 ? Colors.green : Colors.white),
                child: Text('Statistics',
                    style: TextStyle(
                        color:
                        _tabController.index == 1 ? Colors.green : Colors.white)),
              ),
              Tab(
                icon: Icon(Icons.settings,
                    color: _tabController.index == 2 ? Colors.green : Colors.white),
                child: Text('Settings',
                    style: TextStyle(
                        color:
                        _tabController.index == 2 ? Colors.green : Colors.white)),
              ),
            ],
          ),
          Expanded(
            child: BlocProvider(
              create: (context) => TrainingsBloc(
                trainingsRepository: context.read<TrainingsRepository>(),
                storageRepository: context.read<StorageRepository>(),
              )..add(RefreshTrainings()),
              child: TabBarView(
                controller: _tabController,
                children: const [
                  TrainingsTab(),
                  StatisticsTab(),
                  SettingsTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}