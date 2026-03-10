import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class AiSearchRepository {
  /// Takes a raw string query and asks the AI to predict an array of relevant product categories, names, or concepts.
  Future<Either<Failure, List<String>>> getAiSearchSuggestions(String query);
}
