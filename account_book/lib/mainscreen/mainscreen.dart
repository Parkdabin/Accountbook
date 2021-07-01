import 'dart:async';
import 'package:account_book/calendar/calendar.dart';
import 'package:account_book/contentsearch/contentsearch.dart';
import 'package:account_book/message/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:account_book/income/income.dart';
import 'package:account_book/expenditure/expenditure.dart';
import 'package:intl/intl.dart';
import 'package:account_book/sqlite/dbhelper.dart';
import 'package:account_book/sqlite/accountmodel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DBHelper sd1 = DBHelper(tablename: 'inAccount', dbname: 'inAccountdb');
  DBHelper sd2 = DBHelper(tablename: 'outAccount', dbname: 'outAccountdb');
  var date = DateFormat("yyyy/MM/dd").format(DateTime.now());
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  late Future<List<Account>> _loadinlist;
  late Future<List<Account>> _loadoutlist;

  Future<void> getName() async {
    var documentsnapshot =
        await users.doc(FirebaseAuth.instance.currentUser!.uid).get();
    return documentsnapshot.get('name');
  }

  @override
  Future<void> refreshinList() async {
    setState(() {
      _loadinlist = loadinAccount();
    });
  }

  Future<void> refreshoutList() async {
    setState(() {
      _loadoutlist = loadoutAccount();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadoutlist = loadoutAccount();
    _loadinlist = loadinAccount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.brown[20],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, right: 10.0),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Text(
                  '${snapshot.data!.get('name')}님 환영합니다.',
                  style: GoogleFonts.doHyeon(
                      fontSize: 20.0, color: Colors.grey[600]),
                );
              },
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: Center(
                child: Text(
                  'MENU',
                  style: GoogleFonts.doHyeon(
                    fontSize: 23.0,
                  ),
                ),
              ),
              accountName: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return Text('${snapshot.data!.get('name')}',
                        style: GoogleFonts.doHyeon(
                          color: Colors.grey[600],
                        ));
                  }),
              accountEmail: Text(
                '${FirebaseAuth.instance.currentUser!.email}',
                style: GoogleFonts.doHyeon(color: Colors.grey[600]),
              ),
              onDetailsPressed: () {
                print('arrow is clicked');
              },
              decoration: BoxDecoration(
                  color: Colors.brown[50],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40.0),
                    bottomRight: Radius.circular(40.0),
                  )),
            ),
            ListTile(
                leading: Icon(
                  Icons.calendar_today,
                  color: Colors.grey[800],
                ),
                title: Text(
                  '달력',
                  style: GoogleFonts.doHyeon(
                    fontSize: 17.0,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyCalendar()));
                }),
            ListTile(
                leading: Icon(
                  Icons.search,
                  color: Colors.grey[800],
                ),
                title: Text(
                  '지출/수입 내역 검색',
                  style: GoogleFonts.doHyeon(
                    fontSize: 17.0,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ContentSearch()));
                }),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.grey[800],
              ),
              title: Text(
                '로그아웃',
                style: GoogleFonts.doHyeon(
                  fontSize: 17.0,
                ),
              ),
              onTap: () {
                FirebaseAuth.instance.signOut();
              },
            )
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 40.0,
            ),
            Column(
              children: [
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Text('${snapshot.data!.get('lemoney')}원',
                          style: GoogleFonts.doHyeon(
                            fontSize: 35.0,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ));
                    }),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        date,
                        style: GoogleFonts.doHyeon(
                            fontSize: 19.0, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Divider(
                  indent: 10.0,
                  color: Colors.brown[300],
                  height: 25.0,
                  thickness: 3.0,
                  endIndent: 10.0,
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      '수입 내역',
                      style: GoogleFonts.doHyeon(
                          fontSize: 20.0, color: Colors.green[400]),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        sd1.deleteAccount(
                            FirebaseAuth.instance.currentUser!.uid);
                        FToast(content: '초기화 되었습니다.');
                        setState(() {});
                      },
                      child: Icon(Icons.reset_tv),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent,
                        elevation: 0.0,
                        onPrimary: Colors.black,
                      ),
                    ),
                    Text(
                      '지출 내역',
                      style: GoogleFonts.doHyeon(
                          fontSize: 20.0, color: Colors.red[400]),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        sd2.deleteAccount(
                            FirebaseAuth.instance.currentUser!.uid);
                        FToast(content: '초기화 되었습니다.');
                        setState(() {});
                      },
                      child: Icon(Icons.reset_tv),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent,
                        elevation: 0.0,
                        onPrimary: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      width: 170.0,
                      height: 250.0,
                      child: FutureBuilder(
                        future: _loadinlist,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Account>> snapshot) {
                          if (snapshot.hasData) {
                            return Scrollbar(
                              child: RefreshIndicator(
                                child: ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  itemBuilder:
                                      (BuildContext context, int position) {
                                    return Row(
                                      children: [
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, top: 4.0),
                                            child: Text.rich(
                                              TextSpan(children: [
                                                TextSpan(
                                                    text:
                                                        '${snapshot.data![position].date}  ',
                                                    style:
                                                        GoogleFonts.doHyeon()),
                                                TextSpan(
                                                    text:
                                                        '${snapshot.data![position].money}원  ',
                                                    style: GoogleFonts.doHyeon(
                                                        color:
                                                            Colors.green[400])),
                                                TextSpan(
                                                    text:
                                                        '${snapshot.data![position].content}',
                                                    style:
                                                        GoogleFonts.doHyeon())
                                              ]),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                onRefresh: refreshinList,
                              ),
                            );
                          } else {
                            return Scrollbar(
                              child: RefreshIndicator(
                                child: Text(
                                  '내역이 없습니다.',
                                  style: GoogleFonts.doHyeon(),
                                ),
                                onRefresh: refreshinList,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      width: 170.0,
                      height: 250.0,
                      child: FutureBuilder(
                        future: _loadoutlist,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Account>> snapshot) {
                          if (snapshot.hasData) {
                            return Scrollbar(
                              child: RefreshIndicator(
                                child: ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    itemBuilder:
                                        (BuildContext context, int position) {
                                      return Row(
                                        children: [
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0, top: 4.0),
                                              child: Text.rich(
                                                TextSpan(children: [
                                                  TextSpan(
                                                      text:
                                                          '${snapshot.data![position].date}  ',
                                                      style: GoogleFonts
                                                          .doHyeon()),
                                                  TextSpan(
                                                      text:
                                                          '${snapshot.data![position].money}원  ',
                                                      style:
                                                          GoogleFonts.doHyeon(
                                                              color: Colors
                                                                  .red[400])),
                                                  TextSpan(
                                                      text:
                                                          '${snapshot.data![position].content}',
                                                      style:
                                                          GoogleFonts.doHyeon())
                                                ]),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                onRefresh: refreshoutList,
                              ),
                            );
                          } else {
                            return Scrollbar(
                              child: RefreshIndicator(
                                child: Text(
                                  '내역이 없습니다.',
                                  style: GoogleFonts.doHyeon(),
                                ),
                                onRefresh: refreshoutList,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => IncomeScreen()));
                      },
                      child: Text(
                        '수입',
                        style: GoogleFonts.doHyeon(fontSize: 20.0),
                      ),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.brown[300],
                          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ExpenditureScreen()));
                      },
                      child: Text(
                        '지출',
                        style: GoogleFonts.doHyeon(fontSize: 20.0),
                      ),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.brown[300],
                          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0)),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 10.0,
            )
          ],
        ),
      ),
    );
  }

  Future<List<Account>> loadinAccount() async {
    Future.delayed(Duration(seconds: 3));
    return await sd1.accounts(
        'uid = ?', '${FirebaseAuth.instance.currentUser!.uid.toString()}');
  }

  Future<List<Account>> loadoutAccount() async {
    Future.delayed(Duration(seconds: 3));
    return await sd2.accounts(
        'uid = ?', '${FirebaseAuth.instance.currentUser!.uid.toString()}');
  }
}
