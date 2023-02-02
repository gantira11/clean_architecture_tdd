// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:clean_architecture_tdd/app/core/error/failures.dart';
import 'package:clean_architecture_tdd/app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/presentation/utils/input_converter.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/usecases/get_concrete_number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid input - The number must be positive or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia concrete;
  final GetRandomNumberTrivia random;
  final InputConverter inputConverter;

  NumberTriviaState get initialState => Empty();

  NumberTriviaBloc({
    required this.concrete,
    required this.random,
    required this.inputConverter,
  }) : super(Empty()) {
    on<GetTriviaForConcreteNumber>(onGetTriviaForConcreteNumber);
    on<GetTriviaForRandomNumber>(onGetRandomForRandomTrivia);
  }

  FutureOr<void> onGetTriviaForConcreteNumber(
      GetTriviaForConcreteNumber event, Emitter<NumberTriviaState> emit) async {
    final inputEither =
        inputConverter.stringToUnsignedInteger(event.numberTrivia);

    await inputEither.fold(
      (failure) async => emit(
        const Error(message: INVALID_INPUT_FAILURE_MESSAGE),
      ),
      (integer) async {
        emit(Loading());
        final failureOrTrivia = await concrete(Params(integer));

        failureOrTrivia.fold(
          (failure) => emit(Error(message: _mapFailureToMessage(failure))),
          (numberTrivia) => emit(Loaded(trivia: numberTrivia)),
        );
      },
    );
  }

  Future<FutureOr<void>> onGetRandomForRandomTrivia(
    GetTriviaForRandomNumber event,
    Emitter<NumberTriviaState> emit,
  ) async {
    emit(Loading());
    final failureOrTrivia = await random(NoParams());

    emit(failureOrTrivia.fold(
      (failure) => Error(message: _mapFailureToMessage(failure)),
      (numberTrivia) => Loaded(trivia: numberTrivia),
    ));
  }
}

String _mapFailureToMessage(Failure failure) {
  switch (failure.runtimeType) {
    case ServerFailure:
      return SERVER_FAILURE_MESSAGE;
    case CacheFailure:
      return CACHE_FAILURE_MESSAGE;
    default:
      return 'Unexcepted Error';
  }
}
