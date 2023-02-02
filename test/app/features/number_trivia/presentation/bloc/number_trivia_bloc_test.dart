import 'package:clean_architecture_tdd/app/core/error/failures.dart';
import 'package:clean_architecture_tdd/app/core/presentation/utils/input_converter.dart';
import 'package:clean_architecture_tdd/app/core/usecases/usecase.dart';
import 'package:clean_architecture_tdd/app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_tdd/app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd/app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_tdd/app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_tdd/app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<GetConcreteNumberTrivia>(as: #MockGetConcreteNumberTrivia),
  MockSpec<GetRandomNumberTrivia>(as: #MockGetRandomNumberTrivia),
  MockSpec<InputConverter>(as: #MockInputConverter),
])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      concrete: mockGetConcreteNumberTrivia,
      random: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  test('initial state should be Empty', () {
    // assert
    expect(bloc.initialState, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    const tNumberString = '1';
    final tNumberParsed = int.parse(tNumberString);
    const tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    setUpMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Right(tNumberParsed));

    test(
        'should call the InputConverter to validate and convert the string to an unsigned integer',
        () async {
      // arrange
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(Right(tNumberParsed));
      when(mockGetConcreteNumberTrivia.call(any))
          .thenAnswer((_) async => const Right(tNumberTrivia));

      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockInputConverter.stringToUnsignedInteger(any));

      // assert
      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
    });

    test('should emit [error] when the input is invalid', () async {
      // arrange
      when(mockInputConverter.stringToUnsignedInteger(tNumberString))
          .thenReturn(Left(InvalidInputFailure()));

      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockInputConverter.stringToUnsignedInteger(any));

      // assert
      expect(
        bloc.state,
        equals(const Error(message: INVALID_INPUT_FAILURE_MESSAGE)),
      );
    });

    test('should get data from the concrete use case', () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => const Right(tNumberTrivia));

      //act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockGetConcreteNumberTrivia(any));

      // assert
      verify(mockGetConcreteNumberTrivia(Params(tNumberParsed)));
    });

    test('should emit [loaded] when data is gotten successfuly', () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia.call(Params(tNumberParsed)))
          .thenAnswer((_) async => const Right(tNumberTrivia));

      // act
      await untilCalled(
          bloc.add(const GetTriviaForConcreteNumber(tNumberString)));
      await untilCalled(
          mockInputConverter.stringToUnsignedInteger(tNumberString));

      // assert
      expect(bloc.state, equals(const Loaded(trivia: tNumberTrivia)));
    });

    test('should emit [error] when getting data fails', () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia.call(any))
          .thenAnswer((_) async => Left(ServerFailure()));

      // act
      await untilCalled(
        bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      );
      await untilCalled(
        mockInputConverter.stringToUnsignedInteger(tNumberString),
      );

      // assert
      expect(bloc.state, equals(const Error(message: SERVER_FAILURE_MESSAGE)));
    });
  });

  group('GetRandomNumberTrivia', () {
    const tNumberTrivia = NumberTriviaModel(text: 'test trivia', number: 1);

    test('should get data from the random use case', () async {
      // arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => const Right(tNumberTrivia));

      // act
      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(mockGetRandomNumberTrivia(any));

      // assert
      verify(mockGetRandomNumberTrivia(NoParams()));
    });

    test('should emit [loaded] when data is gotten successfuly', () async {
      // arrange
      when(mockGetRandomNumberTrivia(any)).thenAnswer(
        (_) async => const Right(tNumberTrivia),
      );

      // act
      await untilCalled(bloc.add(GetTriviaForRandomNumber()));
      await untilCalled(mockGetRandomNumberTrivia(any));

      // assert
      expect(bloc.state, equals(const Loaded(trivia: tNumberTrivia)));
    });

    test('should emit [error] when gettin data fails', () async {
      // arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));

      // act
      await untilCalled(bloc.add(GetTriviaForRandomNumber()));
      await untilCalled(mockGetRandomNumberTrivia(any));

      // assert
      expect(
        bloc.state,
        equals(const Error(message: SERVER_FAILURE_MESSAGE)),
      );
    });
  });
}
