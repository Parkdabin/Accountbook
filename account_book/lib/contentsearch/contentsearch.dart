import 'package:account_book/message/toast.dart';
import 'package:account_book/sqlite/accountmodel.dart';
import 'package:account_book/sqlite/dbhelper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentSearch extends StatefulWidget {
  const ContentSearch({Key? key}) : super(key: key);

  @override
  _ContentSearchState createState() => _ContentSearchState();
}

class _ContentSearchState extends State<ContentSearch> {
  TextEditingController _searchcontroller = TextEditingController();

  late Future<List<Account>> _loadlist;
  String myuid = FirebaseAuth.instance.currentUser!.uid.toString();
  String viewcontent = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadlist =
        loadinAccount("uid = '$myuid' AND content = ?", _searchcontroller.text);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _searchcontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          '수입/지출 내역 검색',
          style: GoogleFonts.doHyeon(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 50.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _searchcontroller.clear();
                        FToast(content: '수입 내역을 선택하셨습니다.');
                        viewcontent = '수입 내역 검색';
                        setState(() {});
                      },
                      child: Text(
                        '수입',
                        style: GoogleFonts.doHyeon(
                          fontSize: 18.0,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                          onPrimary: Colors.white,
                          primary: Colors.green[300],
                          padding: EdgeInsets.only(top: 15.0, bottom: 15.0)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _searchcontroller.clear();
                        FToast(content: '지출 내역을 선택하셨습니다.');
                        viewcontent = '지출 내역 검색';
                        setState(() {});
                      },
                      child: Text(
                        '지출',
                        style: GoogleFonts.doHyeon(
                          fontSize: 18.0,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.red[200],
                          padding: EdgeInsets.only(top: 15.0, bottom: 15.0)),
                    ),
                  ],
                ),
                SizedBox(
                  height: 35.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: TextFormField(
                            initialValue: null,
                            controller: _searchcontroller,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: viewcontent,
                            ),
                            keyboardType: TextInputType.multiline,
                            maxLines: null),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (viewcontent != '') {
                          if (viewcontent == '수입 내역 검색') {
                            _loadlist = loadinAccount(
                                "uid = '$myuid' AND content = ?",
                                _searchcontroller.text);
                            setState(() {});
                          } else if (viewcontent == '지출 내역 검색') {
                            _loadlist = loadoutAccount(
                                "uid = '$myuid' AND content = ?",
                                _searchcontroller.text);
                            setState(() {});
                          }
                        } else {
                          FToast(content: '수입/지출 중 하나를 선택하세요.');
                        }
                      },
                      child: Icon(Icons.search),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.brown[300],
                          padding: EdgeInsets.only(top: 15.0, bottom: 15.0)),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                  ],
                ),
                SizedBox(
                  height: 15.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Scrollbar(
                    child: Container(
                      width: double.infinity,
                      height: 350.0,
                      child: FutureBuilder(
                        future: _loadlist,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Account>> snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder:
                                  (BuildContext context, int position) {
                                return Text(
                                  '${snapshot.data![position].date}   ${snapshot.data![position].money}원   ${snapshot.data![position].content}',
                                  style: GoogleFonts.doHyeon(
                                    fontSize: 25.0,
                                    color: Colors.indigo,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              },
                            );
                          } else {
                            return Text(
                              '내역이 없습니다.',
                              style: GoogleFonts.doHyeon(
                                fontSize: 25.0,
                                color: Colors.indigo,
                              ),
                              textAlign: TextAlign.center,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Account>> loadinAccount(
      String wherecondition, String content) async {
    DBHelper sd = DBHelper(tablename: 'inAccount', dbname: 'inAccountdb');
    Future.delayed(Duration(seconds: 3));
    return await sd.accounts(wherecondition, content);
  }

  Future<List<Account>> loadoutAccount(
      String wherecondition, String content) async {
    DBHelper sd = DBHelper(tablename: 'outAccount', dbname: 'outAccountdb');
    Future.delayed(Duration(seconds: 3));
    return await sd.accounts(wherecondition, content);
  }
}
