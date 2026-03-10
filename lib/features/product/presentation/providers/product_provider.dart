import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products.dart';

/// Riverpod Provider wrapping our GetIt UseCase
final getProductsUseCaseProvider = Provider<GetProducts>((ref) {
  return sl<GetProducts>(); // Fetched from GetIt Injection Container
});

/// Riverpod AsyncNotifier for modern AsyncValue states
class ProductListNotifier extends AsyncNotifier<List<Product>> {
  int _page = 1;
  final int _limit = 10;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<Product>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchProducts(page: _page);
  }

  Future<List<Product>> _fetchProducts({required int page}) async {
    final useCase = ref.read(getProductsUseCaseProvider);
    final result = await useCase(GetProductsParams(page: page, limit: _limit));

    return result.fold(
      (failure) => throw failure.message, // Caught by AsyncValue.error
      (products) {
        if (products.length < _limit) {
          _hasMore = false;
        }
        return products;
      },
    );
  }

  /// Expose method for manual refresh (Pull to Refresh)
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    _page = 1;
    _hasMore = true;
    try {
      final products = await _fetchProducts(page: _page);
      state = AsyncValue.data(products);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Expose method for infinite scrolling pagination
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || state.hasError) return;

    _isLoadingMore = true;

    try {
      final nextPage = _page + 1;
      final newProducts = await _fetchProducts(page: nextPage);

      _page = nextPage;
      final currentList = state.value ?? [];

      state = AsyncValue.data([...currentList, ...newProducts]);
    } catch (e) {
      // Just log or handle load-more specific errors, to avoid wiping out the whole list
      // with a top-level error state.
    } finally {
      _isLoadingMore = false;
    }
  }
}

/// The final State Provider to be consumed by the UI
final productListProvider =
    AsyncNotifierProvider<ProductListNotifier, List<Product>>(() {
      return ProductListNotifier();
    });
