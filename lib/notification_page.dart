import 'package:flutter/material.dart';
import 'package:smartid_map/model/notification.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> notifications;

  @override
  void initState() {
    notifications = [
      NotificationItem('Học sinh đã lên xe', '24/02/2021 7h30'),
      NotificationItem('Học sinh đã xuống xe', '24/02/2021 8h00'),
      NotificationItem('Học sinh đã lên xe', '25/02/2021 17h00'),
      NotificationItem('Học sinh đã xuống xe', '25/02/2021 17h30'),
      NotificationItem('Học sinh đã lên xe', '26/02/2021 7h30'),
      NotificationItem('Học sinh đã xuống xe', '26/02/2021 8h00'),
      NotificationItem('Học sinh đã lên xe', '27/02/2021 17h00'),
      NotificationItem('Học sinh đã xuống xe', '27/02/2021 17h30'),
      NotificationItem('Học sinh đã lên xe', '28/02/2021 7h30'),
      NotificationItem('Học sinh đã xuống xe', '28/02/2021 8h00'),
      NotificationItem('Học sinh đã lên xe', '01/03/2021 17h00'),
      NotificationItem('Học sinh đã xuống xe', '01/03/2021 17h30'),
      NotificationItem('Học sinh đã lên xe', '02/03/2021 7h30'),
      NotificationItem('Học sinh đã xuống xe', '02/03/2021 8h00'),
      NotificationItem('Học sinh đã lên xe', '03/03/2021 17h00'),
      NotificationItem('Học sinh đã xuống xe', '03/03/2021 17h30'),
      NotificationItem('Học sinh đã lên xe', '04/03/2021 7h30'),
      NotificationItem('Học sinh đã xuống xe', '04/03/2021 8h00'),
      NotificationItem('Học sinh đã lên xe', '05/03/2021 17h00'),
      NotificationItem('Học sinh đã xuống xe', '05/03/2021 17h30'),
      NotificationItem('Học sinh đã lên xe', '06/03/2021 7h30'),
      NotificationItem('Học sinh đã xuống xe', '06/03/2021 8h00'),
      NotificationItem('Học sinh đã lên xe', '07/03/2021 17h00'),
      NotificationItem('Học sinh đã xuống xe', '07/03/2021 17h30'),
      NotificationItem('Học sinh đã lên xe', '08/03/2021 7h30'),
      NotificationItem('Học sinh đã xuống xe', '08/03/2021 8h00'),
      NotificationItem('Học sinh đã lên xe', '09/03/2021 17h00'),
      NotificationItem('Học sinh đã xuống xe', '09/03/2021 17h30'),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông báo'),
        centerTitle: true,
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return Container(
      child: ListView.separated(
        itemCount: notifications.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              '${notifications[index].title}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('${notifications[index].body}'),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
      ),
    );
  }
}
