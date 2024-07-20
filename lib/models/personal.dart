import 'package:isar/isar.dart';

part 'personal.g.dart';

@Collection()
class Personal {
  Id id = Isar.autoIncrement; // You can also use int

  late String name;
  late String nickname;
}