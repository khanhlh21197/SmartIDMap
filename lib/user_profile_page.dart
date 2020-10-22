import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<StatefulWidget> {
  Widget _placeContainer(String title, Color color, bool leftIcon) {
    return Column(
      children: <Widget>[
        Container(
            height: 60,
            width: MediaQuery.of(context).size.width - 40,
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), color: color),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                      color: leftIcon ? Color(0xffa3a3a3) : Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
                leftIcon
                    ? Icon(
                        Icons.add,
                        color: Color(0xffa3a3a3),
                      )
                    : Container()
              ],
            ))
      ],
    );
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            // Text('Back',
            //     style: TextStyle(
            //         fontSize: 16,
            //         fontWeight: FontWeight.w500,
            //         color: Colors.white))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Positioned(top: 40, left: 0, child: _backButton()),
        SingleChildScrollView(
          child: Container(
            color: Color(0xffe7eaf2),
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(40.0, 40, 40, 70),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                // Container(
                //   width: MediaQuery.of(context).size.width,
                //   child: Text(
                //     'Thông tin',
                //     style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
                //   ),
                // ),
                // SizedBox(
                //   height: 50,
                // ),
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(75),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            offset: Offset(10, 15),
                            color: Color(0x22000000),
                            blurRadius: 20.0)
                      ],
                      image: DecorationImage(
                          image: NetworkImage(
                              'https://store.playstation.com/store/api/chihiro/00_09_000/container/US/en/999/UP1018-CUSA00133_00-AV00000000000015/1553561653000/image?w=256&h=256&bg_color=000000&opacity=100&_version=00_09_000'))),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'Khanh Le',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30,
                ),
                _placeContainer('lek21197@gmail.com', Color(0xff526fff), false),
                _placeContainer('0963003197', Color(0xff8f48ff), false),
                _placeContainer('Thêm tài khoản', Color(0xffffffff), true),
              ],
            ),
          ),
        )
      ],
    ));
  }
}
