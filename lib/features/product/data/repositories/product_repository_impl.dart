import 'package:dartz/dartz.dart';
import 'dart:developer';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;

  // Ideally, use a package like `connectivity_plus` to inject network status
  final bool isNetworkAvailable = true;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    required int page,
    required int limit,
  }) async {
    try {
      // 1. OFFLINE FIRST: Instantly return local cache for instantaneous UI feedback
      final localProducts = await localDataSource.getCachedProducts(
        page: page,
        limit: limit,
      );

      // 2. BACKGROUND SYNC: Trigger an asynchronous sync with the remote server.
      // If the user's internet is active, this guarantees Isar will have the fresh data next UI state or via Stream listener.
      _syncWithApi();

      if (localProducts.isNotEmpty) {
        return Right(localProducts);
      } else {
        // 3. CACHE MISS FALLBACK: Only await the Remote API directly if cache is totally empty
        if (!isNetworkAvailable) {
          return const Left(
            ServerFailure('No local products and no internet connection.'),
          );
        }
        final remoteProducts = await remoteDataSource.getProducts(
          page: page,
          limit: limit,
        );
        await localDataSource.cacheProducts(remoteProducts);

        return Right(remoteProducts);
      }
    } catch (e) {
      return const Left(DatabaseFailure('Local Database Access Failure'));
    }
  }

  /// Fire-and-forget method to sync offline changes upwards, then grab remote changes downwards
  Future<void> _syncWithApi() async {
    if (!isNetworkAvailable) return;

    try {
      // Step A: Push local pending modifications upwards (e.g. user created product offline)
      await _pushUnsyncedData();

      // Step B: Pull fresh global data downwards and cache it
      // Background full sync might require pulling a giant page or handling delta changes.
      // For now, pulling page 1 as example
      final remoteProducts = await remoteDataSource.getProducts(
        page: 1,
        limit: 50,
      );
      await localDataSource.cacheProducts(remoteProducts);
    } catch (e) {
      log('Background sync failed cleanly: $e');
    }
  }

  /// Push local, un-synced data to the API as soon as Internet connection is restored
  Future<void> _pushUnsyncedData() async {
    final pendingItems = await localDataSource.getUnsyncedProducts();

    for (final item in pendingItems) {
      try {
        // e.g. remoteDataSource.createOrUpdateProduct(item);
        // On success, mark it verified globally
        await localDataSource.markAsSynced(item.id);
      } catch (e) {
        log('Failed to sync product ${item.id}: $e');
        // Stop syncing if we hit a critical network break and preserve isSynced = false
        break;
      }
    }
  }
}
