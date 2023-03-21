part of 'counter_bloc.dart';

@immutable
abstract class CounterEvent {}

class CounterAddEvent extends CounterEvent {
  CounterAddEvent();
}

class CounterDecEvent extends CounterEvent {
  CounterDecEvent();
}
