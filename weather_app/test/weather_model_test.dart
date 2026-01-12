import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/weather.dart';

void main() {
  group('Weather Model Tests', () {
    test('should create a Weather instance from a realistic Manila JSON sample', () {
      // 1. Arrange: A realistic JSON response for Manila from OpenWeatherMap
      const String jsonString = '''
      {
        "weather": [
          {
            "description": "broken clouds"
          }
        ],
        "main": {
          "temp": 31.02,
          "humidity": 62
        },
        "wind": {
          "speed": 5.5
        },
        "name": "Manila"
      }
      ''';

      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      // 2. Act: Call the fromJson method
      final weather = Weather.fromJson(jsonMap);

      // 3. Assert: Verify the data was mapped correctly
      expect(weather.cityName, 'Manila');
      expect(weather.temperature, 31.02);
      expect(weather.description, 'broken clouds'); // Changed from mainCondition
      expect(weather.humidity, 62);                 // Added check for humidity
      expect(weather.windSpeed, 5.5);              // Added check for windSpeed
    });

    test('should handle numeric values as doubles even if API returns integers', () {
      // API often returns 30 instead of 30.0
      final Map<String, dynamic> jsonWithInt = {
        "weather": [{"description": "clear sky"}],
        "main": {
          "temp": 30,
          "humidity": 50
        },
        "wind": {
          "speed": 4
        },
        "name": "Manila"
      };

      final weather = Weather.fromJson(jsonWithInt);

      expect(weather.temperature, 30.0);
      expect(weather.windSpeed, 4.0);
    });
  });
}