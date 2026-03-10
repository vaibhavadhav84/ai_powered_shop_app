import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ai_powered_shopping_app/features/product/domain/entities/product.dart';
import 'package:ai_powered_shopping_app/features/product/domain/usecases/get_products.dart';
import 'package:ai_powered_shopping_app/features/product/presentation/screens/product_list_screen.dart';
import 'package:ai_powered_shopping_app/features/product/presentation/providers/product_provider.dart';
import 'package:dartz/dartz.dart';

class MockGetProducts extends Mock implements GetProducts {}

Widget createProductListScreen(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: ProductListScreen()),
  );
}

void main() {
  late MockGetProducts mockGetProducts;

  final tProducts = [
    const Product(
      id: '1',
      name: 'Test Product',
      description: 'Test Description',
      price: 99.99,
      imageUrl: 'https://example.com/image.png',
    ),
  ];

  setUpAll(() {
    registerFallbackValue(const GetProductsParams(page: 1, limit: 10));
  });

  setUp(() {
    mockGetProducts = MockGetProducts();
  });

  testWidgets('should render product list items when data is available', (
    tester,
  ) async {
    // arrange
    when(
      () => mockGetProducts(any()),
    ).thenAnswer((_) async => Right(tProducts));

    final container = ProviderContainer(
      overrides: [
        getProductsUseCaseProvider.overrideWithValue(mockGetProducts),
      ],
    );

    // act
    await tester.pumpWidget(createProductListScreen(container));

    // The build() method of AsyncNotifier is triggered on first read
    // We need to pump until loading is finished.
    await tester.pump(); // Start building
    await tester.pump(); // Process the future

    // assert
    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('\$99.99'), findsOneWidget);
  });

  testWidgets('should show snackbar when Add to Cart is pressed', (
    tester,
  ) async {
    // arrange
    when(
      () => mockGetProducts(any()),
    ).thenAnswer((_) async => Right(tProducts));

    final container = ProviderContainer(
      overrides: [
        getProductsUseCaseProvider.overrideWithValue(mockGetProducts),
      ],
    );

    await tester.pumpWidget(createProductListScreen(container));
    await tester.pump(); // Build
    await tester.pump(); // Data available

    final addToCartButton = find.byIcon(Icons.add_shopping_cart);
    expect(addToCartButton, findsOneWidget);

    // act
    await tester.tap(addToCartButton);
    await tester.pump(); // Trigger SnackBar

    // assert
    expect(find.text('Test Product added to cart'), findsOneWidget);
  });
}
