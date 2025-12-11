import 'package:hive/hive.dart';
import '../models/expense.dart';

class HiveDB {
  static final _box = Hive.box<Expense>('expensesBox');

  // Create
  Future<void> addExpense(Expense expense) async {
    await _box.put(expense.id, expense);
  }

  // Read
  List<Expense> getExpenses() {
    return _box.values.toList();
  }

  // Update
  Future<void> updateExpense(Expense expense) async {
    await _box.put(expense.id, expense);
  }

  // Delete
  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
  }

  // Clear All
  Future<void> clearAll() async {
    await _box.clear();
  }
}
