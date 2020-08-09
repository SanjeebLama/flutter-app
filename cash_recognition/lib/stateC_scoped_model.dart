import 'package:scoped_model/scoped_model.dart';

class StateChangeModel extends Model {
  String initTitle = "Click to take Picture of Cash? ";

  bool _clickPicture = false;

  get clickPicture {
    print("Inside GETTER");
    return _clickPicture;
  }

  set clickPicture(bool value) {
    print("Inside SETTER");

    _clickPicture = value;
    notifyListeners();
  }
}
