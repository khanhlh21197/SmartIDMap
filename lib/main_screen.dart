import 'package:flutter/material.dart';
import 'package:smartid_map/helper/shared_prefs_helper.dart';
import 'package:smartid_map/home_page.dart';
import 'package:smartid_map/user_profile_page.dart';

class MainScreen extends StatefulWidget {
  final Map loginResponse;

  const MainScreen({Key key, this.loginResponse}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int quyen;
  SharedPrefsHelper sharedPrefsHelper;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = List();
  static List<BottomNavigationBarItem> bottomBarItems = List();

  @override
  void initState() {
    sharedPrefsHelper = SharedPrefsHelper();
    initBottomBarItems();
    initWidgetOptions();
    super.initState();
  }

  void initBottomBarItems() {
    bottomBarItems = [
      BottomNavigationBarItem(
        icon: Icon(
          Icons.home,
        ),
        label: 'Home',
      ),
      // BottomNavigationBarItem(
      //   icon: Icon(
      //     Icons.list,
      //   ),
      //   label: 'Chi tiết',
      // ),
      // BottomNavigationBarItem(
      //   icon: Icon(Icons.add),
      //   label: 'Thêm',
      // ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.account_box_outlined,
        ),
        label: 'Cá nhân',
      ),
    ];
  }

  void initWidgetOptions() {
    _widgetOptions = <Widget>[
      HomePage(),
      // DetailScreen(),
      // AddScreen(),
      UserProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
      bottomNavigationBar: bottomBar(),
    );
  }

  Widget buildBody() {
    print('_HomeScreenState.buildBody ${_widgetOptions.length}');
    return Container(
      child: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }

  Widget bottomBar() {
    return Theme(
      data: Theme.of(context).copyWith(
        // sets the background color of the `BottomNavigationBar`
        canvasColor: Colors.blue,
        // sets the active color of the `BottomNavigationBar` if `Brightness` is light
        primaryColor: Colors.red,
        textTheme: Theme.of(context).textTheme.copyWith(
              caption: new TextStyle(color: Colors.white),
            ),
      ),
      child: BottomAppBar(
        shape: CircularNotchedRectangle(),
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        child: BottomNavigationBar(
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: bottomBarItems,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
