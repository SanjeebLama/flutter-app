import 'package:flutter/material.dart';
// import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'loader.dart';

class DetailPage extends StatefulWidget {
  final List img;
  DetailPage(this.img);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = new List<Widget>();
    widget.img.forEach((element) {
      children.add(
        InteractiveViewer(
          maxScale: 4.0,
          child: Container(
            // padding: EdgeInsets.only(top: 14.0),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Image.network(
              element,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                return loadingProgress == null
                    ? child
                    : Center(
                        child: ColorLoader(),
                      );
              },
            ),
          ),
        ),
      );
    });
    return PageView(
      children: children,
    );
  }
}
