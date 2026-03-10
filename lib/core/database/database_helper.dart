import 'package:hive_flutter/hive_flutter.dart';
import '../../features/product/data/models/product_hive.dart';

class DatabaseHelper {
  static Future<void> initDatabase() async {
    await Hive.initFlutter();

    // Register Adapters here
    Hive.registerAdapter(ProductHiveAdapter());

    // Open lazy boxes or standard boxes
    await Hive.openBox<ProductHive>('products');
  }
}
