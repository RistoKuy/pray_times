import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class PrayerTimesService {
  Future<PrayerTimes> getPrayerTimes(Position position) async {
    final coordinates = Coordinates(position.latitude, position.longitude);
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;
    
    final date = DateComponents.from(DateTime.now());
    return PrayerTimes(coordinates, date, params);
  }

  String formatPrayerTime(DateTime? time) {
    if (time == null) return 'N/A';
    return DateFormat.jm().format(time);
  }

  String getNextPrayer(PrayerTimes prayerTimes) {
    try {
      return prayerTimes.nextPrayer().name;
    } catch (e) {
      return "Unknown";
    }
  }

  String getTimeUntilNextPrayer(PrayerTimes prayerTimes) {
    try {
      final nextPrayerTime = prayerTimes.timeForPrayer(prayerTimes.nextPrayer());
      if (nextPrayerTime == null) return 'N/A';
      
      final now = DateTime.now();
      final difference = nextPrayerTime.difference(now);
      
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      
      return '$hours hr ${minutes.abs()} min';
    } catch (e) {
      return 'N/A';
    }
  }
}
