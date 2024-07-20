import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import 'package:wallet/models/income.dart';

class Income extends StatefulWidget {
  final  Isar isar;

  Income({required this.isar});

  @override
  State<Income> createState() => _IncomeState();
}

class _IncomeState extends State<Income> {
  final _formKey = GlobalKey<FormState>();
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
      final newIncome = Incomes(
        description: _noteController.text,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        date: _selectedDate,
      );

      await widget.isar.writeTxn(() async {
        await widget.isar.incomes.put(newIncome);
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Income saved successfully!'),
      ));

      Navigator.pop(
          context

      );
      // Clear the form
      _amountController.clear();
      _noteController.clear();
      setState(() {
        _selectedDate = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Income'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              InkWell(
                onTap: () => _selectDate(context),
                child: 
                Padding(padding:const EdgeInsets.only(top: 40.0) ,
                child:InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                  ),
                  child: Text(DateFormat('EEE, d MMM yyyy').format(_selectedDate)),
                ),
                ),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration
                  (border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),

                  labelText: 'Description',
                ),
                maxLines: null,
              ),SizedBox(height: 20.0),
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
