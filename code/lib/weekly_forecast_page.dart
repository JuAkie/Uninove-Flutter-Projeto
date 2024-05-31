import 'package:flutter/material.dart';
import 'forecast_model.dart';

class WeeklyForecastPage extends StatelessWidget {
  final String cityName;
  final List<Forecast> forecasts;

  WeeklyForecastPage({required this.cityName, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previsão Semanal - $cityName'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/background_image.jpg'), // substitua pelo nome do arquivo da sua imagem
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: forecasts.length,
              itemBuilder: (context, index) {
                final forecast = forecasts[index];
                return Card(
                  color: Colors.white.withOpacity(
                      0.8), // Fundo semi-transparente para melhor visibilidade do texto
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: Image.network(
                      'https://openweathermap.org/img/wn/${forecast.icon}@2x.png',
                    ),
                    title: Text(
                      '${forecast.date}',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${forecast.temperature.toStringAsFixed(1)} °C',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
