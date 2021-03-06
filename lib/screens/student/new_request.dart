// Flutter Packages
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';

// Services
import '../../services/database.dart';

class NewRequest extends StatefulWidget {
  static const routeName = '/new-request';

  @override
  _NewRequestState createState() => _NewRequestState();
}

class _NewRequestState extends State<NewRequest> {
  final _formKey = GlobalKey<FormState>();

  String username;
  String uid;
  String imageUrl;

  final _descFocusNode = FocusNode();

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserID();
    fetchUserData();
  }

  fetchUserID() {
    uid = FirebaseAuth.instance.currentUser.uid;
    print(uid);
  }

  void fetchUserData() async {
    dynamic user = await DatabaseService()
        .getUserData(FirebaseAuth.instance.currentUser.uid);

    if (user == null) {
      setState(() {
        username = "Username";
        imageUrl = 'Image';
      });
    } else {
      setState(() {
        username = user.get(FieldPath(['username']));
        imageUrl = user.get(FieldPath(['imageUrl']));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.blue,
          title: Text(
            "New Request",
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Colors.white // add custom icons also
                ),
            onPressed: () {
              return showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(
                    'Discard new request?',
                  ),
                  content: Text(
                    'Changes will not be saved.',
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                        'No',
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                    FlatButton(
                      child: Text(
                        'Yes',
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop(false);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.white,
                // size: 26.0,
              ),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  DatabaseService()
                      .createRequestData(
                        DateTime.now().toString(),
                        uid,
                        username,
                        imageUrl,
                        _titleController.text,
                        _descController.text,
                        DateTime.now(),
                      )
                      .whenComplete(() => print('Added to Firestore'));

                  Navigator.of(context).pop(true);
                }
              },
            ),
          ],
        ),
        body: Container(
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          imageUrl != null
                              ? Container(
                                  width: 80.0,
                                  height: 80.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(imageUrl),
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 80.0,
                                  height: 80.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: AssetImage(
                                            'assets/img/default.jpg')),
                                  ),
                                ),
                          SizedBox(width: 15),
                          Text(
                            username,
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "Title",
                        ),
                        controller: _titleController,
                        validator: (val) =>
                            val.isEmpty ? 'Please enter a title' : null,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_descFocusNode);
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      child: TextFormField(
                        decoration:
                            InputDecoration.collapsed(hintText: "Description"),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        controller: _descController,
                        validator: (val) =>
                            val.isEmpty ? 'Please enter a description' : null,
                        focusNode: _descFocusNode,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
