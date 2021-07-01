import 'package:account_book/calendar/event.dart';
import 'package:account_book/sqlite/accountmodel.dart';
import 'package:account_book/sqlite/dbhelper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

class MyCalendar extends StatefulWidget {
  const MyCalendar({Key? key}) : super(key: key);

  @override
  _MyCalendarState createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> {
  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  DBHelper sd1 = DBHelper(tablename: 'inAccount', dbname: 'inAccountdb');
  DBHelper sd2 = DBHelper(tablename: 'outAccount', dbname: 'outAccountdb');
  late Map<DateTime, List<Event>> _events;

  TextEditingController _eventController = TextEditingController();

  @override
  void initState() {
    _events = {};
    // TODO: implement initState
    super.initState();
    _fetchEvents1();
    _fetchEvents2();
  }

  List<Event> _getEventsfromDay(DateTime date) {
    return _events[date] ?? [];
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          '달력',
          style: GoogleFonts.doHyeon(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              focusedDay: selectedDay,
              firstDay: DateTime(1997),
              lastDay: DateTime(2050),
              calendarFormat: format,
              onFormatChanged: (CalendarFormat _format) {
                setState(() {
                  format = _format;
                });
              },

              //날짜 바꾸기
              startingDayOfWeek: StartingDayOfWeek.sunday,
              daysOfWeekVisible: true,
              onDaySelected: (DateTime selectDay, DateTime focusDay) {
                setState(() {
                  selectedDay = selectDay;
                  focusedDay = focusDay;
                });
              },
              selectedDayPredicate: (DateTime date) {
                return isSameDay(selectedDay, date);
              },
              eventLoader: _getEventsfromDay,

              //달력 스타일
              calendarStyle: CalendarStyle(
                  isTodayHighlighted: true,
                  selectedDecoration: BoxDecoration(
                      color: Colors.brown[200], shape: BoxShape.circle),
                  selectedTextStyle: TextStyle(color: Colors.white),
                  todayDecoration: BoxDecoration(
                    color: Colors.deepPurple[200],
                    shape: BoxShape.circle,
                  )),
              headerStyle:
                  HeaderStyle(formatButtonVisible: false, titleCentered: true),
            ),
            ..._getEventsfromDay(selectedDay).map((Event event) {
              return Column(
                children: [
                  ListTile(
                      title: Row(
                    children: [
                      Text(
                        event.title2,
                        style: GoogleFonts.doHyeon(
                            fontSize: 20.0, color: Colors.deepPurple[300]),
                      ),
                      Text(
                        event.title1,
                        style: GoogleFonts.doHyeon(
                            fontSize: 20.0, color: Colors.black54),
                      ),
                      Text(
                        event.title3,
                        style: GoogleFonts.doHyeon(
                            fontSize: 20.0, color: Colors.black54),
                      ),
                    ],
                  )),
                  Divider(
                    indent: 10.0,
                    height: 5.0,
                    thickness: 3.0,
                    endIndent: 10.0,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _fetchEvents1() async {
    _events = {};
    List<Account> _results = await sd1.accounts(
        'uid = ?', '${FirebaseAuth.instance.currentUser!.uid.toString()}');
    _results.forEach((element) {
      DateTime formattedDate = DateTime.parse('${element.date} 00:00:00.000Z');
      if (_events[formattedDate] != null) {
        _events[formattedDate]!.add(Event(
            title1: '${element.money}원  ',
            title2: '수입  ',
            title3: '${element.content}'));
      } else {
        _events[formattedDate] = [
          Event(
              title1: '${element.money}원  ',
              title2: '수입  ',
              title3: '${element.content}')
        ];
      }
    });
    setState(() {});
  }

  void _fetchEvents2() async {
    _events = {};
    List<Account> _results = await sd2.accounts(
        'uid = ?', '${FirebaseAuth.instance.currentUser!.uid.toString()}');
    _results.forEach((element) {
      DateTime formattedDate = DateTime.parse('${element.date} 00:00:00.000Z');
      if (_events[formattedDate] != null) {
        _events[formattedDate]!.add(Event(
            title1: '${element.money}원  ',
            title2: '지출  ',
            title3: '${element.content}'));
      } else {
        _events[formattedDate] = [
          Event(
              title1: '${element.money}원  ',
              title2: '지출  ',
              title3: '${element.content}')
        ];
      }
    });
    setState(() {});
  }
}
