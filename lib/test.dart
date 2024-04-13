import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SubjectConvertor {
  final String barCode, id;
  final String projectName, image, address;
  double weight, discount, price;
  int quantity;

  SubjectConvertor({
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

  static SubjectConvertor fromJson(Map<String, dynamic> json) {
    // Access nested values from the JSON map
    Map<String, dynamic> idMap = json['id'] ?? {};
    Map<String, dynamic> projectNameMap = json['projectName'] ?? {};
    Map<String, dynamic> weightMap = json['weight'] ?? {};
    Map<String, dynamic> imageMap = json['image'] ?? {};
    Map<String, dynamic> addressMap = json['address'] ?? {};
    Map<String, dynamic> discountMap = json['discount'] ?? {};
    Map<String, dynamic> quantityMap = json['quantity'] ?? {};
    Map<String, dynamic> barCodeMap = json['barCode'] ?? {};
    Map<String, dynamic> priceMap = json['price'] ?? {};

    return SubjectConvertor(
      id: idMap['stringValue'] ?? "",
      address: addressMap['stringValue'] ?? "",
      barCode: barCodeMap['stringValue'] ?? "",
      weight: double.parse(weightMap['integerValue']?.toString() ?? '0'),
      image: imageMap['stringValue'] ?? "",
      projectName: projectNameMap['stringValue'] ?? "",
      quantity: int.parse(quantityMap['integerValue']?.toString() ?? '0'),
      price: double.parse(priceMap['integerValue']?.toString() ?? '0'),
      discount: double.parse(discountMap['integerValue']?.toString() ?? '0'),
    );
  }

  static List<SubjectConvertor> fromMapList(List<dynamic> list) {
    return list.map((item) => fromJson(item)).toList();
  }
}

class FormConvertor {
  final String id;
  final String message;

  FormConvertor({
    required this.id,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "message": message,
      };

  static FormConvertor fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('json parameter cannot be null');
    }

    return FormConvertor(
      id: json['id'] ?? "",
      message: json['message'] ?? "",
    );
  }

  static List<FormConvertor> fromMapList(List<dynamic> list) {
    return list.map((item) => fromJson(item)).toList();
  }

  Future<void> uploadDataToFirestore(FormConvertor data) async {
    final url =
        'https://firestore.googleapis.com/v1/projects/emartbtechproject/databases/(default)/documents/forms/${data.id}';

    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'fields': {
          'id': {'stringValue': data.id},
          'message': {'stringValue': data.message},
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to upload data: ${response.body}');
    }
  }
}

class CartPreferences {
  static const String key = "Subjects";

  static Future<void> save(List<SubjectConvertor> subjects) async {
    final prefs = await SharedPreferences.getInstance();
    final subjectsJson = subjects.map((subject) => subject.toJson()).toList();
    final subjectsString = jsonEncode(subjectsJson);
    await prefs.setString(key, subjectsString);
  }

  static Future<List<SubjectConvertor>> get() async {
    final prefs = await SharedPreferences.getInstance();
    final subjectsString = prefs.getString(key);
    if (subjectsString != null) {
      final subjectsJson = jsonDecode(subjectsString) as List;
      return subjectsJson
          .map((json) => SubjectConvertor.fromJson(json))
          .toList();
    } else {
      return [];
    }
  }

  static Future<void> add(SubjectConvertor newSubject) async {
    final List<SubjectConvertor> subjects = await get();
    subjects.add(newSubject);
    await save(subjects);
  }

  static Future<void> delete(String subjectId) async {
    List<SubjectConvertor> subjects = await get();
    subjects.removeWhere((subject) => subject.barCode == subjectId);
    await save(subjects);
  }
}
