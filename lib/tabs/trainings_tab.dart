import 'package:excercises_tracker/blocs/trainings_bloc.dart';
import 'package:excercises_tracker/models/training.dart';
import 'package:excercises_tracker/screens/create_training_screen.dart';
import 'package:excercises_tracker/screens/training_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TrainingsTab extends StatelessWidget {
  const TrainingsTab({super.key});

  Future<void> _showDeleteConfirmation(BuildContext context, Training training) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Delete Training',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this training? This action cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                if (training.id != null) {
                  context.read<TrainingsBloc>().add(DeleteTraining(training));
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My trainings',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (routeContext) {
                        return BlocProvider.value(
                          value: BlocProvider.of<TrainingsBloc>(context),
                          child: const CreateTrainingScreen(),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<TrainingsBloc, TrainingsState>(
              builder: (context, state) {
                if (state is TrainingsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TrainingsLoaded) {
                  if (state.data.isEmpty) {
                    return const Center(
                      child: Text(
                        'No trainings yet. Press + to add one!',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 0, bottom: 32.0),
                    itemCount: state.data.length,
                    itemBuilder: (context, index) {
                      final training = state.data[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (routeContext) => BlocProvider.value(
                                value: context.read<TrainingsBloc>(),
                                child: TrainingDetailScreen(training: training),
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(training.date,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                      Text(training.type,
                                          style: const TextStyle(
                                              color: Colors.black)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () {
                                    _showDeleteConfirmation(context, training);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is TrainingsError) {
                  return Center(
                      child: Text(state.error,
                          style: const TextStyle(color: Colors.red)));
                } else {
                  return const Center(child: Text('No data'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}