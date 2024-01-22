import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


class subjectConvertor {
  final String barCode, id;
  final String projectName, image, address;
  double weight, discount, price;
  int quantity;

  subjectConvertor({
    required this.barCode,
    required this.id,
    required this.image,
    required this.address,
    required this.discount,
    required this.price,
    required this.quantity,
    required this.weight,
    required this.projectName,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "barCode": barCode,
    "image": image,
    "address": address,
    "projectName": projectName,
    "discount": discount,
    "quantity": quantity,
    "weight": weight,
    "price": price,
  };


  static subjectConvertor fromJson(Map<String, dynamic> json) => subjectConvertor(
    id: json['id'] ?? "",
    address: json['address'] ?? "",
    barCode: json['barCode'] ?? "",
    weight: (json['weight'] ?? 0).toDouble(), // Convert to double
    image: json['image'] ?? "",
    projectName: json['projectName'] ?? "",
    quantity: json['quantity'] ?? 0,
    price: (json['price'] ?? 0).toDouble(), // Convert to double
    discount: (json['discount'] ?? 0).toDouble(), // Convert to double
  );


  static List<subjectConvertor> fromMapList(List<dynamic> list) {
    return list.map((item) => fromJson(item)).toList();
  }
}

class CartPreferences {
  static const String key = "Subjects";

  static Future<void> save(List<subjectConvertor> subjects) async {
    final prefs = await SharedPreferences.getInstance();
    final subjectsJson = subjects.map((subject) => subject.toJson()).toList();
    final subjectsString = jsonEncode(subjectsJson);
    await prefs.setString(key, subjectsString);
  }


  static Future<List<subjectConvertor>> get() async {
    final prefs = await SharedPreferences.getInstance();
    final subjectsString = prefs.getString(key);
    if (subjectsString != null) {
      final subjectsJson = jsonDecode(subjectsString) as List;
      return subjectsJson
          .map((json) => subjectConvertor.fromJson(json))
          .toList();
    } else {
      return [];
    }
  }

  static Future<void> add(subjectConvertor newSubject) async {
    final List<subjectConvertor> subjects = await get();
    subjects.add(newSubject);
    await save(subjects);
  }

  static Future<void> delete(String subjectId) async {
    List<subjectConvertor> subjects = await get();
    subjects.removeWhere((subject) => subject.barCode == subjectId);
    await save(subjects);
  }
}
