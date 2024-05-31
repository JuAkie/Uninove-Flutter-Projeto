import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'forecast_model.dart';
import 'weekly_forecast_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WeatherApp(),
    );
  }
}

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final String apiKey = 'cebcd482eda57fa9a6714c1c2ba91885';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  final String forecastUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  final TextEditingController searchController = TextEditingController();

  String cityName = 'São Paulo';
  String temperature = '';
  String description = '';
  String clouds = '';
  String humidity = '';
  String pressure = '';
  String countryFlagUrl = '';
  String weatherIconUrl = '';
  bool loading = false;
  bool error = false;

  @override
  void initState() {
    super.initState();
    searchController.text = cityName;
    searchWeather();
  }

  void searchWeather() async {
    setState(() {
      loading = true;
    });

    final String url =
        '$baseUrl?units=metric&lang=pt_br&appid=$apiKey&q=${searchController.text}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          cityName = data['name'];
          temperature = data['main']['temp'].toStringAsFixed(1);
          description = data['weather'][0]['description'];
          clouds = '${data['clouds']['all']}%';
          humidity = '${data['main']['humidity']}%';
          pressure = '${data['main']['pressure']} hPa';
          weatherIconUrl =
              'https://openweathermap.org/img/wn/${data['weather'][0]['icon']}@4x.png';
          countryFlagUrl =
              'https://flagsapi.com/${data['sys']['country']}/shiny/32.png';
          loading = false;
          error = false;
        });
      } else {
        setState(() {
          loading = false;
          error = true;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        error = true;
      });
      print('Error fetching weather data: $e');
    }
  }

  String getFormattedDate(DateTime date) {
    List<String> weekdays = [
      'Domingo',
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado'
    ];
    return weekdays[date.weekday % 7];
  }

  void searchForecast() async {
    setState(() {
      loading = true;
    });

    final String url =
        '$forecastUrl?units=metric&lang=pt_br&appid=$apiKey&q=${searchController.text}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Forecast> forecasts = [];
        Map<String, Forecast> dailyForecasts = {};

        for (var entry in data['list']) {
          DateTime date = DateTime.parse(entry['dt_txt']);
          String day = '${date.year}-${date.month}-${date.day}';

          if (!dailyForecasts.containsKey(day) && date.hour == 12) {
            dailyForecasts[day] = Forecast(
              date: getFormattedDate(date),
              icon: entry['weather'][0]['icon'],
              description: entry['weather'][0]['description'],
              temperature: entry['main']['temp'],
            );
          }
        }

        forecasts = dailyForecasts.values.toList();

        setState(() {
          loading = false;
          error = false;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WeeklyForecastPage(
                cityName: cityName,
                forecasts: forecasts,
              ),
            ),
          );
        });
      } else {
        setState(() {
          loading = false;
          error = true;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        error = true;
      });
      print('Error fetching forecast data: $e');
    }
  }

  void navigateToWeeklyForecastPage() {
    searchForecast();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: navigateToWeeklyForecastPage,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background_image.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Form(
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Nome da Cidade',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          searchWeather();
                        },
                      ),
                    ),
                    onFieldSubmitted: (value) {
                      searchWeather();
                    },
                  ),
                ),
                if (loading) CircularProgressIndicator(),
                if (error)
                  Text(
                    'Erro ao buscar dados do clima',
                    style: TextStyle(color: Colors.red),
                  ),
                if (!error && !loading)
                  Column(
                    children: [
                      if (weatherIconUrl.isNotEmpty)
                        Image.network(weatherIconUrl),
                      if (countryFlagUrl.isNotEmpty)
                        Container(
                          height: 32,
                          child: Image.network(countryFlagUrl),
                        ),
                      if (cityName.isNotEmpty)
                        Text(cityName,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                      if (temperature.isNotEmpty)
                        Text('$temperature °C', style: TextStyle(fontSize: 48)),
                      if (description.isNotEmpty)
                        Text(description, style: TextStyle(fontSize: 24)),
                      if (clouds.isNotEmpty) Text('Nuvens: $clouds'),
                      if (humidity.isNotEmpty) Text('Umidade: $humidity'),
                      if (pressure.isNotEmpty) Text('Pressão: $pressure'),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
