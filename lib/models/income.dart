import 'package:isar/isar.dart';

part 'income.g.dart';

@collection
class Incomes {
  Id id=Isar.autoIncrement;
  late  String description;
  late double amount;
late DateTime date;

 Incomes({
    required this.description,
    required this.amount,
    required this.date,
  });}
