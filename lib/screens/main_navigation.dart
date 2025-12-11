import 'package:expense_tracker/screens/budget/budget_screen.dart';
import 'package:expense_tracker/screens/expenses/expenses_screen.dart';
import 'package:expense_tracker/screens/profile/profile_screen.dart';
import 'package:expense_tracker/screens/posts_screen.dart';
import 'package:flutter/material.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  final List<Widget> _screens = [
    ExpensesScreen(),
    BudgetScreen(),
    ProfileScreen(),
    // const PostsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index < _screens.length ? _index : 0],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) {
          setState(() => _index = value);
        },
        selectedItemColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.blue,
        unselectedItemColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[700],
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Expenses",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: "Budget",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.article),
          //   label: "Posts",
          // ),
        ],
      ),
    );
  }
}
