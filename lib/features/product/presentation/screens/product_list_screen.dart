import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/product_provider.dart';

import '../widgets/product_list_item.dart';

// Helper to avoid conflicting scopes
void navigateToSearch(BuildContext context) {
  context.push('/search');
}

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuild when the list configuration changes
    final productState = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(productListProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          navigateToSearch(context);
        },
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Ask AI'),
        backgroundColor: Colors.purple.shade100,
      ),
      body: productState.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
                ref.read(productListProvider.notifier).loadMore();
              }
              return false;
            },
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(productListProvider.notifier).refresh();
              },
              child: ListView.builder(
                itemCount: products.length + 1,
                // cacheExtent: 1000, // Optional: pre-render items
                itemBuilder: (context, index) {
                  if (index == products.length) {
                    final hasMore = ref.watch(
                      productListProvider.notifier.select((n) => n.hasMore),
                    );
                    if (!hasMore && products.isNotEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('No more products')),
                      );
                    }
                    return const SizedBox.shrink();
                  }

                  final product = products[index];
                  return ProductListItem(
                    product: product,
                    onTap: () {
                      context.go('/home/product/${product.id}');
                    },
                  );
                },
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(productListProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
