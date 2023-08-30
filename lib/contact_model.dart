import 'package:hive/hive.dart';
part 'contact_model.g.dart';
@HiveType(typeId: 0)
class ContactModel {
  @HiveField(0)
  String name;
  @HiveField(1)
  List<String> message = [];
  @HiveField(2)
  bool isSelected = false;

  ContactModel({required this.name, required this.message , this.isSelected = false});
}
