import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<BranchStudyMaterialsConvertor?> getBranchStudyMaterials(
    String branch, bool isLoading) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final studyMaterialsJson = await prefs.getString("products");

  if (studyMaterialsJson == null || isLoading) {

    try {
      var documentSnapshot = await FirebaseFirestore.instance
          .collection("products")
          .doc(branch)
          .get();
      if (documentSnapshot.exists) {

        var documentData = documentSnapshot.data();
        try {
          final subjectsQuery =
          await documentSnapshot.reference.collection("products").get();


          final subjects = await subjectsQuery.docs
              .map((doc) => subjectConvertor.fromJson(doc.data()))
              .toList();

          final data = await BranchStudyMaterialsConvertor(
            subjects: subjects,

          );

          String studyMaterialsJson = await json.encode(data.toJson());
          await prefs.setString("products", studyMaterialsJson);
          return data;
        } catch (e) {
          print("Error processing data: $e");
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting study materials: $e");
      return null;
    }
  }
  else {
    return await BranchStudyMaterialsConvertor.fromJson(
        json.decode(studyMaterialsJson));
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


class BranchStudyMaterialsConvertor {
  List<subjectConvertor> subjects;


  BranchStudyMaterialsConvertor({
    required this.subjects,

  });

  Map<String, dynamic> toJson() => {
    "Subjects": subjects.map((subject) => subject.toJson()).toList(),

  };

  static BranchStudyMaterialsConvertor fromJson(Map<String, dynamic> json) =>
      BranchStudyMaterialsConvertor(
        subjects: (json['Subjects'] as List<dynamic>?)
            ?.map((item) => subjectConvertor.fromJson(item))
            .toList() ??
            [],

      );

  static List<BranchStudyMaterialsConvertor> fromMapList(List<dynamic> list) {
    return list.map((item) => fromJson(item)).toList();
  }
}
class subjectConvertor {
  final String barCode;
  final String projectName;
  double weight,discount,totalPrice;
  int quantity;

  subjectConvertor({
    required this.barCode,
    required this.discount,
    required this.totalPrice,
    required this.quantity,
    required this.weight,
    required this.projectName,
  });

  Map<String, dynamic> toJson() => {
    "barCode": barCode,
    "projectName": projectName,
    "discount": discount,
    "quantity": quantity,
    "weight": weight,
    "totalPrice": totalPrice,


  };


  static subjectConvertor fromJson(Map<String, dynamic> json) =>
      subjectConvertor(
        barCode: json['id'] ?? "",
        weight: json['weight']??"",

        projectName: json['projectName'] ?? "",
        quantity: json['quantity'] ?? "",
        totalPrice: json['totalPrice'] ?? "",
        discount: json['discount'] ?? "",

      );

  static List<subjectConvertor> fromMapList(List<dynamic> list) {
    return list.map((item) => fromJson(item)).toList();
  }
}
