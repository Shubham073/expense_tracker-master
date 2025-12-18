import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 1)
class Expense {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String category;

  @HiveField(5)
  DateTime? reminderDateTime;

  @HiveField(6)
  DateTime spentDate;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  String? userCategory;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.reminderDateTime,
    required this.spentDate,
    this.notes,
    this.userCategory,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'reminderDateTime': reminderDateTime?.toIso8601String(),
      'spentDate': spentDate.toIso8601String(),
      'notes': notes,
      'userCategory': userCategory,
    };
  }
}

