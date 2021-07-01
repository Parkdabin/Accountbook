import 'package:account_book/message/dialog.dart';
import 'package:account_book/message/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

bool visited = false;

class _RegisterState extends State<Register> {
  final referenceDatase = FirebaseDatabase.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordControllercheck =
      TextEditingController();
  final _n1 = FocusNode();
  final _n2 = FocusNode();
  final _n3 = FocusNode();

  @override
  Widget build(BuildContext context) {
    void _signUp() async {
      try {
        if (_nameController.text == '') {
          FToast(content: '이름을 입력해 주세요.');
          visited = false;
        } else if (_emailController.text == '') {
          FToast(content: 'Email을 입력해 주세요.');
          visited = false;
        } else if (_passwordController.text == '') {
          FToast(content: '비밀번호를 입력해 주세요.');
          visited = false;
        } else if (_passwordController.text != _passwordControllercheck.text) {
          FToast(content: '비밀번호가 일치하지 않습니다.');
          visited = false;
        } else {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: "${_emailController.text}",
              password: "${_passwordController.text}");
          FirebaseFirestore.instance
              .collection('users')
              .doc('${FirebaseAuth.instance.currentUser!.uid}')
              .set({
            'name': _nameController.text,
            'email': _emailController.text,
            'lemoney': 0
          });

          Navigator.pop(context);
          FlutterDialog(title: '확인', content: '완료되었습니다', context: context);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          FlutterDialog(
              title: '실패', content: '비밀번호가 너무 약합니다!', context: context);
          visited = false;
          print('weak visited');
        } else if (e.code == 'email-already-in-use') {
          FlutterDialog(
              title: '실패', content: '이미 존재하는 Email입니다.', context: context);
          visited = false;
          print('email visited');
        }
      } catch (e) {
        print(e);
        print('catch visited');
      }
    }

    return Scaffold(
        backgroundColor: Colors.brown[20],
        body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 70.0,
                  ),
                  Text('Registration',
                      style: GoogleFonts.doHyeon(
                        fontSize: 60.0,
                        color: Colors.green[600],
                        fontWeight: FontWeight.bold,
                      )),
                  SizedBox(
                    height: 20.0,
                  ),
                  Form(
                    child: Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 15.0, right: 15.0),
                          child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(), labelText: '이름'),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_n1);
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 15.0, right: 15.0),
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'E-mail'),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            focusNode: _n1,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_n2);
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 15.0, right: 15.0),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Password'),
                            keyboardType: TextInputType.emailAddress,
                            focusNode: _n2,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_n3);
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 17.0),
                              child: Text(
                                '특수문자 포함',
                                style: GoogleFonts.doHyeon(),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 15.0, right: 15.0),
                          child: TextFormField(
                            controller: _passwordControllercheck,
                            obscureText: true,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Password 확인'),
                            keyboardType: TextInputType.emailAddress,
                            focusNode: _n3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              '취소',
                              style: GoogleFonts.doHyeon(fontSize: 20.0),
                            ),
                            style: ElevatedButton.styleFrom(
                                primary: Colors.brown[300],
                                padding: EdgeInsets.fromLTRB(
                                    25.0, 10.0, 25.0, 10.0)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _signUp();
                            },
                            child: Text(
                              '완료',
                              style: GoogleFonts.doHyeon(fontSize: 20.0),
                            ),
                            style: ElevatedButton.styleFrom(
                                primary: Colors.brown[300],
                                padding: EdgeInsets.fromLTRB(
                                    25.0, 10.0, 25.0, 10.0)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
