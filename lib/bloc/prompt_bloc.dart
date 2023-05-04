import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chatgpt/utils/prompt.dart';

part 'prompt_event.dart';
part 'prompt_state.dart';

class PromptBloc extends Bloc<PromptEvent, PromptState> {
  PromptBloc() : super(PromptInitial()) {
    on<PromptFetch>((event, emit) async {
      emit(PromptLoading());
      try {
        final List<Prompt> prompts = await getPrompts();
        emit(PromptSuccess(prompts));
      } catch (e) {
        emit(PromptFailed());
      }
    });
  }
}
