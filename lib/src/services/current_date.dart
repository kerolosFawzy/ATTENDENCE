DateTime getTodayDate() {
  DateTime dateToday = DateTime(
      DateTime.now().toUtc().year,
      DateTime.now().toUtc().month,
      DateTime.now().toUtc().day,
      DateTime.now().toUtc().hour + 2 ,
      DateTime.now().toUtc().minute,
      DateTime.now().toUtc().second);
  return dateToday;
}
