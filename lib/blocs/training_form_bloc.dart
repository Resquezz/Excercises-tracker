import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:excercises_tracker/models/training.dart';
import 'package:excercises_tracker/repositories/storage_repository.dart';
import 'package:excercises_tracker/repositories/trainings_repository.dart';

part 'training_form_event.dart';
part 'training_form_state.dart';

class TrainingFormBloc extends Bloc<TrainingFormEvent, TrainingFormState> {
  final TrainingsRepository _trainingsRepository;
  final StorageRepository _storageRepository;

  TrainingFormBloc({
    required TrainingsRepository trainingsRepository,
    required StorageRepository storageRepository,
  })  : _trainingsRepository = trainingsRepository,
        _storageRepository = storageRepository,
        super(TrainingFormInitial()) {
    on<TrainingFormSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
      TrainingFormSubmitted event,
      Emitter<TrainingFormState> emit,
      ) async {
    emit(TrainingFormSubmitting());
    try {
      String? photoUrl = event.training.photoUrl;

      if (event.imageFile != null) {
        photoUrl = await _storageRepository.uploadTrainingImage(event.imageFile!);
      }

      final trainingData = Training(
        id: event.training.id,
        date: event.training.date,
        type: event.training.type,
        duration: event.training.duration,
        description: event.training.description,
        exercises: event.training.exercises,
        photoUrl: photoUrl,
        serverTimestamp: null,
      );

      if (event.training.id != null && event.training.id!.isNotEmpty) {
        await _trainingsRepository.updateTraining(trainingData);
      } else {
        await _trainingsRepository.addTraining(trainingData);
      }

      emit(TrainingFormSuccess());
    } catch (e) {
      emit(TrainingFormError(error: 'Failed to save training: ${e.toString()}'));
    }
  }
}