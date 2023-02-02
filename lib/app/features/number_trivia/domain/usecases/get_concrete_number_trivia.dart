import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/number_trivia.dart';
import '../repositories/number_trivia_repository.dart';

class GetConcreteNumberTrivia extends UseCase<NumberTrivia, Params> {
  GetConcreteNumberTrivia(this.repository);

  final NumberTriviaRepository repository;

  Future<Either<Failure, NumberTrivia>> execute({required int number}) async {
    return await repository.getConcreteNumberTrivia(number);
  }

  @override
  Future<Either<Failure, NumberTrivia>> call(params) async {
    return await repository.getConcreteNumberTrivia(params.number);
  }
}

class Params extends Equatable {
  const Params(this.number);

  final int number;

  @override
  List<Object?> get props => [number];
}
