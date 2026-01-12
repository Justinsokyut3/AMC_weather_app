import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/weather.dart';

void main() {
  test('Weather.fromJson should parse all UI-required fields', () {
    final json = {
      "weather": [{"description": "clear sky"}],
      "main": {"temp": 28.5, "humidity": 70},
      "wind": {"speed": 5.5},
      "name": "Manila"
    };

    final weather = Weather.fromJson(json);

    expect(weather.cityName, 'Manila');
    expect(weather.temperature, 28.5);
    expect(weather.description, 'clear sky');
    expect(weather.humidity, 70);
    expect(weather.windSpeed, 5.5);
  });
}