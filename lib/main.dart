// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:upi_payment_qrcode_generator/upi_payment_qrcode_generator.dart';
import 'firebase_options.dart';
import 'test.dart';
import 'test2.dart';
import 'textField.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  getData() async {
    try {
      final collectionSnapshot =
          await FirebaseFirestore.instance.collection("products").get();

      if (collectionSnapshot.docs.isNotEmpty) {
        try {
          List<subjectConvertor> subjects = collectionSnapshot.docs
              .map((doc) => subjectConvertor.fromJson(doc.data()))
              .toList();
          print(subjects.toList());
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(
                        products: subjects,
                      )));
        } catch (e) {
          print(e);
        }
      }
    } catch (e) {}
  }

  showText(String text) {
    Fluttertoast.showToast(
      msg: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                // onTap: () async {
                //   String id = getID();
                //   await FirebaseFirestore.instance
                //       .collection('products')
                //       .doc(id)
                //       .set(
                //         subjectConvertor(
                //           image: "",
                //           barCode: '',
                //           discount: 0.0,
                //           price: 0,
                //           quantity: 0,
                //           weight: 0.0,
                //           projectName: '',
                //           id: id,
                //           address: '',
                //         ).toJson(),
                //       );
                // },
                child: Text(
                  "Welcome To E-Mart",
                  style: TextStyle(fontSize: 40),
                ),
              )
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(4, 12, 26, 1),
                    borderRadius: BorderRadius.circular(40)),
                child: Row(
                  children: [
                    Text(
                      "  Start Shopping ",
                      style: TextStyle(fontSize: 40, color: Colors.white),
                    ),
                    Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(30)),
                        child: Icon(
                          Icons.start,
                          color: Colors.white,
                        ))
                  ],
                ),
              ),
              onTap: () {
                getData();
              },
            ),
          ],
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}

class HomePage extends StatefulWidget {
  List<subjectConvertor> products;

  HomePage({required this.products});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int IconIndex = 0;
  bool isReadyForPayment =false;
  double totalCost = 0.0;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  Future<void> setupDataChangeListener() async {
    try {
      var event = await _databaseReference.child("updated").get();

      if (event.exists) {
        String even = event.value.toString();

        if (cartString != even) {
          for (subjectConvertor x in widget.products) {
            if (x.barCode == even.split(";").last.trim()) {
              cart.add(x);
            }
          }
          for (subjectConvertor data in cart) {
            totalCost += data.price - (data.price * (data.discount / 100));
          }

          setState(() {
            cartString = even;
          });
        }
      } else {
        print("Snapshot does not exist");
      }
    } catch (e) {
      // Handle any errors that might occur during the database operation
      print("Error fetching data: $e");
    }
  }

  TextEditingController HeadingController = TextEditingController();
  List<subjectConvertor> cart = [];
  String cartString = '';
  subjectConvertor search = subjectConvertor(
      barCode: "",
      id: "",
      image: "",
      address: "",
      discount: 0,
      price: 0,
      quantity: 0,
      weight: 0,
      projectName: "");
  List<int> discount = [2, 3, 5, 7, 10, 20, 30, 50, 70, 90];
  int discountIndex = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      // setupDataChangeListener();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.blueGrey.withOpacity(0.2),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text(
                          "E-mart",
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                      if (IconIndex == 1 || IconIndex == 2)
                        Expanded(
                          child: TextFieldContainer(
                            child: TextFormField(
                              controller: HeadingController,
                              textInputAction: TextInputAction.next,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                              onChanged: (value) {
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search Here',
                                  hintStyle: TextStyle(color: Colors.black54)),
                            ),
                          ),
                        ),
                      if (HeadingController.text.isNotEmpty)
                        InkWell(
                            onTap: () {
                              HeadingController.clear();
                            },
                            child: Icon(
                              Icons.close,
                              size: 30,
                            )),
                      if (IconIndex == 1 || IconIndex == 2)
                        buildButtons("Search", Colors.red),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (IconIndex == 0)
                      Row(
                        children: [
                          Text(
                            "Quantity : ${cart.length}  ",
                            style: TextStyle(fontSize: 30),
                          ),
                          Text(
                            "Total : ${totalCost}",
                            style: TextStyle(fontSize: 30),
                          ),
                        ],
                      ),
                    if (IconIndex != 3)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          children: [
                            buildButtons("Cancel", Colors.red),
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    IconIndex = 3;
                                  });
                                },
                                child: buildButtons("Finish", Colors.green)),
                          ],
                        ),
                      )
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Container(
                        color: Colors.black.withOpacity(0.1),
                        height: double.infinity,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildIcons(
                                0,
                                Icons.shopping_cart,
                                'Shopping',
                              ),
                              buildIcons(
                                1,
                                Icons.search,
                                'Search Product',
                              ),
                              buildIcons(
                                2,
                                Icons.local_offer,
                                'Offers',
                              ),
                              buildIcons(
                                3,
                                Icons.exit_to_app,
                                'Exit',
                              ),
                            ],
                          ),
                        ))),
                Expanded(
                  flex: 10,
                  child: Column(
                    children: [
                      if (IconIndex == 0)
                        Container(
                          color: Colors.black26,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              children: [
                                Expanded(child: Center(child: Text("No."))),
                                Expanded(
                                    flex: 5, child: Text("  Product Name")),
                                Expanded(child: Center(child: Text("Price"))),
                                Expanded(
                                    child: Center(child: Text("Discount"))),
                                Expanded(
                                    flex: 2,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_shopping_cart),
                                        Text(" Quantity"),
                                      ],
                                    )),
                                Expanded(child: Center(child: Text("Total"))),
                              ],
                            ),
                          ),
                        ),
                      if (IconIndex == 0)
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: cart.length,
                                  itemBuilder: (context, int index) {
                                    final data = cart[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Center(
                                                  child:
                                                      Text("${index + 1}."))),
                                          Expanded(
                                              flex: 5,
                                              child: Text(
                                                  "  ${data.projectName}")),
                                          Expanded(
                                              child: Center(
                                                  child:
                                                      Text("${data.price}"))),
                                          Expanded(
                                              child: Center(
                                                  child: Text(
                                                      "${data.discount}%"))),
                                          Expanded(
                                              flex: 2,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.remove_circle),
                                                  Text(
                                                    " 1 ",
                                                    style:
                                                        TextStyle(fontSize: 25),
                                                  ),
                                                  Icon(Icons.add_circle),
                                                ],
                                              )),
                                          Expanded(
                                              child: Center(
                                                  child: Text(
                                                      "${data.price - (data.price * (data.discount / 100))}"))),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (IconIndex == 1)
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: widget.products!.length,
                                        itemBuilder: (context, int index) {
                                          final data = widget.products[index];
                                          return data.projectName
                                                      .toLowerCase()
                                                      .startsWith(
                                                          HeadingController.text
                                                              .toLowerCase()) ||
                                                  data.projectName
                                                      .toLowerCase()
                                                      .contains(
                                                          HeadingController.text
                                                              .toLowerCase())
                                              ? InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      search = data;
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10.0),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                            data.projectName,
                                                            style: TextStyle(
                                                                fontSize: 20),
                                                          )),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Container();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (search.id.isNotEmpty)
                                Expanded(
                                    child: Container(
                                  color: Colors.blueGrey.withOpacity(0.1),
                                  height: double.infinity,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                search.projectName,
                                                style: TextStyle(fontSize: 30),
                                              ),
                                              InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      search = subjectConvertor(
                                                          barCode: "",
                                                          id: "",
                                                          image: "",
                                                          address: "",
                                                          discount: 0,
                                                          price: 0,
                                                          quantity: 0,
                                                          weight: 0,
                                                          projectName: "");
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 50,
                                                  ))
                                            ],
                                          ),
                                        ),
                                        Image.network(search.image),
                                        Container(
                                          width: double.infinity,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 10),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 10),
                                          decoration: BoxDecoration(
                                              color: Colors.greenAccent
                                                  .withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Original Price : ${search.price}",
                                                style: TextStyle(fontSize: 25),
                                              ),
                                              Text(
                                                "Discount         : ${search.discount}",
                                                style: TextStyle(fontSize: 25),
                                              ),
                                              Text(
                                                "Final Price      : ${search.price - (search.price * (search.discount / 100))}",
                                                style: TextStyle(fontSize: 25),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 10),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                          decoration: BoxDecoration(
                                              color: Colors.black12,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Location",
                                                style: TextStyle(fontSize: 25),
                                              ),
                                              Text(
                                                "${search.address}",
                                                style: TextStyle(fontSize: 25),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                            ],
                          ),
                        ),
                      if (IconIndex == 2)
                        SizedBox(
                          height: 50,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                if (discountIndex > 0)
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          discountIndex = 0;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.close,
                                          size: 40,
                                          color: Colors.red,
                                        ),
                                      )),
                                ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: discount.length,
                                  itemBuilder: (context, int index) {
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          discountIndex = discount[index];
                                        });
                                      },
                                      child: Container(
                                        width: 200,
                                        margin: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 5),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 3, horizontal: 10),
                                        decoration: BoxDecoration(
                                          color:
                                              discountIndex == discount[index]
                                                  ? Colors.lightBlueAccent
                                                      .withOpacity(0.3)
                                                  : Colors.black12,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Upto ${discount[index]}% off",
                                            style: TextStyle(fontSize: 22),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (IconIndex == 2)
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: widget.products.length,
                                  itemBuilder: (context, int index) {
                                    final data = widget.products[index];
                                    return (data.projectName
                                                    .toLowerCase()
                                                    .startsWith(
                                                        HeadingController.text
                                                            .toLowerCase()) ||
                                                data.projectName
                                                    .toLowerCase()
                                                    .contains(HeadingController
                                                        .text
                                                        .toLowerCase())) &&(
                                            discountIndex <= data.discount)&&(data.discount>0)
                                        ? InkWell(
                                            onTap: () {
                                              setState(() {
                                                search = data;
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10.0),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20.0),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex:2,
                                                        child: Text(
                                                      data.projectName,
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    )),
                                                    Expanded(
                                                        child: Text(
                                                          data.discount==0?"":"${data.discount} %",
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    )),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (IconIndex == 3)
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              IconIndex = 0;
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 10),
                                            margin: EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 10),
                                            decoration: BoxDecoration(
                                                color: Colors.green
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Row(
                                              children: [
                                                Icon(Icons.arrow_back_ios),
                                                Text(
                                                  "Back To Shopping",
                                                  style:
                                                      TextStyle(fontSize: 30),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if(isReadyForPayment)Column(
                                          children: [

                                            const SizedBox(
                                              height: 20,
                                            ),
                                            const Text("UPI Payment QRCode with Amount",
                                                style: TextStyle(fontWeight: FontWeight.bold)),
                                            UPIPaymentQRCode(
                                              upiDetails: UPIDetails(
                                                  upiID: "8599988222@ybl",
                                                  payeeName: "Sujith Nimmala",
                                                  amount: totalCost,
                                                  transactionNote: "Shopping Bill"),
                                              size: 220,
                                              upiQRErrorCorrectLevel: UPIQRErrorCorrectLevel.low,
                                            ),
                                            Text(
                                              "Scan QR to Pay",
                                              style: TextStyle(color: Colors.grey[600], letterSpacing: 1.2),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    Expanded(
                                        child: Column(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 20),
                                          margin: EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 20),
                                          decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withOpacity(0.08),
                                              borderRadius:
                                              BorderRadius.circular(30)),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Total Cost : ${totalCost}",style: TextStyle(fontSize: 30,fontWeight: FontWeight.w500),),
                                              Text("Quantity    : ${cart.length}",style: TextStyle(fontSize: 30),),
                                              Text("Saved        : --",style: TextStyle(fontSize: 30),)
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                            setState(() {
                                              isReadyForPayment = true;
                                            });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10, horizontal: 25),
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 5, horizontal: 10),
                                                decoration: BoxDecoration(
                                                    color: Colors.blue
                                                        .withOpacity(0.3),
                                                    borderRadius:
                                                        BorderRadius.circular(10)),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.payments),
                                                    Text(
                                                      "Generate Bill",
                                                      style:
                                                          TextStyle(fontSize: 30),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButtons(String text, Color colors) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
          color: colors.withOpacity(0.8),
          borderRadius: BorderRadius.circular(25)),
      child: Text(
        text,
        style: TextStyle(fontSize: 25),
      ),
    );
  }

  Widget buildIcons(int index, IconData icon, String heading) {
    return InkWell(
      onTap: () {
        if (index != 1) HeadingController.clear();
        setState(() {
          IconIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        color: IconIndex == index ? Colors.white : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Icon(
              icon,
              size: 60,
            )),
          ],
        ),
      ),
    );
  }
}

String getID() {
  var now = new DateTime.now();
  return DateFormat('d.M.y-kk:mm:ss').format(now);
}
