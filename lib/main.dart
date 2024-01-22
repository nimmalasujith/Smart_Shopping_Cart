// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import 'textField.dart';

void main() {
  runApp(const MyApp());
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
      home: HomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Welcome To E-Mart",
                style: TextStyle(fontSize: 40),
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
            ),
          ],
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int IconIndex = 0;
TextEditingController HeadingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
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
                        if(IconIndex==1)Expanded(
                          child: TextFieldContainer(
                            child: TextFormField(
                              controller: HeadingController,
                              textInputAction: TextInputAction.next,
                              style:
                              TextStyle(color: Colors. black, fontSize:   20),
                              onChanged: (value){
                                setState(() {

                                });
                              },
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search Here',
                                  hintStyle: TextStyle(color: Colors. black54)),
                            ),

                          ),
                        ),
                        if(HeadingController.text.isNotEmpty)InkWell(onTap: (){
                          HeadingController.clear();
                        },child: Icon(Icons.close,size: 30,)),
                        if(IconIndex==1)buildButtons("Search", Colors.red),

                      ],
                    ),
                  )

             ,
Row(
  children: [
    if(IconIndex==0)Row(
      children: [
        Text("Quantity : 40  ",style: TextStyle(fontSize: 30),),
        Text("Total : 564",style: TextStyle(fontSize: 30),),
      ],
    ),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          buildButtons("Cancel", Colors.red),
          buildButtons("Finish", Colors.green),
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
                                  Icons.settings,
                                  'Settings',
                                ),
                              ],
                            ),
                          ))),
                  Expanded(
                    flex: 10,
                    child: Column(
                      children: [
                        if(IconIndex==0)Container(
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
                        if(IconIndex==0)Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, int index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Center(
                                                    child: Text("${index+1}."))),
                                            Expanded(
                                                flex: 5,
                                                child: Text("  Product Name")),
                                            Expanded(
                                                child: Center(
                                                    child: Text("Price"))),
                                            Expanded(
                                                child: Center(
                                                    child: Text("Discount"))),
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
                                                      " 2 ",
                                                      style: TextStyle(
                                                          fontSize: 25),
                                                    ),
                                                    Icon(Icons.add_circle),
                                                  ],
                                                )),
                                            Expanded(
                                                child: Center(
                                                    child: Text("Total"))),
                                          ],
                                        ),
                                      );
                                    },
                                    itemCount: 20),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        if(index!=1)HeadingController.clear();
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
