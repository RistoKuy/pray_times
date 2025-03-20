import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pray_times/models/prayer_time.dart';

class PrayerTimesService {
  static const String baseUrl = 'https://jadwalsholat.org/api';
  
  // Fetch prayer times for a specific city
  Future<DailyPrayerTimes> getPrayerTimes({required String cityId}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prayer_times.php?id=$cityId'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['results'] != null) {
          return DailyPrayerTimes.fromJson(data['results']);
        } else {
          throw Exception('Failed to load prayer times: ${data['status']}');
        }
      } else {
        throw Exception('Failed to load prayer times: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching prayer times: $e');
    }
  }
  
  // Get list of available cities
  Future<List<Map<String, dynamic>>> getCities() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/city_list.php'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['results'] != null) {
          return List<Map<String, dynamic>>.from(data['results']);
        } else {
          throw Exception('Failed to load cities: ${data['status']}');
        }
      } else {
        throw Exception('Failed to load cities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cities: $e');
    }
  }
}
