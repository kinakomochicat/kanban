class Task {
  String title;
  int status; // 0:未着手 1:作業中 2:完了
  int star;
  Task(this.title, [this.status = 0, this.star = 0]);
}