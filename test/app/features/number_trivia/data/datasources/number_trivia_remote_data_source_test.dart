import 'dart:convert';

import 'package:clean_architecture_tdd/app/core/error/exception.dart';
import 'package:clean_architecture_tdd/app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_tdd/app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_remote_data_source_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late NumberTriviaRemoteDataSourceImp dataSource;
  late MockClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockClient();
    dataSource = NumberTriviaRemoteDataSourceImp(client: mockHttpClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure404() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('Something went wring', 404));
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel.fromJson(
      jsonDecode(fixture('trivia.json')),
    );

    test(
        'should perform a GET request on a URL with number being the endpoint with application/json header',
        () async {
      // arrange
      setUpMockHttpClientSuccess200();

      // act
      dataSource.getConcreteNumberTrivia(tNumber);

      // assert
      verify(mockHttpClient.get(
        Uri.parse('http://numbersapi.com/$tNumber'),
        headers: {'Content-Type': 'application/json'},
      ));
    });

    test('should return NumberTrivia when the response code is 200 (success)',
        () async {
      // arrange
      when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(
          fixture('trivia.json'),
          200,
        ),
      );

      // act
      final result = await dataSource.getConcreteNumberTrivia(tNumber);

      // assert
      expect(result, equals(tNumberTriviaModel));
    });

    test(
        'should return a ServerException when the response code is 404 or other',
        () async {
      // arrange
      setUpMockHttpClientFailure404();

      // act
      final call = dataSource.getConcreteNumberTrivia;

      // assert
      expect(
          () => call(tNumber), throwsA(const TypeMatcher<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia.json')));

    test(
        'should perform a get request on a URL with *random* endpoint with application/json headers',
        () {
      // arrange
      setUpMockHttpClientSuccess200();

      // act
      dataSource.getRandomNumberTrivia();

      // assert
      verify(
        mockHttpClient.get(
          Uri.parse('http://numbersapi.com/random'),
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
    });

    test('should return NumberTrivia when the response code is 200 (success)',
        () async {
      // arrange
      setUpMockHttpClientSuccess200();

      // act
      final result = await dataSource.getRandomNumberTrivia();

      //assert
      expect(result, equals(tNumberTriviaModel));
    });

    test(
        'should return a ServerException when the response code is 404 or other',
        () async {
      // arrange
      setUpMockHttpClientFailure404();

      // act
      final call = dataSource.getRandomNumberTrivia;

      // assert
      expect(() => call(), throwsA(const TypeMatcher<ServerException>()));
    });
  });
}
