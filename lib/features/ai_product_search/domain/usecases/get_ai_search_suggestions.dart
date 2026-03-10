import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/ai_search_repository.dart';
import 'package:equatable/equatable.dart';

class GetAiSearchSuggestions implements UseCase<List<String>, SearchParams> {
  final AiSearchRepository repository;

  GetAiSearchSuggestions(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(SearchParams params) async {
    return await repository.getAiSearchSuggestions(params.query);
  }
}

class SearchParams extends Equatable {
  final String query;

  const SearchParams({required this.query});

  @override
  List<Object?> get props => [query];
}
