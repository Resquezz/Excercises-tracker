import 'package:bloc/bloc.dart';
import 'package:excercises_tracker/models/training.dart';
import 'package:excercises_tracker/repositories/storage_repository.dart';
import 'package:excercises_tracker/repositories/trainings_repository.dart';

part 'trainings_event.dart';
part 'trainings_state.dart';

class TrainingsBloc extends Bloc<TrainingsEvent, TrainingsState> {
  final TrainingsRepository _trainingsRepository;
  final StorageRepository _storageRepository;

  TrainingsBloc({
    required TrainingsRepository trainingsRepository,
    required StorageRepository storageRepository,
  })  : _trainingsRepository = trainingsRepository,
        _storageRepository = storageRepository,
        super(TrainingsInitial()) {
    on<RefreshTrainings>(_onRefreshTrainings);
    on<DeleteTraining>(_onDeleteTraining);
  }

  Future<void> _onRefreshTrainings(
      RefreshTrainings event,
      Emitter<TrainingsState> emit,
      ) async {
    emit(TrainingsLoading());
    try {
      final result = await _trainingsRepository.getTrainings();
      emit(TrainingsLoaded(data: result));
    } catch (e) {
      emit(TrainingsError(error: 'Failed to load trainings: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTraining(
      DeleteTraining event,
      Emitter<TrainingsState> emit,
      ) async {
    try {
      if (event.training.photoUrl != null && event.training.photoUrl!.isNotEmpty) {
        await _storageRepository.deleteImage(event.training.photoUrl!);
      }

      if (event.training.id != null) {
        await _trainingsRepository.deleteTraining(event.training.id!);
      }

      add(RefreshTrainings());
    } catch (e) {
      emit(TrainingsError(error: 'Failed to delete training. Error message: ${e.toString()}'));
    }
  }
}