import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../database/hive_db.dart';
import '../core/notifications.dart';

class ExpenseProvider with ChangeNotifier {
  final HiveDB _db = HiveDB();
  final uuid = Uuid();

  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  // Load from DB
  void loadExpenses() {
    _expenses = _db.getExpenses();
    notifyListeners();
  }

  // Add
  Future<void> addExpense(
    String title,
    double amount,
    String category,
    [DateTime? reminderDateTime,
    DateTime? spentDate,
    String? notes,
    String? userCategory]
  ) async {
    Expense exp = Expense(
      id: uuid.v4(),
      title: title,
      amount: amount,
      category: category,
      date: DateTime.now(),
      reminderDateTime: reminderDateTime,
      spentDate: spentDate ?? DateTime.now(),
      notes: notes,
      userCategory: userCategory,
    );

    await _db.addExpense(exp);
    // Show notification for add
    await NotificationService.showInstantNotification(
      title: 'Expense Added',
      body: 'Expense "${exp.title}" added.',
      id: exp.hashCode,
    );
    // Schedule reminder notification if set
    if (reminderDateTime != null) {
      await NotificationService.scheduleNotification(
        id: exp.hashCode,
        title: 'Expense Reminder',
        body: 'Reminder for expense "${exp.title}".',
        scheduledTime: reminderDateTime,
      );
    }
    loadExpenses();
  }

  // Update
  Future<void> updateExpense(Expense expense) async {
    await _db.updateExpense(expense);
    // Show notification for edit
    await NotificationService.showInstantNotification(
      title: 'Expense Updated',
      body: 'Expense "${expense.title}" updated.',
      id: expense.hashCode,
    );
    // Schedule reminder notification if set
    if (expense.reminderDateTime != null) {
      await NotificationService.scheduleNotification(
        id: expense.hashCode,
        title: 'Expense Reminder',
        body: 'Reminder for expense "${expense.title}".',
        scheduledTime: expense.reminderDateTime!,
      );
    }
    loadExpenses();
  }

  // Delete
  Future<void> deleteExpense(String id) async {
    await _db.deleteExpense(id);
    loadExpenses();
  }

  Future<void> clearAll() async {
    await _db.clearAll(); // call method from HiveDB
    _expenses.clear();
    notifyListeners();
  }
}
