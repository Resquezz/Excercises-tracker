import 'package:flutter/material.dart';

class StatisticsTab extends StatelessWidget {
  const StatisticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Select date',
                    fillColor: Colors.grey,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter exercise name',
                    fillColor: Colors.grey,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(child: Text('Training weights')),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(child: Text('Workouts performed')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
