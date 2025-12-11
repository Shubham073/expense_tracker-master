import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  EditExpenseScreen({required this.expense});

  @override
  _EditExpenseScreenState createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController titleCtrl;
  late TextEditingController amountCtrl;
  late String category;
  DateTime? reminderDateTime;

  @override
  void initState() {
    titleCtrl = TextEditingController(text: widget.expense.title);
    amountCtrl = TextEditingController(text: widget.expense.amount.toString());
    category = widget.expense.category;
  reminderDateTime = widget.expense.reminderDateTime;
  super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Edit Expense")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: titleCtrl, decoration: InputDecoration(labelText: "Title")),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Amount")),
            DropdownButton(
              value: category,
              items: ["Food", "Travel", "Shopping", "Bills"].map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
              onChanged: (value) => setState(() => category = value!),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(reminderDateTime == null
                      ? 'No reminder set'
                      : 'Reminder: ${reminderDateTime!.toLocal()}'),
                ),
                TextButton(
                  child: Text('Set Reminder'),
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: reminderDateTime ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(reminderDateTime ?? DateTime.now()),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          reminderDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Update"),
              onPressed: () async {
                widget.expense.title = titleCtrl.text;
                widget.expense.amount = double.parse(amountCtrl.text);
                widget.expense.category = category;
                widget.expense.reminderDateTime = reminderDateTime;
                await provider.updateExpense(widget.expense);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
