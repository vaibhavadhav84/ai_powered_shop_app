import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../datasources/ai_search_remote_data_source.dart';
import '../datasources/image_labeling_local_data_source.dart';
import '../../domain/repositories/image_search_repository.dart';

class ImageSearchRepositoryImpl implements ImageSearchRepository {
  final ImageLabelingLocalDataSource localDataSource;
  final AiSearchRemoteDataSource remoteDataSource;

  ImageSearchRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<String>>> getImageSearchSuggestions(
    String imagePath,
  ) async {
    try {
      // 1. Get labels from ML Kit
      final labels = await localDataSource.getLabelsFromImage(imagePath);

      if (labels.isEmpty) {
        return const Right([]);
      }

      // 2. Convert labels to a search query for Gemini
      final query = labels.take(5).join(", ");

      // 3. Get suggestions from Gemini based on visual labels
      final suggestions = await remoteDataSource.getSearchSuggestions(
        "Products similar to: $query",
      );

      return Right(suggestions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
