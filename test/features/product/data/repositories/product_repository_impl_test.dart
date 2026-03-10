import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ai_powered_shopping_app/features/product/data/datasources/product_local_data_source.dart';
import 'package:ai_powered_shopping_app/features/product/data/datasources/product_remote_data_source.dart';
import 'package:ai_powered_shopping_app/features/product/data/models/product_model.dart';
import 'package:ai_powered_shopping_app/features/product/data/repositories/product_repository_impl.dart';

class MockRemoteDataSource extends Mock implements ProductRemoteDataSource {}

class MockLocalDataSource extends Mock implements ProductLocalDataSource {}

void main() {
  late ProductRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue(
      const ProductModel(
        id: '0',
        name: '',
        description: '',
        price: 0,
        imageUrl: '',
      ),
    );
  });

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    repository = ProductRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  final tProductModels = [
    const ProductModel(
      id: '1',
      name: 'T-Shirt',
      price: 19.99,
      description: 'Cool shirt',
      imageUrl: 'url',
    ),
  ];

  group('getProducts', () {
    test(
      'should return remote data on cache miss when remote call is successful',
      () async {
        // arrange
        // 1. Initial local check (cache miss)
        when(
          () => mockLocalDataSource.getCachedProducts(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => []);

        // 2. Background sync calls (unsynced products + refresh)
        when(
          () => mockLocalDataSource.getUnsyncedProducts(),
        ).thenAnswer((_) async => []);
        when(
          () => mockRemoteDataSource.getProducts(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => tProductModels);
        when(
          () => mockLocalDataSource.cacheProducts(any()),
        ).thenAnswer((_) async => Future.value());

        // act
        final result = await repository.getProducts(page: 1, limit: 10);

        // assert
        expect(result, Right(tProductModels));
        verify(() => mockLocalDataSource.getCachedProducts(page: 1, limit: 10));
        // Since _syncWithApi is un-awaited, we might not always see its verify calls immediately
        // but the main flow should work.
      },
    );

    test(
      'should return local data instantly when cache is NOT empty',
      () async {
        // arrange
        when(
          () => mockLocalDataSource.getCachedProducts(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => tProductModels);
        when(
          () => mockLocalDataSource.getUnsyncedProducts(),
        ).thenAnswer((_) async => []);

        // Optional background sync mock
        when(
          () => mockRemoteDataSource.getProducts(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => tProductModels);
        when(
          () => mockLocalDataSource.cacheProducts(any()),
        ).thenAnswer((_) async => Future.value());

        // act
        final result = await repository.getProducts(page: 1, limit: 10);

        // assert
        expect(result, Right(tProductModels));
        verify(() => mockLocalDataSource.getCachedProducts(page: 1, limit: 10));
      },
    );
  });
}
