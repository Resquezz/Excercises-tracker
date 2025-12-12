part of 'trainings_bloc.dart';

abstract class TrainingsState {}

class TrainingsInitial extends TrainingsState {}

class TrainingsLoading extends TrainingsState {}

class TrainingsLoaded extends TrainingsState {
  final List<Training> data;

  TrainingsLoaded({required this.data});
}

class TrainingsError extends TrainingsState {
  final String error;

  TrainingsError({required this.error});
}