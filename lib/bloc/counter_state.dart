part of 'counter_bloc.dart';

enum CounterStates { initial, loading, success, failure }

class CounterState extends Equatable {
  final int count;
  final CounterStates states;

  const CounterState(this.count, this.states);

  @override
  List<Object> get props => [count, states];
}
