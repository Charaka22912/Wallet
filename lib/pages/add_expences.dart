import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:wallet/models/expences.dart';  // Your Isar model for Expenses
import 'package:intl/intl.dart';
import 'home_page.dart';
import 'dashboard.dart';

class addexpence extends StatefulWidget {
  final Isar isar;

  addexpence({required this.isar});

  @override
  _AddExpenseState createState() => _AddExpenseState();
}

class _AddExpenseState extends State<addexpence> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'Food';
  TextEditingController _amountController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final newExpense = Expenses(
        catgory: _selectedCategory,
        description: _noteController.text,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        date: _selectedDate,
      );

      await widget.isar.writeTxn(() async {
        await widget.isar.expenses.put(newExpense);
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Expense saved successfully!'),
      ));

      Navigator.pop(
        context

      );
      // Clear the form
      _amountController.clear();
      _noteController.clear();
      setState(() {
        _selectedCategory = 'Food';
        _selectedDate = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expenses'),
        centerTitle: true,

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 20.0),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(border:OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide:BorderSide(color: Colors.grey,width: 2.0) ),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue,width: 2.0)),
                  labelText: 'Category',
                ),
                items: <String>['Food', 'Transport', 'Entertainment', 'Other']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(border:OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide:BorderSide(color: Colors.grey,width: 2.0) ),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue,width: 2.0)),
                  labelText: 'Amount',
                  suffixText: 'LKR',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _amountController.clear();
                    },
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(border:OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(borderSide:BorderSide(color: Colors.grey,width: 2.0) ),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue,width: 2.0)),
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('EEE, d MMM yyyy').format(_selectedDate)),
                ),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(border:OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide:BorderSide(color: Colors.grey,width: 2.0) ),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue,width: 2.0)),
                  labelText: 'Description',
                ),
                maxLines: null,
              ),
            ],
          ),

        ),
      ),
      floatingActionButton: FloatingActionButton(
      onPressed: _saveExpense,
      child: Icon(Icons.save),
    ),

    );
  }



}

