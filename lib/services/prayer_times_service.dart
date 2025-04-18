import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pray_times/models/prayer_time.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimesService {
  static const String baseUrl = 'https://api.aladhan.com/v1';
  
  // Fetch prayer times based on exact coordinates
  Future<DailyPrayerTimes> getPrayerTimes({
    required double latitude,
    required double longitude,
    int? method,
    int calibration = 0,
  }) async {
    try {
      // Get time format preference
      final prefs = await SharedPreferences.getInstance();
      final use24HourFormat = prefs.getBool('use24HourFormat') ?? false;
      
      // Parameters for the API call
      final now = DateTime.now();
      final params = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'method': (method ?? 2).toString(), // Default to 2 (Islamic Society of North America) if not specified
        'month': now.month.toString(),
        'year': now.year.toString(),
      };
      
      final Uri uri = Uri.parse('$baseUrl/calendar').replace(queryParameters: params);
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200 && data['data'] != null) {
          // Get today's date to find today's prayer times from the month's data
          final today = now.day;
          final todayData = data['data'][today - 1]; // API returns array indexed from 0
          
          // Extract prayer times from the response
          final timings = todayData['timings'];
          final date = '${now.day}/${now.month}/${now.year}';
          
          final prayerTimesList = <PrayerTime>[];
          
          // Add each prayer time to the list, applying calibration
          prayerTimesList.add(PrayerTime(name: 'Fajr', time: _formatTime(timings['Fajr'], use24HourFormat, calibration)));
          prayerTimesList.add(PrayerTime(name: 'Sunrise', time: _formatTime(timings['Sunrise'], use24HourFormat, calibration)));
          prayerTimesList.add(PrayerTime(name: 'Dhuhr', time: _formatTime(timings['Dhuhr'], use24HourFormat, calibration)));
          prayerTimesList.add(PrayerTime(name: 'Asr', time: _formatTime(timings['Asr'], use24HourFormat, calibration)));
          prayerTimesList.add(PrayerTime(name: 'Maghrib', time: _formatTime(timings['Maghrib'], use24HourFormat, calibration)));
          prayerTimesList.add(PrayerTime(name: 'Isha', time: _formatTime(timings['Isha'], use24HourFormat, calibration)));
          
          return DailyPrayerTimes(
            date: date,
            prayerTimes: prayerTimesList,
          );
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
  
  // Helper method to format time with calibration
  String _formatTime(String timeString, bool use24HourFormat, int calibration) {
    // Remove timezone info if present (e.g., "04:30 (GMT+1)")
    String cleanTime = timeString;
    if (cleanTime.contains('(')) {
      cleanTime = cleanTime.split('(')[0].trim();
    }
    
    try {
      // Parse the time
      final DateFormat inputFormat = DateFormat('HH:mm');
      final DateTime timeDateTime = inputFormat.parse(cleanTime);
      
      // Apply calibration (adjust minutes)
      final DateTime calibratedTime = timeDateTime.add(Duration(minutes: calibration));
      
      // Format according to preference
      final DateFormat outputFormat = use24HourFormat 
          ? DateFormat('HH:mm')
          : DateFormat('h:mm a');
          
      return outputFormat.format(calibratedTime);
    } catch (e) {
      // Return the original time if parsing fails
      return cleanTime;
    }
  }
  
  // Get calculation methods
  Future<List<Map<String, dynamic>>> getCalculationMethods() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/methods'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200 && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data'].values);
        } else {
          throw Exception('Failed to load calculation methods: ${data['status']}');
        }
      } else {
        throw Exception('Failed to load calculation methods: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching calculation methods: $e');
    }
  }
}