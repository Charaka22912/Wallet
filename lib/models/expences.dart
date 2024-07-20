import 'package:isar/isar.dart';

part 'expences.g.dart'; // This part is for generated code

@Collection()
class Expenses {
  Id id = Isar.autoIncrement; // You can also use int
  late String catgory;
  late String description;
  late double amount;
  late DateTime date;

  Expenses({
    required this.catgory,
    required this.description,
    required this.amount,
    required this.date,
  });
}
