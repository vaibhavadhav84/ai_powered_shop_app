import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/usecases/get_ai_search_suggestions.dart';
import '../../domain/usecases/get_image_search_suggestions.dart';

/// Exposes the specific use case
final getAiSearchUseCaseProvider = Provider<GetAiSearchSuggestions>((ref) {
  return sl<GetAiSearchSuggestions>();
});

final getImageSearchUseCaseProvider = Provider<GetImageSearchSuggestions>((
  ref,
) {
  return sl<GetImageSearchSuggestions>();
});

/// Riverpod class handling the state of search query and suggestions
class AiSearchNotifier extends AsyncNotifier<List<String>> {
  Timer? _debounceTimer;
  String _currentQuery = '';
  String? _currentImagePath;

  String? get currentImagePath => _currentImagePath;

  @override
  Future<List<String>> build() async {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return [];
  }

  /// Called from the UI when user types
  void onSearchChanged(String query) {
    if (_currentQuery == query) return;
    _currentQuery = query;

    // Reset list if input is empty immediately
    if (query.trim().isEmpty) {
      _debounceTimer?.cancel();
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    // Prevent spamming the AI API - Debounce 500ms
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    final useCase = ref.read(getAiSearchUseCaseProvider);
    final result = await useCase(SearchParams(query: query));

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (suggestions) {
        state = AsyncValue.data(suggestions);
      },
    );
  }

  Future<void> onImageCaptured(String imagePath) async {
    _currentImagePath = imagePath;
    _currentQuery = '';
    state = const AsyncValue.loading();

    final useCase = ref.read(getImageSearchUseCaseProvider);
    final result = await useCase(ImageSearchParams(imagePath: imagePath));

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (suggestions) {
        state = AsyncValue.data(suggestions);
      },
    );
  }

  void clearImage() {
    _currentImagePath = null;
    state = const AsyncValue.data([]);
  }

  // Dispose logic handled via ref.onDispose in build()
}

final aiSearchProvider = AsyncNotifierProvider<AiSearchNotifier, List<String>>(
  () {
    return AiSearchNotifier();
  },
);
