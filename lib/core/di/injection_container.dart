import 'package:get_it/get_it.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../network/dio_client.dart';
import 'package:hive/hive.dart';
import '../../features/product/data/models/product_hive.dart';
import '../../features/product/data/datasources/product_local_data_source.dart';
import '../../features/product/data/datasources/product_remote_data_source.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/get_products.dart';

import '../../features/ai_product_search/data/datasources/ai_search_remote_data_source.dart';
import '../../features/ai_product_search/data/repositories/ai_search_repository_impl.dart';
import '../../features/ai_product_search/domain/repositories/ai_search_repository.dart';
import '../../features/ai_product_search/domain/repositories/image_search_repository.dart';
import '../../features/ai_product_search/domain/usecases/get_ai_search_suggestions.dart';
import '../../features/ai_product_search/domain/usecases/get_image_search_suggestions.dart';
import '../../features/ai_product_search/data/datasources/image_labeling_local_data_source.dart';
import '../../features/ai_product_search/data/repositories/image_search_repository_impl.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ---------------------------------------------------------------------------
  // Core: Network & Third-Party SDKs
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // Configure Gemini Model (In production, load this from dotenv!)
  const geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyDkF3gfshL1CxcM6WdAocmQECQ0kGfWCIE',
  );
  sl.registerLazySingleton<GenerativeModel>(
    () =>
        GenerativeModel(model: 'gemini-3-flash-preview', apiKey: geminiApiKey),
  );

  sl.registerLazySingleton<ImageLabeler>(
    () => ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5)),
  );

  // ---------------------------------------------------------------------------
  // Data sources
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(client: sl<DioClient>()),
  );

  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(
      productBox: Hive.box<ProductHive>('products'),
    ),
  );

  sl.registerLazySingleton<AiSearchRemoteDataSource>(
    () => AiSearchRemoteDataSourceImpl(generativeModel: sl<GenerativeModel>()),
  );

  sl.registerLazySingleton<ImageLabelingLocalDataSource>(
    () => ImageLabelingLocalDataSourceImpl(imageLabeler: sl()),
  );

  // ---------------------------------------------------------------------------
  // Repositories
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  sl.registerLazySingleton<AiSearchRepository>(
    () => AiSearchRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ImageSearchRepository>(
    () => ImageSearchRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Use cases
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => GetAiSearchSuggestions(sl()));
  sl.registerLazySingleton(() => GetImageSearchSuggestions(sl()));
}
