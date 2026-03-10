import '../models/product_model.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/error/network_exception_handler.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    required int page,
    required int limit,
  });
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient client;

  ProductRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ProductModel>> getProducts({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await client.dio.get(
        '', // baseUrl already contains /products
        queryParameters: {'limit': limit}, // Fake Store API supports ?limit=N
      );

      if (response.statusCode == 200) {
        // Offload heavy JSON parsing to a background isolate
        return await compute(_parseProducts, response.data);
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw NetworkExceptionHandler.handleException(e);
    }
  }
}

// Top-level function for isolate parsing
List<ProductModel> _parseProducts(dynamic data) {
  final List<dynamic> jsonList = data;
  return jsonList.map((json) => ProductModel.fromJson(json)).toList();
}
