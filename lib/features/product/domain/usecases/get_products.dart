import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProducts implements UseCase<List<Product>, GetProductsParams> {
  final ProductRepository repository;

  GetProducts(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(GetProductsParams params) async {
    return await repository.getProducts(page: params.page, limit: params.limit);
  }
}

class GetProductsParams extends Equatable {
  final int page;
  final int limit;

  const GetProductsParams({required this.page, required this.limit});

  @override
  List<Object?> get props => [page, limit];
}
