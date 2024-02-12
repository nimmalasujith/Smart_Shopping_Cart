// ignore_for_file: prefer_const_constructors

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:smart_cart/test.dart';

class FirebaseService {
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

  void setupDataChangeListener(Function(List<String>) onChanged) {
    _databaseReference.child("updated").onChildChanged.listen((event) {
      if (event.snapshot.value != null) {
        String even = event.toString();
      }
    });
  }
}

class searchBarData extends StatefulWidget {
  subjectConvertor data;

  searchBarData({required this.data});

  @override
  State<searchBarData> createState() => _searchBarDataState();
}

class _searchBarDataState extends State<searchBarData> {
  bool isExp = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isExp = !isExp;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0,horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data.projectName,
                        style: TextStyle(fontSize: isExp?25:20,fontWeight: isExp? FontWeight.w600:FontWeight.normal),
                      ),
                      if (isExp) Container(

                        margin: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        padding: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Original Price : ${widget.data.price}",
                              style: TextStyle(fontSize: 25),
                            ),
                            Text(
                              "Discount         : ${widget.data.discount} %",
                              style: TextStyle(fontSize: 25),
                            ),
                            Text(
                              "Final Price      : ${widget.data.price - (widget.data.price * (widget.data.discount / 100))}",
                              style: TextStyle(fontSize: 25),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                if (isExp) Expanded(flex:2,child: AspectRatio(aspectRatio: 16/9,child: Image.network(widget.data.image)))
              ],
            ),

            if (isExp)Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Location",
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  "  ${widget.data.address}",
                  style: TextStyle(fontSize: 25,fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
