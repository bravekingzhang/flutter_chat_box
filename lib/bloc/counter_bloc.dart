import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'counter_event.dart';
part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState(0, CounterStates.initial)) {
    on<CounterAddEvent>((event, emit) async {
      emit(CounterState(state.count, CounterStates.loading));
      await Future.delayed(const Duration(milliseconds: 1000));
      emit(CounterState(state.count + 1, CounterStates.success));
    });

    on<CounterDecEvent>((event, emit) async {
      emit(CounterState(state.count, CounterStates.loading));
      await Future.delayed(const Duration(milliseconds: 1000));
      emit(CounterState(state.count - 1, CounterStates.success));
    });
  }
}
