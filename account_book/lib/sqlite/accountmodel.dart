class Account {
  final String id;
  final String uid;
  final String date;
  final String money;
  final String content;

  Account(
      {required this.id,
      required this.uid,
      required this.date,
      required this.money,
      required this.content});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'date': date,
      'money': money,
      'content': content,
    };
  }

  @override
  String toString() {
    return 'Account{id: $id, date: $date, money: $money, content: $content}';
  }
}
