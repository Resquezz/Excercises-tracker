import 'dart:io';
import 'package:excercises_tracker/blocs/training_form_bloc.dart';
import 'package:excercises_tracker/blocs/trainings_bloc.dart';
import 'package:excercises_tracker/models/training.dart';
import 'package:excercises_tracker/repositories/storage_repository.dart';
import 'package:excercises_tracker/repositories/trainings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:excercises_tracker/models/excercise.dart';

class CreateTrainingScreen extends StatefulWidget {
  final Training? training;

  const CreateTrainingScreen({super.key, this.training});

  @override
  State<CreateTrainingScreen> createState() => _CreateTrainingScreenState();
}

class _CreateTrainingScreenState extends State<CreateTrainingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _exerciseNameController = TextEditingController();
  final _weightController = TextEditingController();

  final List<String> _trainingTypes = [
    'Strength',
    'Cardio',
    'HIIT',
    'Yoga',
    'CrossFit',
    'Swimming',
    'Running',
    'Other',
  ];

  String? _selectedType;
  DateTime? _selectedDate;
  File? _pickedImage;

  List<Exercise> _exercises = [];

  @override
  void initState() {
    super.initState();
    if (widget.training != null) {
      _dateController.text = widget.training!.date;
      _durationController.text = widget.training!.duration.toString();
      _descriptionController.text = widget.training!.description;
      _selectedType = widget.training!.type;
      _exercises = List.from(widget.training!.exercises);

      try {
        _selectedDate = DateFormat('dd/MM/yyyy').parse(widget.training!.date);
      } catch (e) {
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    _exerciseNameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submit(BuildContext blocContext) {
    if (_formKey.currentState!.validate()) {
      final trainingData = Training(
        id: widget.training?.id,
        date: _dateController.text,
        type: _selectedType!,
        duration: int.parse(_durationController.text),
        description: _descriptionController.text,
        exercises: List.from(_exercises),
        photoUrl: widget.training?.photoUrl,
      );

      blocContext.read<TrainingFormBloc>().add(
        TrainingFormSubmitted(
          training: trainingData,
          imageFile: _pickedImage,
        ),
      );
    }
  }

  void _addExercise() {
    if (_exerciseNameController.text.isNotEmpty &&
        _weightController.text.isNotEmpty &&
        double.tryParse(_weightController.text) != null) {
      setState(() {
        _exercises.add(Exercise(
          name: _exerciseNameController.text,
          weight: double.parse(_weightController.text),
        ));
      });
      _exerciseNameController.clear();
      _weightController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _pickPhoto() async {
    final file = await context.read<StorageRepository>().pickImage();
    if (file != null) {
      setState(() {
        _pickedImage = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TrainingFormBloc(
        trainingsRepository: context.read<TrainingsRepository>(),
        storageRepository: context.read<StorageRepository>(),
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[800],
        appBar: AppBar(
          backgroundColor: Colors.grey[800],
          title: Text(
            widget.training == null ? 'Create New Training' : 'Edit Training',
            style: const TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocListener<TrainingFormBloc, TrainingFormState>(
          listener: (context, state) {
            if (state is TrainingFormSuccess) {
              context.read<TrainingsBloc>().add(RefreshTrainings());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(widget.training == null
                        ? 'Training saved!'
                        : 'Training updated!'),
                    backgroundColor: Colors.green),
              );
            } else if (state is TrainingFormError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.redAccent),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text('Date', style: TextStyle(color: Colors.white)),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Select date',
                            fillColor: Colors.grey,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            errorStyle:
                            const TextStyle(color: Colors.redAccent),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a date';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today,
                            color: Colors.white),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                              _dateController.text =
                                  DateFormat('dd/MM/yyyy').format(date);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text('Type', style: TextStyle(color: Colors.white)),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    hint: const Text('Select type'),
                    decoration: InputDecoration(
                      fillColor: Colors.grey,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      errorStyle: const TextStyle(color: Colors.redAccent),
                    ),
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black),
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Colors.black),
                    items: _trainingTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text('Duration', style: TextStyle(color: Colors.white)),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Enter duration (min)',
                            fillColor: Colors.grey,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            errorStyle:
                            const TextStyle(color: Colors.redAccent),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter duration';
                            }
                            if (int.tryParse(value) == null ||
                                int.parse(value) <= 0) {
                              return 'Enter valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _pickPhoto,
                        child: Text(_pickedImage != null
                            ? 'Photo Added!'
                            : (widget.training?.photoUrl != null
                            ? 'Change Photo'
                            : 'Add photo')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text('Description',
                      style: TextStyle(color: Colors.white)),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      fillColor: Colors.grey,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      errorStyle: const TextStyle(color: Colors.redAccent),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text('Exercises',
                      style: TextStyle(color: Colors.white)),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _exerciseNameController,
                          decoration: InputDecoration(
                            hintText: 'Enter name',
                            fillColor: Colors.grey,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Weight (kg)',
                            fillColor: Colors.grey,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle,
                            color: Colors.white),
                        onPressed: _addExercise,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_exercises.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = _exercises[index];
                        return ListTile(
                          title: Text(
                              '${exercise.name} - ${exercise.weight} kg',
                              style: const TextStyle(color: Colors.white)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                _exercises.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 32),

                  BlocBuilder<TrainingFormBloc, TrainingFormState>(
                    builder: (context, state) {
                      if (state is TrainingFormSubmitting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ElevatedButton(
                        onPressed: () => _submit(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          widget.training == null ? 'Add' : 'Save Changes',
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}