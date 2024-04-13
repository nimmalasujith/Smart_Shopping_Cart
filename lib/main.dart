// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/message_format.dart';
import 'package:new_virtual_keyboard/virtual_keyboard.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:upi_payment_qrcode_generator/upi_payment_qrcode_generator.dart';
import 'homePage.dart';
import 'test.dart';
import 'textField.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Shopping Cart',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  getData() async {
    var url =
        "https://firestore.googleapis.com/v1/projects/emartbtechproject/databases/(default)/documents/products";
    List<SubjectConvertor> projects = [];
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var collectionData = json.decode(response.body);
        for (var data in collectionData['documents']) {
          projects.add(SubjectConvertor.fromJson(data['fields']));
        }
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      products: projects,
                    )));
      } else {
        print('Failed to fetch collection: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
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
        ));
  }
}

class HomePage extends StatefulWidget {
  List<SubjectConvertor> products;

  HomePage({required this.products});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int IconIndex = 0;
  bool isReadyForPayment = false;
  double totalCost = 0.0;
  double weight = 0;
  TextEditingController HeadingController = TextEditingController();
  List<SubjectConvertor> cart = [];
  String cartString = '';

  List<int> discount = [2, 3, 5, 7, 10, 20, 30, 50, 70, 90];
  int discountIndex = 0;
  bool removeItem = false;
  late io.Socket socket;
  bool isOpened = false;

  void connectToServer() {
    socket = io.io(
      'http://127.0.0.1:8000',
      io.OptionBuilder().setTransports(['websocket']).build(),
    );

    socket.onConnect((_) {
      print('Connected to server');
    });
    socket.on('string_weight', (e) {
      double even  = double.parse(e);
      print(even);
      double weight =
          cart.fold(0.0, (sum, item) => sum + item.weight * item.quantity);
      if (!((even - 100) < weight && weight < (even + 200)) && !isOpened) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: contentBoxForWeight(context, !(weight < (even + 200))),
            );
          },
        );
        setState(() {
          isOpened = true;
        });
      } else if (((even - 100) < weight && weight < (even + 200)) &&
          isOpened) {
        Navigator.pop(context);
        setState(() {
          isOpened = false;
        });
      }
    });
    socket.on('string_data', (even) {
      if (cartString != even) {
        for (SubjectConvertor x in widget.products) {
          if (x.barCode.trim() == even.split(";").last.trim()) {
            if (removeItem && cart.contains(x)) {
              if (x.quantity == 1) {
                cart.remove(x);
              } else {
                cart.firstWhere((item) => item.barCode == x.barCode).quantity -=
                    1;
              }
              Navigator.pop(context);
              setState(() {
                removeItem = false;
              });
            } else if (cart.contains(x)) {
              cart.firstWhere((item) => item.barCode == x.barCode).quantity +=
                  1;
            } else {
              cart.add(x);
            }
          }
        }
        totalCost = cart.fold(
          0.0,
          (sum, item) =>
              sum +
              (item.quantity * item.price -
                  (item.quantity * item.price * (item.discount / 100))),
        );
        setState(() {
          totalCost;
          cart;
          cartString = even;
        });
      }
    });

    socket.onError((error) {
      print('Socket connection error: $error');
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
    });
    socket.connect();
  }

  String enteredText = '';

  @override
  void initState() {
    super.initState();
    connectToServer();
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
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
                            child: TextField(
                              controller: HeadingController,
                              textInputAction: TextInputAction.next,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search Here',
                                  hintStyle: TextStyle(color: Colors.black87)),
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
                            "Qty : ${cart.fold(0, (sum, item) => sum + item.quantity)}  ",
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
                            InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                        elevation: 0,
                                        backgroundColor: Colors.transparent,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          "Do You Want To Close Shopping?",
                                                          style: TextStyle(
                                                              fontSize: 35),
                                                        ),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          InkWell(
                                                              onTap: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            35),
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            5,
                                                                        horizontal:
                                                                            5),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .black,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            25)),
                                                                child: Text(
                                                                  "No",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          25,
                                                                      color: Colors
                                                                          .greenAccent
                                                                          .withOpacity(
                                                                              0.8)),
                                                                ),
                                                              )),
                                                          InkWell(
                                                              onTap: () {
                                                                Navigator.pop(
                                                                    context);
                                                                Navigator.pop(
                                                                    context);
                                                                cart.clear();
                                                              },
                                                              child: Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            35),
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top: 5,
                                                                        bottom:
                                                                            5,
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            30),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .black,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            25)),
                                                                child: Text(
                                                                  "Yes",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          25,
                                                                      color: Colors
                                                                          .red
                                                                          .withOpacity(
                                                                              0.8)),
                                                                ),
                                                              )),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: buildButtons("Cancel", Colors.red)),
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    IconIndex = 3;
                                  });
                                  // _databaseReference.child("updated").set('');
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
                              buildIcons(
                                4,
                                Icons.feed,
                                '"FeedBack"',
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
                          color: Colors.black,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Center(
                                        child: Text(
                                  "No.",
                                  style: TextStyle(color: Colors.white),
                                ))),
                                Expanded(
                                    flex: 5,
                                    child: Text(
                                      "  Product Name",
                                      style: TextStyle(color: Colors.white),
                                    )),
                                Expanded(
                                    child: Center(
                                        child: Text(
                                  "Price",
                                  style: TextStyle(color: Colors.white),
                                ))),
                                Expanded(
                                    child: Center(
                                        child: Text(
                                  "Discount",
                                  style: TextStyle(color: Colors.white),
                                ))),
                                Expanded(
                                    flex: 1,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_shopping_cart,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          "Qty",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Center(
                                        child: Text(
                                      "Total",
                                      style: TextStyle(color: Colors.white),
                                    ))),
                              ],
                            ),
                          ),
                        ),
                      if (IconIndex == 0)
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                if (cart.isNotEmpty)
                                  ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: cart.length,
                                    reverse: true,
                                    itemBuilder: (context, int index) {
                                      final data = cart[index];
                                      return data.projectName.isNotEmpty
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      child: Center(
                                                          child: Text(
                                                              "${index + 1}."))),
                                                  Expanded(
                                                      flex: 5,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "  ${data.projectName}",
                                                            style: TextStyle(
                                                                fontSize: 22,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10.0),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            3,
                                                                        horizontal:
                                                                            8),
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .black,
                                                                        borderRadius:
                                                                            BorderRadius.circular(20)),
                                                                    child: Row(
                                                                      children: [
                                                                        Text(
                                                                          "Bar Code : ${data.barCode}",
                                                                          style: TextStyle(
                                                                              fontSize: 16,
                                                                              color: Colors.white.withOpacity(0.9),
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                        Container(
                                                                          margin: EdgeInsets.symmetric(
                                                                              horizontal: 10,
                                                                              vertical: 3),
                                                                          height:
                                                                              20,
                                                                          width:
                                                                              2,
                                                                          color:
                                                                              Colors.white54,
                                                                        ),
                                                                        Text(
                                                                          "wt : ${data.weight}",
                                                                          style: TextStyle(
                                                                              fontSize: 16,
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                      ],
                                                                    )),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                                  Expanded(
                                                      child: Center(
                                                          child: Text(
                                                    "${data.price}",
                                                    style:
                                                        TextStyle(fontSize: 20),
                                                  ))),
                                                  Expanded(
                                                      child: Center(
                                                          child: Text(
                                                    "${data.discount}%",
                                                    style:
                                                        TextStyle(fontSize: 20),
                                                  ))),
                                                  Expanded(
                                                      child: Center(
                                                    child: Text(
                                                      "${data.quantity}",
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                  )),
                                                  Expanded(
                                                      flex: 2,
                                                      child: Center(
                                                          child: Text(
                                                        "${data.price - (data.price * (data.discount / 100))}",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ))),
                                                ],
                                              ),
                                            )
                                          : Container();
                                    },
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 50.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Scan Product To Add ",
                                          style: TextStyle(
                                              fontSize: 45,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Icon(
                                          Icons.arrow_circle_right,
                                          size: 55,
                                        )
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      if (IconIndex == 1)
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: widget.products!.length,
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
                                                        .toLowerCase())) &&
                                            data.projectName.isNotEmpty
                                        ? searchBarData(data: data)
                                        : Container();
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
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
                                                  discountIndex =
                                                      discount[index];
                                                });
                                              },
                                              child: Container(
                                                width: 200,
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 5, horizontal: 5),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 3,
                                                    horizontal: 10),
                                                decoration: BoxDecoration(
                                                  color: discountIndex ==
                                                          discount[index]
                                                      ? Colors.lightBlueAccent
                                                          .withOpacity(0.3)
                                                      : Colors.black12,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "Upto ${discount[index]}% off",
                                                    style:
                                                        TextStyle(fontSize: 22),
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
                                                        .toLowerCase())) &&
                                            (discountIndex <= data.discount) &&
                                            (data.discount > 0)
                                        ? InkWell(
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
                                                        flex: 2,
                                                        child: Text(
                                                          data.projectName,
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        )),
                                                    Expanded(
                                                        child: Text(
                                                      data.discount == 0
                                                          ? ""
                                                          : "${data.discount} %",
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
                                        if (isReadyForPayment)
                                          Column(
                                            children: [
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              const Text(
                                                  "UPI Payment QRCode with Amount",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              UPIPaymentQRCode(
                                                upiDetails: UPIDetails(
                                                    upiID: "8599988222@ybl",
                                                    payeeName: "Sujith Nimmala",
                                                    amount: totalCost,
                                                    transactionNote:
                                                        "Shopping Bill"),
                                                size: 220,
                                                upiQRErrorCorrectLevel:
                                                    UPIQRErrorCorrectLevel.low,
                                              ),
                                              Text(
                                                "Scan QR to Pay",
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    letterSpacing: 1.2),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Total Cost : ${totalCost}",
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Text(
                                                "Quantity    : ${cart.fold(0, (sum, item) => sum + item.quantity)}",
                                                style: TextStyle(fontSize: 30),
                                              ),
                                              Text(
                                                "Saved        : ${cart.fold(0.0, (sum, item) => sum + (item.quantity * item.price)) - cart.fold(0.0, (sum, item) => sum + (item.quantity * item.price - (item.quantity * item.price * (item.discount / 100))))}",
                                                style: TextStyle(fontSize: 30),
                                              )
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  isReadyForPayment = true;
                                                });
                                                // _databaseReference
                                                //     .child("updated")
                                                //     .set("");
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 25),
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 5,
                                                    horizontal: 10),
                                                decoration: BoxDecoration(
                                                    color: Colors.blue
                                                        .withOpacity(0.3),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.payments),
                                                    Text(
                                                      "Generate Bill",
                                                      style: TextStyle(
                                                          fontSize: 30),
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
                      if (IconIndex == 4)
                        Expanded(
                            child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  "Feed Back Form",
                                  style: TextStyle(fontSize: 30),
                                ),
                              ),
                              TextFieldContainer(
                                child: TextField(
                                  maxLines: null,
                                  controller: HeadingController,
                                  textInputAction: TextInputAction.next,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 25),
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Share Your Points',
                                      hintStyle:
                                          TextStyle(color: Colors.black87)),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(
                                  20.0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () async {
                                          String id = getID();
                                          final formData = FormConvertor(
                                            id: id,

                                            message: HeadingController.text,
                                          );

                                          try {
                                            await formData
                                                .uploadDataToFirestore(
                                                    formData);
                                            print(
                                                'Data uploaded successfully!');
                                            HeadingController.clear();

                                          } catch (e) {
                                            print('Error uploading data: $e');
                                          }
                                        },
                                        child: Text("Submit Here"))
                                  ],
                                ),
                              )
                            ],
                          ),
                        )),
                      if (IconIndex == 1 || IconIndex == 2 || IconIndex == 4)
                        Container(
                          // Keyboard is transparent
                          color: Colors.white,
                          child: VirtualKeyboard(
                              fontSize: 20,
                              type: VirtualKeyboardType.Alphanumeric,
                              onKeyPress: (key) {
                                print(key.text);
                                if (key.text == null) {
                                  setState(() {
                                    if (enteredText.isNotEmpty) {
                                      enteredText = enteredText.substring(
                                          0, enteredText.length - 1);
                                    }
                                  });
                                } else {
                                  // Update the enteredText for other keys
                                  setState(() {
                                    enteredText += key.text;
                                  });
                                }
                                HeadingController.text = enteredText;
                              }),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30), color: Colors.black87),
            child: Row(
              children: [
                if (IconIndex == 0)
                  InkWell(
                    onTap: () {
                      setState(() {
                        removeItem = true;
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return RemoveItemBuild(context);
                          },
                        );
                      });
                    },
                    child: Text(
                      "Remove Product",
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                if (IconIndex == 2)
                  InkWell(
                    onTap: () {
                      getData();
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 30,
                          color: Colors.white,
                        ),
                        Text(
                          " Today's Offers",
                          style: TextStyle(color: Colors.white, fontSize: 25),
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

  Widget contentBoxForWeight(BuildContext context, bool isMax) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0, 10),
                blurRadius: 10.0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isMax
                    ? "PLEASE SCAN THE REMOVED PRODUCT or PLACE IT IN THE CART"
                    : "PLEASE PLACE THE SCANNED PRODUCT",
                style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.black87),
                    child: Row(
                      children: [
                        if (IconIndex == 0)
                          InkWell(
                            onTap: () {
                              setState(() {
                                removeItem = true;
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return RemoveItemBuild(context);
                                  },
                                );
                              });
                            },
                            child: Text(
                              "Remove Product",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25),
                            ),
                          ),
                        if (IconIndex == 2)
                          InkWell(
                            onTap: () {
                              getData();
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.filter_list,
                                  size: 30,
                                  color: Colors.white,
                                ),
                                Text(
                                  " Today's Offers",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 25),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget RemoveItemBuild(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0, 10),
                blurRadius: 10.0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                        image: AssetImage("assets/scanner.gif"))),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Scan Product To Remove From The List.",
                      style: TextStyle(
                          fontSize: 40.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 50.0),
                    Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            removeItem = false;
                          });
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 50),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.black87),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white, fontSize: 40),
                          ),
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
    );
  }

  List<String> projects = [];

  todayOff() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 30),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 15),
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 40,
                              ),
                            )),
                        Text(
                          "Today Deals",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 30),
                        )
                      ],
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CarouselSlider(
                          options: CarouselOptions(
                              aspectRatio: 16 / 9,
                              viewportFraction: 1,
                              autoPlay: true),
                          items: projects.map((item) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Image.network(
                                  item,
                                  fit: BoxFit.cover,
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  getData() async {
    var url =
        "https://firestore.googleapis.com/v1/projects/emartbtechproject/databases/(default)/documents/todayProducts";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var collectionData = json.decode(response.body);
        for (var data in collectionData['documents']) {
          projects.add(data['fields']['imageUrl']['stringValue']);
        }
        setState(() {
          projects;
        });
        todayOff();
      } else {
        print('Failed to fetch collection: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  Widget buildButtons(String text, Color colors) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Text(
        text,
        style: TextStyle(fontSize: 25, color: colors.withOpacity(0.8)),
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
        if (index == 2) getData();
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

class todayProductsConvertor {
  final String imageUrl, id;

  todayProductsConvertor({
    required this.imageUrl,
    required this.id,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "imageUrl": imageUrl,
      };

  static todayProductsConvertor fromJson(Map<String, dynamic> json) =>
      todayProductsConvertor(
        id: json['id'] ?? "",
        imageUrl: json['imageUrl'] ?? "",
      );

  static List<todayProductsConvertor> fromMapList(List<dynamic> list) {
    return list.map((item) => fromJson(item)).toList();
  }
}
