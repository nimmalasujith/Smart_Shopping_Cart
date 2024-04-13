// import 'dart:io';
//
import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
class TextFieldContainer extends StatefulWidget {
  Widget child;
  String heading;

  TextFieldContainer({required this.child, this.heading = ""});

  @override
  State<TextFieldContainer> createState() => _TextFieldContainerState();
}

class _TextFieldContainerState extends State<TextFieldContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.heading.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left:   15, top:   8),
            child: Text(
              widget.heading,
              style: TextStyle(fontSize: 18),
            ),
          ),
        Padding(
          padding: EdgeInsets.only(
              left:   10,
              right:   10,
              top:   5,
              bottom:   5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors. black12),
              borderRadius: BorderRadius.circular(  10),
            ),
            child: Padding(
              padding: EdgeInsets.only(left:   10),
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}
//
// class updateCreator extends StatefulWidget {
//   bool mode;
//   String NewsId;
//   String heading;
//   String link;
//   String photoUrl;
//   String subMessage;
//   String branch;
//
//
//   updateCreator(
//       {this.NewsId = "",
//         this.link = '',
//         this.heading = "",
//         this.photoUrl = "",
//         this.subMessage = "",
//         this.mode = false,
//
//         required this.branch});
//
//   @override
//   State<updateCreator> createState() => _updateCreatorState();
// }
//
// class _updateCreatorState extends State<updateCreator> {
//   FirebaseStorage storage = FirebaseStorage.instance;
//   String Branch = "";
//   bool isBranch = false;
//   final HeadingController = TextEditingController();
//   final DescriptionController = TextEditingController();
//   final PhotoUrlController = TextEditingController();
//   final LinkController = TextEditingController();
//   bool _isImage = false;
//
//   void AutoFill() async {
//     HeadingController.text = widget.heading;
//     PhotoUrlController.text = widget.photoUrl;
//     DescriptionController.text = widget.subMessage;
//     LinkController.text = widget.link;
//     if (widget.photoUrl.length > 3) {
//       setState(() {
//         _isImage = true;
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     AutoFill();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     HeadingController.dispose();
//     PhotoUrlController.dispose();
//     LinkController.dispose();
//     super.dispose();
//   }
//
//   bool isSwitched = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: SafeArea(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 backButton(
//
//                     text: "Updater",
//                     child: SizedBox(
//                       width:   45,
//                     )),
//                 TextFieldContainer(
//                   child: TextFormField(
//                     controller: HeadingController,
//                     textInputAction: TextInputAction.next,
//                     style:
//                     TextStyle(color: Colors. black, fontSize:   20),
//                     decoration: InputDecoration(
//                         border: InputBorder.none,
//                         hintText: 'Heading',
//                         hintStyle: TextStyle(color: Colors. black54)),
//                   ),
//                   heading: "Heading",
//                 ),
//                 TextFieldContainer(
//                   child: TextFormField(
//                     controller: DescriptionController,
//                     textInputAction: TextInputAction.next,
//                     style:
//                     TextStyle(color: Colors. black, fontSize:   20),
//                     decoration: InputDecoration(
//                         border: InputBorder.none,
//                         hintText: 'Description',
//                         hintStyle: TextStyle(color: Colors. black54)),
//                   ),
//                   heading: "Description",
//                 ),
//                 TextFieldContainer(
//                   child: TextFormField(
//                     controller: LinkController,
//                     textInputAction: TextInputAction.next,
//                     style:
//                     TextStyle(color: Colors. black, fontSize:   20),
//                     decoration: InputDecoration(
//                         border: InputBorder.none,
//                         hintText: 'Url',
//                         hintStyle: TextStyle(color: Colors. black54)),
//                   ),
//                   heading: "Url",
//                 ),
//                 if (_isImage == true)
//                   Padding(
//                     padding: EdgeInsets.only(
//                         left:   10, top:   20),
//                     child: Row(
//                       children: [
//                         Container(
//                             height:   110,
//                             width:   180,
//                             decoration: BoxDecoration(
//                                 color: Colors.black.withOpacity(0.5),
//                                 borderRadius:
//                                 BorderRadius.circular(  14),
//                                 image: DecorationImage(
//                                     image: NetworkImage(
//                                         PhotoUrlController.text.trim()),
//                                     fit: BoxFit.fill))),
//                         InkWell(
//                           child: Padding(
//                             padding: EdgeInsets.only(
//                                 left:   30,
//                                 top:   10,
//                                 bottom:   10,
//                                 right:   10),
//                             child: Text(
//                               "Delete",
//                               style: TextStyle(
//                                   fontSize:   30,
//                                   color: CupertinoColors.destructiveRed),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 if (_isImage == false)
//                   InkWell(
//                     child: Padding(
//                       padding: EdgeInsets.only(
//                           left:   15,
//                           top:   20,
//                           bottom:   10),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.upload,
//                             size:   35,
//                             color: Colors. black,
//                           ),
//                           SizedBox(
//                             width:   5,
//                           ),
//                           Text(
//                             "Upload Photo",
//                             style: TextStyle(
//                                 fontSize:   30, color: Colors. black),
//                           ),
//                         ],
//                       ),
//                     ),
//                     onTap: () async {
//                       final pickedFile = await ImagePicker()
//                           .pickImage(source: ImageSource.gallery);
//                       File file = File(pickedFile!.path);
//                       final Reference ref =
//                       storage.ref().child('products/${getID()}');
//                       final TaskSnapshot task = await ref.putFile(file);
//                       final String url = await task.ref.getDownloadURL();
//                       PhotoUrlController.text = url;
//                       bool _isLoading = false;
//                       showDialog(
//                         context: context,
//                         builder: (context) {
//                           return Dialog(
//                             backgroundColor: Colors.black.withOpacity(0.1),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius:
//                                 BorderRadius.circular(  20)),
//                             elevation: 16,
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 border: Border.all(
//                                     color: Colors. black.withOpacity(0.1)),
//                                 borderRadius:
//                                 BorderRadius.circular(  20),
//                               ),
//                               child: ListView(
//                                 physics: BouncingScrollPhysics(),
//                                 shrinkWrap: true,
//                                 children: <Widget>[
//                                   Center(
//                                     child: Padding(
//                                       padding: EdgeInsets.all(  8.0),
//                                       child: Text(
//                                         "Image",
//                                         style: TextStyle(
//                                             fontSize:   22,
//                                             fontWeight: FontWeight.w300,
//                                             color: Colors.blue),
//                                       ),
//                                     ),
//                                   ),
//                                   Stack(
//                                     children: <Widget>[
//                                       Image.network(
//                                         url,
//                                         fit: BoxFit.cover,
//                                         loadingBuilder: (context, child, progress) {
//                                           if (progress == null) {
//                                             _isLoading = false;
//                                           }
//                                           return progress == null
//                                               ? child
//                                               : Center(
//                                               child:
//                                               CircularProgressIndicator());
//                                         },
//                                       ),
//                                       if (_isLoading)
//                                         Center(
//                                           child: CircularProgressIndicator(),
//                                         ),
//                                     ],
//                                   ),
//                                   SizedBox(
//                                     height:   10,
//                                   ),
//                                   Row(
//                                     children: [
//                                       InkWell(
//                                         child: Padding(
//                                           padding:
//                                           EdgeInsets.all(  5.0),
//                                           child: Text(
//                                             "Cancel & Delete",
//                                             style: TextStyle(
//                                                 color: Colors. black,
//                                                 fontSize:   20),
//                                           ),
//                                         ),
//                                         onTap: () async {
//                                           final Uri uri = Uri.parse(url);
//                                           final String fileName =
//                                               uri.pathSegments.last;
//                                           final Reference ref =
//                                           storage.ref().child("/${fileName}");
//                                           try {
//                                             await ref.delete();
//                                             showToastText(
//                                                 'Image deleted successfully');
//                                           } catch (e) {
//                                             showToastText(
//                                                 'Error deleting image: $e');
//                                           }
//                                           Navigator.pop(context);
//                                         },
//                                       ),
//                                       SizedBox(
//                                         width:   20,
//                                       ),
//                                       InkWell(
//                                         child: Padding(
//                                           padding:
//                                           EdgeInsets.all(  5.0),
//                                           child: Text(
//                                             "Okay",
//                                             style: TextStyle(
//                                                 color: Colors. black,
//                                                 fontSize:   20),
//                                           ),
//                                         ),
//                                         onTap: () {
//                                           setState(() {
//                                             PhotoUrlController.text = url;
//                                             _isImage = true;
//                                           });
//                                           Navigator.pop(context);
//                                         },
//                                       ),
//                                     ],
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                   )
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 if (widget.NewsId.length < 3)
//                   Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: Row(
//                       children: [
//                         Expanded(
//                             flex: 3,
//                             child: Text(
//                               "This is news for the whole college and branch.",
//                               style: TextStyle(color: Colors. black, fontSize: 20),
//                             )),
//                         Expanded(
//                           child: Switch(
//                             value: isSwitched,
//                             onChanged: (value) {
//                               setState(() {
//                                 isSwitched = value;
//                               });
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     InkWell(
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.grey[500],
//                           borderRadius: BorderRadius.circular(  15),
//                           border: Border.all(color: Colors. black),
//                         ),
//                         child: Padding(
//                           padding: EdgeInsets.only(
//                               left:   10,
//                               right:   10,
//                               top:   5,
//                               bottom:   5),
//                           child: Text("Back..."),
//                         ),
//                       ),
//                     ),
//                     InkWell(
//
//                       child: widget.NewsId.length < 3
//                           ? Container(
//                         decoration: BoxDecoration(
//                           color: Colors.grey[500],
//                           borderRadius:
//                           BorderRadius.circular(  15),
//                           border: Border.all(color: Colors. black),
//                         ),
//                         child: Padding(
//                           padding: EdgeInsets.only(
//                               left:   10,
//                               right:   10,
//                               top:   5,
//                               bottom:   5),
//                           child: Text("Create"),
//                         ),
//                       )
//                           : Container(
//                         decoration: BoxDecoration(
//                           color: Colors.grey[500],
//                           borderRadius:
//                           BorderRadius.circular(  15),
//                           border: Border.all(color: Colors. black),
//                         ),
//                         child: Padding(
//                           padding: EdgeInsets.only(
//                               left:   10,
//                               right:   10,
//                               top:   5,
//                               bottom:   5),
//                           child: Text("Update"),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       width:   15,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ));
//   }
// }
