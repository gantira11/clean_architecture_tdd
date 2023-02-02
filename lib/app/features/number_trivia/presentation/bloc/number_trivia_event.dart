part of 'number_trivia_bloc.dart';

abstract class NumberTriviaEvent extends Equatable {
  const NumberTriviaEvent();

  @override
  List<Object> get props => [];
}

class GetTriviaForConcreteNumber extends NumberTriviaEvent {
  const GetTriviaForConcreteNumber(this.numberTrivia);

  final String numberTrivia;

  @override
  List<Object> get props => [numberTrivia];
}

class GetTriviaForRandomNumber extends NumberTriviaEvent {}
