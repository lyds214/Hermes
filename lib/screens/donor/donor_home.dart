// Flutter Packages
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Screens
import './donor_request_tile.dart';

// Services
import '../../services/database.dart';

// Widgets
import '../../widgets/graphics.dart';
import '../../widgets/loading.dart';

class DonorHome extends StatefulWidget {
  @override
  _DonorHomeState createState() => _DonorHomeState();
}

class _DonorHomeState extends State<DonorHome> {
  Stream requests;
  Stream searchResults;

  bool isSearching = false;
  TextEditingController searchField = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  fetchRequests() async {
    await DatabaseService().getRequestsData().then((results) {
      setState(() {
        requests = results;
      });
    });
  }

  onSearchButtonClicked() async {
    await DatabaseService().getRequestsByTitle(searchField.text).then((value) {
      searchResults = value;
      setState(() {
        isSearching = true;
      });
    });
  }

  helpDialog() {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Welcome to Hermes!',
        ),
        content: Text(
          'Click on a request to view and send a message if you can donate.',
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Close',
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final AppBar appBar = AppBar(
      elevation: 0.0,
      leading: SmallLogo(50),
      title: Text(
        'Available Requests',
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.help,
          ),
          onPressed: helpDialog,
        ),
      ],
    );

    Widget searchBar = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          /// Only display arrow back icon when user is searching
          isSearching
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      isSearching = false;
                      searchField.text = "";
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 12.0,
                    ),
                    child: Icon(Icons.arrow_back),
                  ),
                )
              : Container(),

          /// Textfield for searching for a user
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(
                vertical: 16,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  /// Search by UserName textfield
                  Expanded(
                    child: TextField(
                      controller: searchField,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search by title',
                      ),
                    ),
                  ),

                  /// Gesture Detection logic when search icon is tapped
                  IconButton(
                    onPressed: () async {
                      if (searchField.text.isNotEmpty) {
                        onSearchButtonClicked();
                      } else {
                        print('Textfield is empty');
                      }
                    },
                    icon: Icon(Icons.search),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    Widget requestList = Container(
        height: (mediaQuery.size.height -
            appBar.preferredSize.height -
            mediaQuery.padding.top),
        padding: const EdgeInsets.only(bottom: 50),
        child: StreamBuilder(
            stream: requests,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                    child: Text(
                        'Snapshot Error receiving existing requests from donor home view'));
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.data.docs.length == 0) {
                  return Center(
                    child: Text(
                      'No requests available',
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot request = snapshot.data.docs[index];
                    return DonorRequestTile(request);
                  },
                );
              } else {
                return Text('');
              }
            }));

    Widget searchList = Container(
        height: (mediaQuery.size.height -
            appBar.preferredSize.height -
            mediaQuery.padding.top),
        padding: const EdgeInsets.only(bottom: 50),
        child: StreamBuilder(
            stream: searchResults,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                    child: Text(
                        'Snapshot Error receiving searched requests from donor home view'));
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Loading();
              } else if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.data.docs.length == 0) {
                  return Expanded(
                      child: Center(child: Text("No requests found")));
                }
                return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot request = snapshot.data.docs[index];
                    return DonorRequestTile(request);
                  },
                );
              } else {
                return Text('');
              }
            }));

    final pageBody = SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              searchBar,
              isSearching ? searchList : requestList,
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: pageBody,
      backgroundColor: Theme.of(context).primaryColor,
    );
  }
}
