part of 'prompt_bloc.dart';

abstract class PromptEvent extends Equatable {
  const PromptEvent();

  @override
  List<Object> get props => [];
}

class PromptFetch extends PromptEvent {}
