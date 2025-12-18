import 'package:hive/hive.dart';
import '../models/category.dart';

class CategoryDB {
  static final _box = Hive.box<Category>('categoriesBox');

  Future<void> addCategory(Category category) async {
    await _box.put(category.name, category);
  }

  List<Category> getCategories() {
    return _box.values.toList();
  }

  Future<void> deleteCategory(String name) async {
    await _box.delete(name);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
