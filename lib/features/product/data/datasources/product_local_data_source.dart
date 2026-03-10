import 'package:hive/hive.dart';
import '../models/product_hive.dart';
import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getCachedProducts({
    required int page,
    required int limit,
  });
  Future<List<ProductModel>> getUnsyncedProducts();
  Future<void> cacheProducts(List<ProductModel> products);
  Future<void> saveLocalProduct(ProductModel product, {bool isSynced = false});
  Future<void> markAsSynced(String remoteId);
  Future<void> deleteProduct(String remoteId);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final Box<ProductHive> productBox;

  ProductLocalDataSourceImpl({required this.productBox});

  @override
  Future<List<ProductModel>> getCachedProducts({
    required int page,
    required int limit,
  }) async {
    // Return all active products mapped to Domain Model (excluding soft-deletes) with Pagination
    final offset = (page - 1) * limit;
    final productsHive = productBox.values
        .where((p) => !p.isDeleted)
        .skip(offset)
        .take(limit)
        .toList();
    return productsHive.map(_mapToModel).toList();
  }

  @override
  Future<List<ProductModel>> getUnsyncedProducts() async {
    // Find offline-modified products waiting to be pushed
    final productsHive = productBox.values.where((p) => !p.isSynced).toList();
    return productsHive.map(_mapToModel).toList();
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final Map<String, ProductHive> hiveMap = {};
    for (var p in products) {
      hiveMap[p.id] = ProductHive()
        ..remoteId = p.id
        ..name = p.name
        ..description = p.description
        ..price = p.price
        ..imageUrl = p.imageUrl
        ..isSynced = true
        ..isDeleted = false;
    }
    await productBox.putAll(hiveMap);
  }

  @override
  Future<void> saveLocalProduct(
    ProductModel product, {
    bool isSynced = false,
  }) async {
    final hiveRecord = ProductHive()
      ..remoteId = product.id
      ..name = product.name
      ..description = product.description
      ..price = product.price
      ..imageUrl = product.imageUrl
      ..isSynced = isSynced;

    await productBox.put(product.id, hiveRecord);
  }

  @override
  Future<void> markAsSynced(String remoteId) async {
    final record = productBox.get(remoteId);
    if (record != null) {
      record.isSynced = true;
      await record.save();
    }
  }

  @override
  Future<void> deleteProduct(String remoteId) async {
    final record = productBox.get(remoteId);
    if (record != null) {
      // Soft-delete: We mark it deleted so UI doesn't show it, but it waits until API sync
      record.isDeleted = true;
      record.isSynced = false;
      await record.save();
    }
  }

  ProductModel _mapToModel(ProductHive p) {
    return ProductModel(
      id: p.remoteId,
      name: p.name,
      description: p.description,
      price: p.price,
      imageUrl: p.imageUrl,
    );
  }
}
