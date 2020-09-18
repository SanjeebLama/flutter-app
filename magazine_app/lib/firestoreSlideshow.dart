import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detailPage.dart';

class FirestoreSlideshow extends StatefulWidget {
  @override
  _FirestoreSlideshowState createState() => _FirestoreSlideshowState();
}

class _FirestoreSlideshowState extends State<FirestoreSlideshow> {
  final PageController ctrl = PageController(viewportFraction: 0.8);

  final Firestore db = Firestore.instance;

  Stream slides;

  String activeTag = 'new';

  // Keep track of current page to avoid unnecessary renders
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _queryDb();

// Set state when page changes
    ctrl.addListener(() {
      int next = ctrl.page.round();
      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: slides,
          initialData: [],
          builder: (context, AsyncSnapshot snap) {
            List slideList = snap.data.toList();

            return PageView.builder(
                controller: ctrl,
                itemCount: slideList.length + 1,
                // ignore: missing_return
                itemBuilder: (context, int currentIdx) {
                  if (currentIdx == 0) {
                    return _buildTagPage();
                  } else if (slideList.length >= currentIdx) {
                    // Active page
                    bool active = currentIdx == currentPage;
                    return _buildStoryPage(slideList[currentIdx - 1], active);
                  }
                });
          }),
    );
  }

  void _queryDb({String tag = 'DamiUpdate'}) {
    // Make a Query
    Query query = db.collection('magazines').where('tags', arrayContains: tag);

    // Map the documents to the data payload
    slides =
        query.snapshots().map((list) => list.documents.map((doc) => doc.data));

    // Update the active tag
    setState(() {
      activeTag = tag;
    });
  }

//Builder Functions
  _buildStoryPage(Map data, bool active) {
    // Animated Properties
    final double blur = active ? 30 : 0;
    final double offset = active ? 20 : 0;
    final double top = active ? 100 : 200;

    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DetailPage(data['img'])));
      },
      child: Container(
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOutQuint,
          margin: EdgeInsets.only(top: top, bottom: 50, right: 30),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  data['cover'],
                ),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black87,
                    blurRadius: blur,
                    offset: Offset(offset, offset))
              ]),
          child: Center(
            child: Text(
              data['title'],
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  _buildTagPage() {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dami Hami',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text('FILTER', style: TextStyle(color: Colors.black26)),
        _buildButton('DamiUpdate'),
        _buildButton('PreviousIssues'),
        // _buildButton('new')
      ],
    ));
  }

  _buildButton(tag) {
    Color color = tag == activeTag ? Colors.purpleAccent : Colors.white;
    return FlatButton(
        color: color,
        child: Text('#$tag'),
        onPressed: () => _queryDb(tag: tag));
  }
}
