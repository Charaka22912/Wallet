import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:wallet/models/income.dart';

import '../models/expences.dart';

class ExpensesDetailsScreen extends StatefulWidget {
  final Isar isar;

  ExpensesDetailsScreen({required this.isar});

  @override
  _ExpensesDetailsScreenState createState() => _ExpensesDetailsScreenState();
}

class _ExpensesDetailsScreenState extends State<ExpensesDetailsScreen> {
  Future<Map<String, List>> _fetchData() async {
    final expenses = await widget.isar.expenses.where().findAll();
    final incomes = await widget.isar.incomes.where().findAll();
    return {'expenses': expenses, 'incomes': incomes};
  }

  _updateExpense(Expenses expense) async {
    final descriptionController = TextEditingController(text: expense.description);
    final amountController = TextEditingController(text: expense.amount.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                expense.description = descriptionController.text;
                expense.amount = double.parse(amountController.text);

                await widget.isar.writeTxn(() async {
                  await widget.isar.expenses.put(expense);
                });

                Navigator.of(context).pop();
                setState(() {}); // Refresh the list
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  _updateIncome(Incomes income) async {
    final descriptionController = TextEditingController(text: income.description);
    final amountController = TextEditingController(text: income.amount.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Income'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                income.description = descriptionController.text;
                income.amount = double.parse(amountController.text);

                await widget.isar.writeTxn(() async {
                  await widget.isar.incomes.put(income);
                });

                Navigator.of(context).pop();
                setState(() {});
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  _deleteExpense(Expenses expense) async {
    await widget.isar.writeTxn(() async {
      await widget.isar.expenses.delete(expense.id);
    });

    setState(() {});
  }

  _deleteIncome(Incomes income) async {
    await widget.isar.writeTxn(() async {
      await widget.isar.incomes.delete(income.id);
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary'),
      ),
      body: FutureBuilder<Map<String, List>>(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || (snapshot.data!['expenses']!.isEmpty && snapshot.data!['incomes']!.isEmpty)) {
            return Center(child: Text('No expenses or incomes found.'));
          } else {
            final expenses = snapshot.data!['expenses'] as List<Expenses>;
            final incomes = snapshot.data!['incomes'] as List<Incomes>;
            final combined = [...expenses, ...incomes];

            return ListView.builder(
              itemCount: combined.length,
              itemBuilder: (context, index) {
                final item = combined[index];
                if (item is Expenses) {
                  return ListTile(
                    title: Text(item.description, style: TextStyle(color: Colors.red)),
                    subtitle: Text('Amount: ${item.amount.toString()} LKR\nDate: ${item.date.toLocal().toString().split(' ')[0]}', style: TextStyle(color: Colors.red)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.red),
                          onPressed: () => _updateExpense(item),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteExpense(item),
                        ),
                      ],
                    ),
                  );
                } else if (item is Incomes) {
                  return ListTile(
                    title: Text(item.description, style: TextStyle(color: Colors.blue)),
                    subtitle: Text('Amount: ${item.amount.toString()} LKR\nDate: ${item.date.toLocal().toString().split(' ')[0]}', style: TextStyle(color: Colors.blue)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _updateIncome(item),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.blue),
                          onPressed: () => _deleteIncome(item),
                        ),
                      ],
                    ),
                  );
                }
                return Container();
              },
            );
          }
        },
      ),
    );
  }
}
