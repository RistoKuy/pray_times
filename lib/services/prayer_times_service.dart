import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pray_times/models/prayer_time.dart';

class PrayerTimesService {
  // Base URL for the prayer times API
  final String baseUrl = 'https://api.pray.times.example';

  // Fetch prayer times for a specific city ID
  Future<DailyPrayerTimes> getPrayerTimes({required String cityId}) async {
    try {
      // This is a mock implementation. In production, you would use a real API endpoint
      // Example: final response = await http.get(Uri.parse('$baseUrl/prayer_times?city_id=$cityId'));
      
      // For demonstration purposes, returning mock data
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      
      // Mock response data
      final mockData = {
        'date': '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        'prayer_times': [
          {'name': 'Fajr', 'time': '04:30'},
          {'name': 'Sunrise', 'time': '05:45'},
          {'name': 'Dhuhr', 'time': '12:00'},
          {'name': 'Asr', 'time': '15:15'},
          {'name': 'Maghrib', 'time': '18:10'},
          {'name': 'Isha', 'time': '19:20'},
        ]
      };
      
      return DailyPrayerTimes.fromJson(mockData);
    } catch (e) {
      throw Exception('Failed to load prayer times: $e');
    }
  }
}