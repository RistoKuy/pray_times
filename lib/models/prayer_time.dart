class PrayerTime {
  final String name;
  final String time;

  PrayerTime({
    required this.name,
    required this.time,
  });

  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    return PrayerTime(
      name: json['name'],
      time: json['time'],
    );
  }
}

class DailyPrayerTimes {
  final String date;
  final List<PrayerTime> prayerTimes;

  DailyPrayerTimes({
    required this.date,
    required this.prayerTimes,
  });

  factory DailyPrayerTimes.fromJson(Map<String, dynamic> json) {
    var prayerTimesList = <PrayerTime>[];
    if (json['prayer_times'] != null) {
      json['prayer_times'].forEach((prayer) {
        prayerTimesList.add(PrayerTime.fromJson(prayer));
      });
    }

    return DailyPrayerTimes(
      date: json['date'],
      prayerTimes: prayerTimesList,
    );
  }
}