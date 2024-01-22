import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();


  void setupDataChangeListener(Function(List<String>) onChanged) {
    _databaseReference.child("updated").onChildChanged.listen((event) {
      if (event.snapshot.value != null) {
        String even=event.toString();
      }
    });
  }
}
