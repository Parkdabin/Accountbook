import 'package:account_book/sign/registration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:account_book/message/toast.dart';
import 'package:google_fonts/google_fonts.dart';

class SignIn extends StatelessWidget {
  SignIn({Key? key}) : super(key: key);
  final _n1 = FocusNode();

  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();

  void _signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: "${_emailcontroller.text}",
          password: "${_passwordcontroller.text}");
    } on FirebaseAuthException catch (e) {
      if (_emailcontroller.text == '') {
        FToast(content: 'Email을 입력해 주세요.');
      } else if (_passwordcontroller.text == '') {
        FToast(content: 'password를 입력해주세요.');
      }
      if (e.code == 'user-not-found') {
        FToast(content: '등록되지 않은 사용자 입니다.');
      } else if (e.code == 'wrong-password') {
        FToast(content: '비밀번호가 일치하지 않습니다.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.brown[20],
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Login',
                    style: GoogleFonts.doHyeon(
                      fontSize: 60.0,
                      color: Colors.green[600],
                      fontWeight: FontWeight.bold,
                    )),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: TextField(
                        controller: _emailcontroller,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), labelText: 'E-mail'),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_n1);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: TextField(
                        controller: _passwordcontroller,
                        obscureText: true,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password'),
                        keyboardType: TextInputType.text,
                        focusNode: _n1,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Register()));
                          },
                          child: Text(
                            '회원가입',
                            style: GoogleFonts.doHyeon(fontSize: 20.0),
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.brown[300],
                              padding:
                                  EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            _signIn();
                          },
                          child: Text(
                            '로그인',
                            style: GoogleFonts.doHyeon(fontSize: 20.0),
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.brown[300],
                              padding:
                                  EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0)),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
