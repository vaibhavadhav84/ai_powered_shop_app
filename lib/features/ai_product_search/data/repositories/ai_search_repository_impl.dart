import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/ai_search_repository.dart';
import '../datasources/ai_search_remote_data_source.dart';

class AiSearchRepositoryImpl implements AiSearchRepository {
  final AiSearchRemoteDataSource remoteDataSource;

  // Ideally inject networking status check here
  final bool isNetworkAvailable = true;

  AiSearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<String>>> getAiSearchSuggestions(
    String query,
  ) async {
    if (!isNetworkAvailable) {
      return const Left(ServerFailure('No internet connection available.'));
    }

    try {
      final suggestions = await remoteDataSource.getSearchSuggestions(query);
      return Right(suggestions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
