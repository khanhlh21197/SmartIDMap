import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class MultipleDatePicker extends StatefulWidget {
  final Function(dynamic) datePickerCallback;

  const MultipleDatePicker({Key key, this.datePickerCallback})
      : super(key: key);

  @override
  MultipleDatePickerState createState() => MultipleDatePickerState();
}

/// State for MyApp
class MultipleDatePickerState extends State<MultipleDatePicker> {
  String _selectedDate;
  String _dateCount;
  String _range;
  String _rangeCount;
  var selectionMode;
  List<DateTime> dates;

  @override
  void initState() {
    _selectedDate = '';
    _dateCount = '';
    _range = '';
    _rangeCount = '';
    selectionMode = DateRangePickerSelectionMode.multiple;
    super.initState();
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    _selectedDate = '';
    _dateCount = '';
    _range = '';
    _rangeCount = '';
    dates = List();
    if (args.value is PickerDateRange) {
      _range =
          DateFormat('dd/MM/yyyy').format(args.value.startDate).toString() +
              ' - ' +
              DateFormat('dd/MM/yyyy')
                  .format(args.value.endDate ?? args.value.startDate)
                  .toString();
    } else if (args.value is DateTime) {
      _selectedDate = '${DateFormat('dd/MM/yyyy').format(args.value)}';
      dates.add(args.value);
    } else if (args.value is List<DateTime>) {
      _dateCount = args.value.length.toString();
      dates = args.value;
    } else {
      dates = args.value;
      _rangeCount = args.value.length.toString();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text('Chọn ngày nghỉ'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Ngày đã chọn: ${_selectedDate != '' ? _selectedDate : _range}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Số ngày đã chọn: ${_dateCount != '' ? _dateCount : _rangeCount}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            chooseTypeOfCalendar(),
            SfDateRangePicker(
              showNavigationArrow: true,
              onSelectionChanged: _onSelectionChanged,
              selectionMode: selectionMode,
              initialSelectedRange: PickerDateRange(
                  DateTime.now().subtract(const Duration(days: 4)),
                  DateTime.now().add(const Duration(days: 3))),
            ),
            actionButton(),
          ],
        ),
      ),
    );
  }

  Widget chooseTypeOfCalendar() {
    return Container(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FlatButton(
                onPressed: () {
                  selectionMode = DateRangePickerSelectionMode.single;
                  setState(() {});
                },
                child: Text('Chọn một ngày'),
                color: selectionMode == DateRangePickerSelectionMode.single
                    ? Colors.green
                    : Colors.blue,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FlatButton(
                onPressed: () {
                  selectionMode = DateRangePickerSelectionMode.multiple;
                  setState(() {});
                },
                child: Text('Chọn nhiều ngày'),
                color: selectionMode == DateRangePickerSelectionMode.multiple
                    ? Colors.green
                    : Colors.blue,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FlatButton(
                onPressed: () {
                  selectionMode = DateRangePickerSelectionMode.range;
                  setState(() {});
                },
                child: Text('Chọn ngày liên tiếp'),
                color: selectionMode == DateRangePickerSelectionMode.range
                    ? Colors.green
                    : Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget actionButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: FlatButton(
              onPressed: () {
                widget.datePickerCallback(dates);
                Navigator.of(context).pop();
              },
              child: Text('Đồng ý'),
              color: Colors.blue,
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
