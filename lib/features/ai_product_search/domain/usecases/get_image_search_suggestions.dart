import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/image_search_repository.dart';
import 'package:equatable/equatable.dart';

class GetImageSearchSuggestions
    implements UseCase<List<String>, ImageSearchParams> {
  final ImageSearchRepository repository;

  GetImageSearchSuggestions(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(ImageSearchParams params) async {
    return await repository.getImageSearchSuggestions(params.imagePath);
  }
}

class ImageSearchParams extends Equatable {
  final String imagePath;

  const ImageSearchParams({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}
