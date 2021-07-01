import 'package:account_book/message/dialog.dart';
import 'package:account_book/sqlite/accountmodel.dart';
import 'package:account_book/sqlite/dbhelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({Key? key}) : super(key: key);

  @override
  _InComeState createState() => _InComeState();
}

class _InComeState extends State<IncomeScreen> {
  final _n1 = FocusNode();
  final _n2 = FocusNode();
  final TextEditingController _incomecontroller = TextEditingController();
  final TextEditingController _datecontroller = TextEditingController();
  final TextEditingController _contentcontroller = TextEditingController();
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  var maskFormatter = new MaskTextInputFormatter(
      mask: '####-##-##', filter: {"#": RegExp(r'[0-9]')});

  Future<int> getlemoney() async {
    var documentSnapshot =
        await users.doc(FirebaseAuth.instance.currentUser!.uid).get();
    return documentSnapshot.get('lemoney');
  }

  Future<void> updateUser() async {
    dynamic gle = await getlemoney();

    return users
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'lemoney': (int.parse(_incomecontroller.text) + gle)});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[20],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          '수입',
          style: GoogleFonts.doHyeon(color: Colors.green[600], fontSize: 20.0),
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
                height: 50.0,
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: Center(
                  child: Form(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _incomecontroller,
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
                          controller: _datecontroller,
                          inputFormatters: [maskFormatter],
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '날짜 입력',
                              hintText: 'ex) 1997-06-22'),
                          keyboardType: TextInputType.datetime,
                          maxLength: 10,
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
                              hintText: 'ex) 월급'),
                          focusNode: _n2,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                        )
                      ],
                    ),
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
                      } else if (_incomecontroller.text == '') {
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
                              ' + ${_incomecontroller.text}',
                              style: GoogleFonts.doHyeon(
                                  fontSize: 32.0, color: Colors.green[600]),
                            ),
                            Text(
                                '${snapshot.data!.get('lemoney') + int.parse(_incomecontroller.text)}',
                                style: GoogleFonts.doHyeon(
                                    fontSize: 32.0, color: Colors.green[600]))
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
                  if (_incomecontroller.text == '') {
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
    DBHelper sd = DBHelper(tablename: 'inAccount', dbname: 'inAccountdb');
    var fido = Account(
      id: strsha(DateTime.now().toString()),
      uid: FirebaseAuth.instance.currentUser!.uid.toString(),
      date: this._datecontroller.text,
      money: this._incomecontroller.text,
      content: this._contentcontroller.text,
    );
    await sd.insertAccount(fido);
  }

  String strsha(String text) {
    var bytes = utf8.encode(text); // data being hashed
    var digest = sha512.convert(bytes);
    return digest.toString();
  }
}
