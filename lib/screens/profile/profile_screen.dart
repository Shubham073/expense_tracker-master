import 'dart:convert';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // USER INFO
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: const Icon(Icons.person, size: 45),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Shubham Bhalekar",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "shubham.bhalekar@xoriant.com",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            "Settings",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 12),

          // THEME MODE
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: Provider.of<ThemeProvider>(context).isDarkMode,
            onChanged: (val) {
              Provider.of<ThemeProvider>(
                context,
                listen: false,
              ).toggleTheme(val);
            },
          ),

          const SizedBox(height: 20),

          const Text(
            "Data",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 12),

          // EXPORT JSON
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text("Export Expenses (JSON)"),
            onTap: () {
              final dataJson = jsonEncode(
                provider.expenses.map((e) => e.toMap()).toList(),
              );

              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Exported JSON"),
                  content: SingleChildScrollView(child: Text(dataJson)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              );
            },
          ),

          // CLEAR ALL EXPENSES
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              "Clear All Expenses",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              final confirm = await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Confirm"),
                  content: const Text(
                    "Are you sure you want to delete all expenses?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await provider.clearAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("All expenses deleted")),
                  );
                }
              }
            },
          ),

          const SizedBox(height: 30),

          // FOOTER
          Center(
            child: Text(
              "Expense Tracker v1.0.0",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
