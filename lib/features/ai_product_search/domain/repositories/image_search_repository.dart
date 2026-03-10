import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class ImageSearchRepository {
  Future<Either<Failure, List<String>>> getImageSearchSuggestions(
    String imagePath,
  );
}
