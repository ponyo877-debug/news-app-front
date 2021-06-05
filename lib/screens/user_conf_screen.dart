import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserConfScreen extends StatefulWidget {
  const UserConfScreen({Key key}) : super(key: key);

  @override
  _UserConfScreen createState() => _UserConfScreen();
}

class _UserConfScreen extends State<UserConfScreen> {
  bool _isEdit = false;
  Future<String> _future;
  String NameData = "";

  @override
  void initState() {
    super.initState();
    _future = _getNameData();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        margin: EdgeInsets.only(top: 100),
        height: 350,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      Align(
          alignment: Alignment.topCenter,
          child: FutureBuilder(
            future: _future,
    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
    if (!snapshot.hasData) {
      return Center(child: CircularProgressIndicator());
    } else {
      var _controller = TextEditingController(text: NameData.isEmpty ? snapshot.data : NameData);
      return Column(
            children: [
              CircleAvatar(
              radius: 100.0,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                      radius: 20.0,
                    child: Icon(
                      Icons.camera_alt,
                      size: 40.0,
                      color: Color(0xFF404040),
                    ),
                  ),
                ),
                radius: 90.0,
                backgroundImage: NetworkImage(
                    'https://img.gitouhon-juku-k8s2.ga/default_0.jpg'),
              ),
            ),
              Center(
                child:
                Container(
                  padding: EdgeInsets.only(top: 16.0),
                  child: _isEdit ? TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    autofocus: true,
                    maxLength: 10,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w700,
                      fontSize: 50.0,
                    ),
                  ) :
                  Text(
                    NameData.isEmpty ? snapshot.data : NameData,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w700,
                      fontSize: 50.0,
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: TextButton(
                    onPressed: () {
                      print('押した');
                      print(_isEdit);
                      setState(() {
                        if (_isEdit) {
                          print("aaaa");
                          NameData = _controller.text;
                          updateNameData(NameData);
                        }
                        _isEdit = !_isEdit;
                      });
                    },
                    child: Container(
                      padding:
                      EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFEF476F),
                        borderRadius:
                        BorderRadius.all(Radius.circular(20.0)),
                      ),
                      child: Text(
                        _isEdit ? 'Update Name' : 'Edit Name',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 25.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ]);
    }
    },),
    ),
    ]);
  }

  Future<String> _getNameData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var myStringData = await prefs.getString("Name");
    print("Name: " + myStringData);
    return myStringData;
  }

  updateNameData(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("Name", name);
    print("UpdateName: " + name);
  }
}
