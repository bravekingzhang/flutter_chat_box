part of 'prompt_bloc.dart';

class Prompt {
  final String act;
  final String prompt;

  Prompt(this.act, this.prompt);
}

abstract class PromptState extends Equatable {
  const PromptState();

  @override
  List<Object> get props => [];
}

class PromptInitial extends PromptState {}

class PromptSuccess extends PromptState {
  final List<Prompt> prompts;
  const PromptSuccess(this.prompts);
}

class PromptLoading extends PromptState {}

class PromptFailed extends PromptState {}
