import 'package:hive/hive.dart';

part 'product_hive.g.dart';

@HiveType(typeId: 0)
class ProductHive extends HiveObject {
  @HiveField(0)
  late String remoteId;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late double price;

  @HiveField(4)
  late String imageUrl;

  @HiveField(5, defaultValue: true)
  bool isSynced = true;

  @HiveField(6, defaultValue: false)
  bool isDeleted = false;
}
