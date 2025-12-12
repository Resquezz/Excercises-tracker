part of 'training_form_bloc.dart';

abstract class TrainingFormState {}

class TrainingFormInitial extends TrainingFormState {}
class TrainingFormSubmitting extends TrainingFormState {}
class TrainingFormSuccess extends TrainingFormState {}
class TrainingFormError extends TrainingFormState {
  final String error;
  TrainingFormError({required this.error});
}