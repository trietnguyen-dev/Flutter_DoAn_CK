import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytopzone/model/usermodel.dart';
import 'package:mytopzone/screens/homepage.dart';
import 'package:mytopzone/widgets/mybutton.dart';
import 'package:mytopzone/widgets/mytextformField.dart';
import 'package:mytopzone/widgets/notification_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel userModel;
  TextEditingController phoneNumber;
  TextEditingController address;
  TextEditingController userName;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static String p =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = new RegExp(p);
  bool isMale = false;
  void vaildation() async {
    if (userName.text.isEmpty && phoneNumber.text.isEmpty) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Tất cả thông tin đều trống"),
        ),
      );
    } else if (userName.text.isEmpty) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Tên còn trống "),
        ),
      );
    } else if (userName.text.length < 6) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Tên phải 6 chữ "),
        ),
      );
    } else if (phoneNumber.text.length < 11 || phoneNumber.text.length > 11) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Sổ điên thoại phải 11 số "),
        ),
      );
    } else {
      userDetailUpdate();
    }
  }

  File _pickedImage;

  PickedFile _image;
  Future<void> getImage({ImageSource source}) async {
    _image = await ImagePicker().getImage(source: source);
    if (_image != null) {
      setState(() {
        _pickedImage = File(_image.path);
      });
    }
  }

  String userUid;

  Future<String> _uploadImage({File image}) async {
    Reference storageReference =
        FirebaseStorage.instance.ref().child("UserImage/$userUid");
    UploadTask uploadTask = storageReference.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    return imageUrl;
  }

  void getUserUid() {
    User myUser = FirebaseAuth.instance.currentUser;
    userUid = myUser.uid;
  }

  bool centerCircle = false;
  var imageMap;
  void userDetailUpdate() async {
    setState(() {
      centerCircle = true;
    });
    _pickedImage != null
        ? imageMap = await _uploadImage(image: _pickedImage)
        : Container();
    FirebaseFirestore.instance.collection("User").doc(userUid).update({
      "UserName": userName.text,
      "UserGender": isMale == true ? "Nam" : "Nữ",
      "UserNumber": phoneNumber.text,
      "UserImage": imageMap,
      "UserAddress": address.text
    });
    setState(() {
      centerCircle = false;
    });
    setState(() {
      edit = false;
    });
  }

  Widget _buildSingleContainer(
      {Color color, String startText, String endText}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        height: 55,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: edit == true ? color : Colors.white,
          borderRadius: edit == false
              ? BorderRadius.circular(30)
              : BorderRadius.circular(0),
        ),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              startText,
              style: TextStyle(fontSize: 17, color: Colors.black45),
            ),
            Text(
              endText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String userImage;
  bool edit = false;
  Widget _buildContainerPart() {
    address = TextEditingController(text: userModel.userAddress);
    userName = TextEditingController(text: userModel.userName);
    phoneNumber = TextEditingController(text: userModel.userPhoneNumber);
    if (userModel.userGender == "Male") {
      isMale = true;
    } else {
      isMale = false;
    }
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSingleContainer(
            endText: userModel.userName,
            startText: "Tên",
          ),
          _buildSingleContainer(
            endText: userModel.userEmail,
            startText: "Email",
          ),
          _buildSingleContainer(
            endText: userModel.userGender,
            startText: "Giới tính",
          ),
          _buildSingleContainer(
            endText: userModel.userPhoneNumber,
            startText: "Số điện thoại",
          ),
          _buildSingleContainer(
            endText: userModel.userAddress,
            startText: "Địa chỉ",
          ),
        ],
      ),
    );
  }

  Future<void> myDialogBox(context) {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text("Chụp ngay"),
                    onTap: () {
                      getImage(source: ImageSource.camera);
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text("Lấy từ thư mục ảnh"),
                    onTap: () {
                      getImage(source: ImageSource.gallery);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildTextFormFliedPart() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MyTextFormField(
            name: "Tên",
            controller: userName,
          ),
          _buildSingleContainer(
            color: Colors.grey[300],
            endText: userModel.userEmail,
            startText: "Email",
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isMale = !isMale;
              });
            },
            child: _buildSingleContainer(
              color: Colors.white,
              endText: isMale == true ? "Nam" : "Nữ",
              startText: "Giới tính",
            ),
          ),
          MyTextFormField(
            name: "Số điện thoại",
            controller: phoneNumber,
          ),
          MyTextFormField(
            name: "Địa chỉ",
            controller: address,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    getUserUid();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      backgroundColor: Color(0xfff8f8f8),
      appBar: AppBar(
        leading: edit == true
            ? IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.redAccent,
                  size: 30,
                ),
                onPressed: () {
                  setState(() {
                    edit = false;
                  });
                },
              )
            : IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black45,
                  size: 30,
                ),
                onPressed: () {
                  setState(() {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (ctx) => HomePage(),
                      ),
                    );
                  });
                },
              ),
        backgroundColor: Colors.white,
        actions: [
          edit == false
              ? NotificationButton()
              : IconButton(
                  icon: Icon(
                    Icons.check,
                    size: 30,
                    color: Color(0xff746bc9),
                  ),
                  onPressed: () {
                    vaildation();
                  },
                ),
        ],
      ),
      body: centerCircle == false
          ? ListView(
              children: [
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("User")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      var myDoc = snapshot.data.docs;
                      myDoc.forEach((checkDocs) {
                        if (checkDocs.data()["UserId"] == userUid) {
                          userModel = UserModel(
                            userEmail: checkDocs.data()["UserEmail"],
                            userImage: checkDocs.data()["UserImage"],
                            userAddress: checkDocs.data()["UserAddress"],
                            userGender: checkDocs.data()["UserGender"],
                            userName: checkDocs.data()["UserName"],
                            userPhoneNumber: checkDocs.data()["UserNumber"],
                          );
                        }
                      });
                      return Container(
                        height: 603,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                          maxRadius: 65,
                                          backgroundImage: _pickedImage == null
                                              ? userModel.userImage == ""
                                                  ? AssetImage(
                                                      "images/userImage.png")
                                                  : NetworkImage(
                                                      userModel.userImage)
                                              : FileImage(_pickedImage)),
                                    ],
                                  ),
                                ),
                                edit == true
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .viewPadding
                                                    .left +
                                                220,
                                            top: MediaQuery.of(context)
                                                    .viewPadding
                                                    .left +
                                                110),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              myDialogBox(context);
                                            },
                                            child: CircleAvatar(
                                              backgroundColor:
                                                  Colors.transparent,
                                              child: Icon(
                                                Icons.camera_alt,
                                                color: Color(0xff746bc9),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                            Container(
                              height: 350,
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: edit == true
                                          ? _buildTextFormFliedPart()
                                          : _buildContainerPart(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20)),
                                child: edit == false
                                    ? MyButton(
                                        name: "Chỉnh sửa thông tin",
                                        onPressed: () {
                                          setState(() {
                                            edit = true;
                                          });
                                        },
                                      )
                                    : Container(),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
