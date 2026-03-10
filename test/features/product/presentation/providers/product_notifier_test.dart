import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_powered_shopping_app/features/product/domain/entities/product.dart';
import 'package:ai_powered_shopping_app/features/product/domain/usecases/get_products.dart';
import 'package:ai_powered_shopping_app/features/product/presentation/providers/product_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';

class MockGetProducts extends Mock implements GetProducts {}

void main() {
  late MockGetProducts mockGetProducts;
  late ProviderContainer container;

  final tProducts = List.generate(
    10,
    (index) => Product(
      id: '$index',
      name: 'Product $index',
      description: 'Desc $index',
      price: 10.0 + index,
      imageUrl: 'url',
    ),
  );

  setUpAll(() {
    registerFallbackValue(const GetProductsParams(page: 1, limit: 10));
  });

  setUp(() {
    mockGetProducts = MockGetProducts();

    GetIt.instance.allowReassignment = true;
    GetIt.instance.registerSingleton<GetProducts>(mockGetProducts);

    container = ProviderContainer();
  });

  tearDown(() {
    GetIt.instance.reset();
    container.dispose();
  });

  test('should load products and update state to data', () async {
    // arrange
    when(
      () => mockGetProducts(any()),
    ).thenAnswer((_) async => Right(tProducts));

    // wait for the first load (build method)
    await container.read(productListProvider.future);

    // assert
    expect(container.read(productListProvider).value, tProducts);
    verify(
      () => mockGetProducts(const GetProductsParams(page: 1, limit: 10)),
    ).called(1);
  });

  test('should handle loadMore correctly', () async {
    // arrange
    when(
      () => mockGetProducts(any()),
    ).thenAnswer((_) async => Right(tProducts));

    await container.read(productListProvider.future);

    // act
    await container.read(productListProvider.notifier).loadMore();

    // assert
    expect(container.read(productListProvider).value!.length, 20);
    verify(
      () => mockGetProducts(const GetProductsParams(page: 1, limit: 10)),
    ).called(1);
    verify(
      () => mockGetProducts(const GetProductsParams(page: 2, limit: 10)),
    ).called(1);
  });
}
