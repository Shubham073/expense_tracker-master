import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
class Category {
  @HiveField(0)
  String name;
  @HiveField(1)
  bool isCustom;

  Category({required this.name, this.isCustom = false});
}
