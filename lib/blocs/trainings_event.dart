part of 'trainings_bloc.dart';

abstract class TrainingsEvent {}

class RefreshTrainings extends TrainingsEvent {}

class DeleteTraining extends TrainingsEvent {
  final Training training;
  DeleteTraining(this.training);
}