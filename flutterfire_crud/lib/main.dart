// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text("Flutter Fire CRUD")),
        // body: GetUserName("Hc5kYd8KvBzVcQSEa9mH"),
        // body: UserInformation(),
        body: ListPage(),
      ),
    );
  }
}

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  Future _data;
  Future getUsers() async {
    var firestore = Firestore.instance;
    firestore.collection("users").getDocuments();
    QuerySnapshot qn = await firestore.collection("users").getDocuments();
    return qn.documents;
  }

  navigateToDetail(DocumentSnapshot users) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => DetailList(users: users)));
  }

  @override
  void initState() {
    super.initState();

    _data = getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading ...");
          } else {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return ListTile(
                    title: Text(snapshot.data[index].data['name']),
                    onTap: () {
                      navigateToDetail(snapshot.data[index]);
                    });
              },
            );
          }
        },
      ),
    );
  }
}
//Get document according to specific ID - StreamBuilder
// class GetUserName extends StatelessWidget {
//   final String documentId;

//   GetUserName(this.documentId);

//   @override
//   Widget build(BuildContext context) {
//     CollectionReference users = Firestore.instance.collection('users');

//     return FutureBuilder<DocumentSnapshot>(
//       future: users.document(documentId).get(),
//       builder:
//           (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//         if (snapshot.hasError) {
//           return Text("Something went wrong");
//         }

//         if (snapshot.connectionState == ConnectionState.done) {
//           // Map<String, dynamic> data = snapshot.data.data();
//           // return Text("Name: ${data['name']} ${data['job']}");
//         }

//         return Text("loading");
//       },
//     );
//   }
// }

//Get information using stream builder
class UserInformation extends StatelessWidget {
  BuildContext get context => null;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("users").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }
          return PageView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.network(
                        snapshot.data.documents.elementAt(index)['img']),
                    Text(snapshot.data.documents.elementAt(index)["name"]),
                    Text(snapshot.data.documents.elementAt(index)["job"]),
                  ],
                );
              });
        });
  }
}

class DetailList extends StatefulWidget {
  final DocumentSnapshot users;

  DetailList({Key key, @required this.users}) : super(key: key);
  @override
  _DetailListState createState() => _DetailListState();
}

class _DetailListState extends State<DetailList> {
  // int _count() {
  //   List<String> tags = widget.users.data["tags"];
  //   int count = tags.length;
  //   return count;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.users.data['name']}"),
      ),
      body: ListView(
        children: [
          Column(children: [
            Container(
              height: MediaQuery.of(context).size.height / 3.0,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Image.network(widget.users.data["img"]),
              ),
            ),
            Container(
              child: Card(
                child: ListTile(
                  title: Text(widget.users.data["name"]),
                  subtitle: Text("Age:" + widget.users.data["job"]),
                ),
              ),
            ),
            Container(
                height: 500.0, child: ArrayView(widget.users.data["skills"])),
          ]),
        ],
      ),
    );
  }
}

class ArrayView extends StatelessWidget {
  final List skills;
  ArrayView(this.skills);
  @override
  Widget build(BuildContext context) {
    List<Widget> children = new List<Widget>();
    skills.forEach((element) {
      children.add(Text(element));
    });
    return ListView(
      children: children,
    );
  }
}
