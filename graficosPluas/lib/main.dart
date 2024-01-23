import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:csv/csv.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3, // Número total de pestañas (diagramas)
        child: Scaffold(
          appBar: AppBar(
            title: Text('Gráficos'),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Barras'),
                Tab(text: 'Pastel (Multijugador)'),
                Tab(text: 'Pastel (Precio)'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              BarChartPage(),
              PieChartPage(type: 'Multijugador'),
              PieChartPage(type: 'Precio'),
            ],
          ),
        ),
      ),
    );
  }
}

class BarChartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Implementación del gráfico de barras
    return FutureBuilder(
      future: loadCSV('categorias.csv'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Map<String, dynamic>> data = snapshot.data as List<Map<String, dynamic>>;
          List<String> categories = data.map((item) => item['Categoría'].toString()).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChart(
              BarChartData(
                groupsSpace: 12,
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: SideTitles(
                    showTitles: true,
                    margin: 16,
                    rotateAngle: 45,
                    getTitles: (double value) {
                      if (value >= 0 && value < categories.length) {
                        return categories[value.toInt()];
                      } else {
                        return '';
                      }
                    },
                  ),
                  leftTitles: SideTitles(showTitles: true, margin: 12),
                  rightTitles: SideTitles(showTitles: false, margin: 12),
                  topTitles: SideTitles(showTitles: false, margin: 12),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xff37434d), width: 1),
                ),
                barGroups: categories.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key.toInt(),
                    barRods: [
                      BarChartRodData(
                        y: data[entry.key]['Número de Juegos'].toDouble(),
                        colors: [Colors.blue],
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> loadCSV(String fileName) async {
    String csvData = await rootBundle.loadString('assets/$fileName');
    List<List<dynamic>> rowsAsListOfValues = CsvToListConverter().convert(csvData);

    List<Map<String, dynamic>> data = [];

    for (int i = 1; i < rowsAsListOfValues.length; i++) {
      Map<String, dynamic> row = {
        'Categoría': rowsAsListOfValues[i][0].toString().trim(),
        'Número de Juegos': int.parse(rowsAsListOfValues[i][1].toString().trim())
      };
      data.add(row);
    }

    return data;
  }
}

class PieChartPage extends StatelessWidget {
  final String type;

  PieChartPage({required this.type});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadCSV('${type.toLowerCase()}.csv'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Map<String, dynamic>> data = snapshot.data as List<Map<String, dynamic>>;

          if (type == 'Multijugador') {
            int multiplayerGames = data.firstWhere((item) => item['Tipo'] == 'Multijugador')['Número de Juegos'];
            int nonMultiplayerGames = data.firstWhere((item) => item['Tipo'] == 'No Multijugador')['Número de Juegos'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: PieChart(
                PieChartData(
                  sectionsSpace: 12,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: Colors.blue,
                      value: multiplayerGames.toDouble(),
                      title: '$multiplayerGames\nMultijugador',
                      radius: 80,
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: nonMultiplayerGames.toDouble(),
                      title: '$nonMultiplayerGames\nNo Multijugador',
                      radius: 80,
                    ),
                  ],
                ),
              ),
            );
          } else if (type == 'Precio') {
            int freeGames = data.firstWhere((item) => item['Tipo'] == 'Gratis')['Número de Juegos'];
            int paidGames = data.firstWhere((item) => item['Tipo'] == 'No Gratis')['Número de Juegos'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: PieChart(
                PieChartData(
                  sectionsSpace: 12,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: freeGames.toDouble(),
                      title: '$freeGames\nGratis',
                      radius: 80,
                    ),
                    PieChartSectionData(
                      color: Colors.orange,
                      value: paidGames.toDouble(),
                      title: '$paidGames\nNo Gratis',
                      radius: 80,
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(); // En caso de un tipo no reconocido
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> loadCSV(String fileName) async {
    String csvData = await rootBundle.loadString('assets/$fileName');
    List<List<dynamic>> rowsAsListOfValues = CsvToListConverter().convert(csvData);

    List<Map<String, dynamic>> data = [];

    for (int i = 1; i < rowsAsListOfValues.length; i++) {
      Map<String, dynamic> row = {
        'Tipo': rowsAsListOfValues[i][0].toString().trim(),
        'Número de Juegos': int.parse(rowsAsListOfValues[i][1].toString().trim())
      };
      data.add(row);
    }

    return data;
  }
}
