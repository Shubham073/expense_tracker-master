import 'package:flutter/material.dart';
import '../models/category.dart';
import '../database/category_db.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryDB _db = CategoryDB();
  List<Category> _categories = [];
  List<Category> get categories => _categories;

  void loadCategories() {
    _categories = _db.getCategories();
    notifyListeners();
  }

  Future<void> addCategory(String name) async {
    final cat = Category(name: name, isCustom: true);
    await _db.addCategory(cat);
    loadCategories();
  }

  Future<void> deleteCategory(String name) async {
    await _db.deleteCategory(name);
    loadCategories();
  }

  Future<void> clearAll() async {
    await _db.clearAll();
    _categories.clear();
    notifyListeners();
  }
}
