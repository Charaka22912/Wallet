import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:wallet/pages/add_income.dart';
import '../models/income.dart';
import 'add_expences.dart';
import 'package:isar/isar.dart';
import 'package:wallet/models/personal.dart';
import 'package:wallet/models/expences.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  final String nickname;
  final Isar isar;

  DashboardScreen({required this.nickname, required this.isar});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, double> dataMap = {};
  StreamSubscription<void>? expensesSubscription;
  String _selectedFilter = 'Daily';
  double totalExpenses = 0;
  double totalIncome = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _setupListener();
  }

  void _setupListener() {
    expensesSubscription = widget.isar.expenses.watchLazy().listen((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final expenses = await widget.isar.expenses.where().findAll();
    final incomes = await widget.isar.incomes.where().findAll();
    final Map<String, double> totals = {};
    DateTime now = DateTime.now();

    totalExpenses = 0;
    totalIncome = 0;

    for (var expense in expenses) {
      bool shouldInclude = false;
      switch (_selectedFilter) {
        case 'Daily':
          shouldInclude = expense.date.year == now.year && expense.date.month == now.month && expense.date.day == now.day;
          break;
        case 'Monthly':
          shouldInclude = expense.date.year == now.year && expense.date.month == now.month;
          break;
        case 'Yearly':
          shouldInclude = expense.date.year == now.year;
          break;
      }
      if (shouldInclude) {
        if (totals.containsKey(expense.catgory)) {
          totals[expense.catgory] = totals[expense.catgory]! + expense.amount;
        } else {
          totals[expense.catgory] = expense.amount;
        }
        totalExpenses += expense.amount;
      }
    }

    for (var income in incomes) {
      bool shouldInclude = false;
      switch (_selectedFilter) {
        case 'Daily':
          shouldInclude = income.date.year == now.year && income.date.month == now.month && income.date.day == now.day;
          break;
        case 'Monthly':
          shouldInclude = income.date.year == now.year && income.date.month == now.month;
          break;
        case 'Yearly':
          shouldInclude = income.date.year == now.year;
          break;
      }
      if (shouldInclude) {
        totalIncome += income.amount;
      }
    }

    setState(() {
      dataMap = totals;
    });
  }

  @override
  void dispose() {
    expensesSubscription?.cancel();
    super.dispose();
  }

  Widget _buildFilterButton(String text) {
    bool isSelected = _selectedFilter == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = text;
          _fetchData();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double balance = totalIncome - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi ${widget.nickname}!', style: TextStyle(fontFamily: 'Mag')),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFilterButton('Daily'),
                      SizedBox(width: 8.0),
                      _buildFilterButton('Monthly'),
                      SizedBox(width: 8.0),
                      _buildFilterButton('Yearly'),
                    ],
                  ),

                  SizedBox(height: 80),
                  dataMap.isEmpty
                      ? CircularProgressIndicator()
                      : PieChart(
                    dataMap: dataMap,
                    chartType: ChartType.ring,
                    animationDuration: Duration(milliseconds: 800),
                    chartRadius: MediaQuery.of(context).size.width / 2.5,
                    colorList: [
                      Colors.indigo.shade300,
                      Colors.redAccent.shade100,
                      Colors.green,
                      Colors.yellow,
                      Colors.purple,
                      Colors.tealAccent
                    ],
                    chartValuesOptions: ChartValuesOptions(
                      showChartValueBackground: false,
                      showChartValues: true,
                      showChartValuesInPercentage: true,
                      showChartValuesOutside: true,
                    ),
                    ringStrokeWidth: 42,
                    legendOptions: LegendOptions(
                      showLegendsInRow: false,
                      legendPosition: LegendPosition.bottom,
                      showLegends: true,
                      legendShape: BoxShape.circle,
                      legendTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  Text(
                    'Balance: ${balance.toStringAsFixed(2)} LKR',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 170.0),
              child: SizedBox(
                width: 120,
                height: 20,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/expenses_details');
                    print('Summary');
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade300,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70.0,left: 40.0),
              child: SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => addexpence(isar: widget.isar),
                      ),
                    );
                    print('Expenses');
                  },
                  child: Text(
                    'Expenses',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70.0,right: 40.0),
              child: SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Income(isar: widget.isar),
                      ),
                    );
                    print('Income');
                  },
                  child: Text(
                    'Income',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
