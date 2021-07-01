import 'dart:convert';
import 'package:account_book/message/dialog.dart';
import 'package:account_book/sqlite/accountmodel.dart';
import 'package:account_book/sqlite/dbhelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:crypto/crypto.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ExpenditureScreen extends StatefulWidget {
  const ExpenditureScreen({Key? key}) : super(key: key);

  @override
  _ExpenditureState createState() => _ExpenditureState();
}

class _ExpenditureState extends State<ExpenditureScreen> {
  final _n1 = FocusNode();
  final _n2 = FocusNode();
  TextEditingController _expencontroller = TextEditingController();
  TextEditingController _datecontroller = TextEditingController();
  TextEditingController _contentcontroller = TextEditingController();
  var maskFormatter = new MaskTextInputFormatter(
      mask: '####-##-##', filter: {"#": RegExp(r'[0-9]')});

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<int> getlemoney() async {
    var documentSnapshot =
        await users.doc(FirebaseAuth.instance.currentUser!.uid).get();
    return documentSnapshot.get('lemoney');
  }

  Future<void> updateUser() async {
    dynamic gle = await getlemoney();
    return users
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'lemoney': (gle - int.parse(_expencontroller.text))});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[20],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          '지출',
          style: GoogleFonts.doHyeon(color: Colors.red[400], fontSize: 20.0),
        ),
        backgroundColor: Colors.brown[50],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 30.0,
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: Center(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _expencontroller,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), labelText: '금액 입력'),
                        keyboardType: TextInputType.number,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_n1);
                        },
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        inputFormatters: [maskFormatter],
                        controller: _datecontroller,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '날짜 입력',
                            hintText: 'ex) 1997-06-22'),
                        keyboardType: TextInputType.datetime,
                        focusNode: _n1,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_n2);
                        },
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        controller: _contentcontroller,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '내용 입력',
                            hintText: 'ex) 마트'),
                        focusNode: _n2,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                width: double.infinity,
                height: 250.0,
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
                      } else if (_expencontroller.text == '') {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('예상금액\n${snapshot.data!.get('lemoney')}',
                                style: GoogleFonts.doHyeon(
                                    fontSize: 32.0, color: Colors.grey[600])),
                          ],
                        );
                      } else {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '예상금액',
                              style: GoogleFonts.doHyeon(
                                  fontSize: 32.0, color: Colors.grey[600]),
                            ),
                            Text(
                              '${snapshot.data!.get('lemoney')}',
                              style: GoogleFonts.doHyeon(
                                  fontSize: 32.0, color: Colors.grey[600]),
                            ),
                            Text(
                              ' - ${_expencontroller.text}',
                              style: GoogleFonts.doHyeon(
                                  fontSize: 32.0, color: Colors.red[400]),
                            ),
                            Text(
                                '${snapshot.data!.get('lemoney') - int.parse(_expencontroller.text)}',
                                style: GoogleFonts.doHyeon(
                                    fontSize: 32.0, color: Colors.red[400]))
                          ],
                        );
                      }
                    }),
              ),
              SizedBox(
                height: 20.0,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_expencontroller.text == '') {
                    FlutterDialog(
                        title: '실패', content: '금액을 입력해 주세요.', context: context);
                  } else if (_datecontroller.text == '') {
                    FlutterDialog(
                        title: '실패', content: '날짜를 입력해 주세요.', context: context);
                  } else {
                    updateUser();
                    saveDB();
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  '확인',
                  style: GoogleFonts.doHyeon(fontSize: 20.0),
                ),
                style: ElevatedButton.styleFrom(
                    primary: Colors.brown[300],
                    padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveDB() async {
    DBHelper sd = DBHelper(tablename: 'outAccount', dbname: 'outAccountdb');
    var fido = Account(
      id: strsha(DateTime.now().toString()),
      uid: FirebaseAuth.instance.currentUser!.uid.toString(),
      date: _datecontroller.text,
      money: _expencontroller.text,
      content: _contentcontroller.text,
    );
    await sd.insertAccount(fido);
  }

  String strsha(String text) {
    var bytes = utf8.encode(text); // data being hashed
    var digest = sha512.convert(bytes);
    return digest.toString();
  }
}
