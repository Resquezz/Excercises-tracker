import 'package:excercises_tracker/blocs/trainings_bloc.dart';
import 'package:excercises_tracker/models/training.dart';
import 'package:excercises_tracker/screens/create_training_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TrainingDetailScreen extends StatelessWidget {
  final Training training;

  const TrainingDetailScreen({super.key, required this.training});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: const Text('Training Details', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (routeContext) {
                    return BlocProvider.value(
                      value: BlocProvider.of<TrainingsBloc>(context),
                      child: CreateTrainingScreen(training: training),
                    );
                  },
                ),
              ).then((_) {
                Navigator.pop(context);
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (training.photoUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Image.network(
                  training.photoUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Text('Error loading image', style: TextStyle(color: Colors.red)),
                ),
              ),
            Text('Date: ${training.date}', style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Type: ${training.type}', style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Duration: ${training.duration} min', style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Description: ${training.description}', style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 16),
            const Text('Exercises:', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (training.exercises.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: training.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = training.exercises[index];
                    return ListTile(
                      title: Text('${exercise.name} - ${exercise.weight} kg', style: const TextStyle(color: Colors.white)),
                    );
                  },
                ),
              )
            else
              const Text('No exercises', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}