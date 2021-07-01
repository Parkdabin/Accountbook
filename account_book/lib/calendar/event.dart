class Event {
  final String title1;
  final String title2;
  final String title3;
  Event({required this.title1, required this.title2, required this.title3});

  String toString() {
    return '${this.title1}${this.title2}${this.title3}';
  }
}
