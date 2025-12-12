part of 'training_form_bloc.dart';

abstract class TrainingFormEvent {}

class TrainingFormSubmitted extends TrainingFormEvent {
  final Training training;
  final File? imageFile;

  TrainingFormSubmitted({required this.training, this.imageFile});
}