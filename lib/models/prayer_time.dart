class PrayerTime {
  final String name;
  final String time;

  PrayerTime({required this.name, required this.time});

  factory PrayerTime.fromJson(String name, String time) {
    return PrayerTime(
      name: name,
      time: time,
    );
  }
}

class DailyPrayerTimes {
  final String date;
  final List<PrayerTime> prayerTimes;

  DailyPrayerTimes({required this.date, required this.prayerTimes});

  factory DailyPrayerTimes.fromJson(Map<String, dynamic> json) {
    final List<PrayerTime> times = [];
    
    // Parse standard prayer times
    if (json['shubuh'] != null) times.add(PrayerTime.fromJson('Fajr', json['shubuh']));
    if (json['dzuhur'] != null) times.add(PrayerTime.fromJson('Dhuhr', json['dzuhur']));
    if (json['ashar'] != null) times.add(PrayerTime.fromJson('Asr', json['ashar']));
    if (json['maghrib'] != null) times.add(PrayerTime.fromJson('Maghrib', json['maghrib']));
    if (json['isya'] != null) times.add(PrayerTime.fromJson('Isha', json['isya']));
    
    return DailyPrayerTimes(
      date: json['tanggal'] ?? 'Unknown date',
      prayerTimes: times,
    );
  }
}
