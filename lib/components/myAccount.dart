import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../api/api.dart';

Api api = Api();
User curUser = new User();

class FireBaseFireStoreDemo extends StatefulWidget {
  FireBaseFireStoreDemo() : super();
  final String title = "My Account";

  @override
  FireBaseFireStoreDemoState createState() => FireBaseFireStoreDemoState();
}

class FireBaseFireStoreDemoState extends State<FireBaseFireStoreDemo> {
  bool showText = false;
  TextEditingController controller = TextEditingController();
  bool isEditing = false;
  User user;

  add() {
    if (isEditing) {
      //Update
      api.update(user, controller.text);
      setState(() {
        isEditing = false;
      });
    } else {
      api.addUsers(controller.text);
    }
    controller.text = '';
  }

  Widget buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: api.getUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }
        if (snapshot.hasData) {
          print("Documents ${snapshot.data.documents.length}");
          return buildList(context, snapshot.data.documents);
        }
        return CircularProgressIndicator();
      },
    );
  }

  Widget buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      children: snapshot.map((data) => buildListItem(context, data)).toList(),
    );
  }

  Widget buildListItem(BuildContext context, DocumentSnapshot data) {
    final user = User.fromSnapshot(data);
    return Padding(
        key: ValueKey(user.name),
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: ListTile(
            title: Text(
              user.name,
              style: TextStyle(color: Colors.white),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.white,
              ),
              onPressed: () {
                api.delete(user);
              },
            ),
            onTap: () {
              setUpdateUI(user);
            },
          ),
        ));
  }

  setUpdateUI(User user) {
    controller.text = user.name;
    setState(() {
      showText = true;
      isEditing = true;
      curUser = user;
    });
  }

  button() {
    return SizedBox(
      width: double.infinity,
      child: OutlineButton(
        child: Text(
          isEditing ? "UPDATE" : "ADD",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          add();
          setState(() {
            showText = false;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                showText = !showText;
              });
            },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            showText
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: controller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            labelText: "Name", hintText: "Enter name"),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      button(),
                    ],
                  )
                : Container(),
            SizedBox(
              height: 20,
            ),
            Text(
              "My Account",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white),
            ),
            SizedBox(
              height: 10,
            ),
            Flexible(
              child: buildBody(context),
            )
          ],
        ),
      ),
    );
  }
}
