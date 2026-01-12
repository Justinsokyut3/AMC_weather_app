import 'package:flutter/material.dart';
import 'services/weather_service.dart';
import 'models/weather.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue
      ),
      home: const WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final TextEditingController _controller = TextEditingController();

  Weather? _weather;
  bool _isLoading = false;
  String _error = '';

  // Helper function to get gradient colors based on weather
  List<Color> _getGradientColors() {
    if (_weather == null) {
      // Default Blue Gradient before search
      return [Colors.blue.shade300, Colors.blue.shade800];
    }

    final condition = _weather!.description.toLowerCase();
    if (condition.contains('cloud')) {
      return [Colors.blueGrey.shade300, Colors.blueGrey.shade700];
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      return [Colors.indigo.shade300, Colors.indigo.shade900];
    } else if (condition.contains('clear') || condition.contains('sun')) {
      return [Colors.lightBlue.shade300, Colors.orange.shade300]; // Sunny blue-orange
    } else if (condition.contains('thunderstorm')) {
      return [Colors.deepPurple.shade400, Colors.blueGrey.shade900];
    }

    // Default blue gradient for other conditions
    return [Colors.blue.shade400, Colors.blue.shade900];
  }

  void _fetchWeather(String cityName) async {
    if (cityName.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final weather = await WeatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Could not find city or connection error";
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Apply the Gradient to the entire screen
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _getGradientColors(),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make Scaffold transparent to see gradient
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Colors.blueAccent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wb_sunny, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Weather App',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- SEARCH BAR ---
              TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter city name (e.g., Manila)',
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) => _fetchWeather(value),
              ),
              const SizedBox(height: 20),

              // --- DISPLAY AREA ---
              Expanded(
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : _error.isNotEmpty
                      ? Text(_error, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                      : _weather == null
                      ? const Text('Search for a city to see weather', style: TextStyle(color: Colors.white70))
                      : SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _weather!.cityName,
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          '${_weather!.temperature.toStringAsFixed(1)}°C',
                          style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w200, color: Colors.white),
                        ),
                        Text(
                          _weather!.description.toUpperCase(),
                          style: const TextStyle(fontSize: 18, letterSpacing: 1.2, color: Colors.white70),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildWeatherDetail('Humidity', '${_weather!.humidity}%', Icons.water_drop),
                            _buildWeatherDetail('Wind', '${_weather!.windSpeed} m/s', Icons.air),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}