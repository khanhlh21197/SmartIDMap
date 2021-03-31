import 'package:flutter/material.dart';
import 'package:smartid_map/helper/shared_prefs_helper.dart';
import 'package:smartid_map/home_page.dart';
import 'package:smartid_map/notification_page.dart';
import 'package:smartid_map/ui/add_ui/add_page.dart';
import 'package:smartid_map/ui/add_ui/add_student_page.dart';
import 'package:smartid_map/ui/history_page.dart';
import 'package:smartid_map/ui/manage_page/manage_screen.dart';
import 'package:smartid_map/user_profile_page.dart';

class MainScreen extends StatefulWidget {
  final Map loginResponse;
  final int quyen;

  const MainScreen({Key key, this.loginResponse, this.quyen}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const adminBottomBarItems = [
    BottomNavigationBarItem(
      icon: Icon(
        Icons.error,
      ),
      label: 'Quản lý',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.notifications),
      label: 'Thông báo',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.add),
      label: 'Thêm',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.access_time),
      label: 'Lịch sử',
    ),
    BottomNavigationBarItem(
      icon: Icon(
        Icons.account_box_outlined,
      ),
      label: 'Cá nhân',
    ),
  ];

  static const userBottomBarItems = [
    BottomNavigationBarItem(
      icon: Icon(
        Icons.home,
      ),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.notifications),
      label: 'Thông báo',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.add),
      label: 'Thêm',
    ),
    BottomNavigationBarItem(
      icon: Icon(
        Icons.account_box_outlined,
      ),
      label: 'Cá nhân',
    ),
  ];

  int _selectedIndex = 0;
  SharedPrefsHelper sharedPrefsHelper;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = List();
  static List<BottomNavigationBarItem> bottomBarItems = List();

  @override
  void initState() {
    print('_MainScreenState.initState ${widget.quyen}');
    sharedPrefsHelper = SharedPrefsHelper();
    initBottomBarItems();
    initWidgetOptions();
    super.initState();
  }

  void initBottomBarItems() {
    switch (widget.quyen) {
      case 1:
        bottomBarItems = adminBottomBarItems;
        break;
      case 2:
        bottomBarItems = userBottomBarItems;
        break;
    }
  }

  void initWidgetOptions() {
    switch (widget.quyen) {
      case 1:
        _widgetOptions = <Widget>[
          ManageScreen(),
          NotificationScreen(),
          AddScreen(),
          HistoryScreen(),
          UserProfilePage(
            switchValue: false,
          ),
        ];
        break;
      case 2:
        _widgetOptions = <Widget>[
          HomePage(),
          NotificationScreen(),
          AddStudentScreen(
            isParent: true,
          ),
          UserProfilePage(
            switchValue: true,
          ),
        ];
        break;
    }
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
