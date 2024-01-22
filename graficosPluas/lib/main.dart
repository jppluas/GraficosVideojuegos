import 'dart:async';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Gráfico de Barras'),
        ),
        body: FutureBuilder(
          future: loadCSV(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return BarChartPage(data: snapshot.data!);
            }
          },
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> loadCSV() async {
    String csvData = await rootBundle.loadString('assets/datosPluas.csv');
    List<List<dynamic>> rowsAsListOfValues = CsvToListConverter().convert(csvData);

    List<String> headers = rowsAsListOfValues[0].map((e) => e.toString()).toList();
    List<Map<String, dynamic>> data = [];

    for (int i = 1; i < rowsAsListOfValues.length; i++) {
      Map<String, dynamic> row = {};
      for (int j = 0; j < headers.length; j++) {
        row[headers[j]] = rowsAsListOfValues[i][j];
      }
      data.add(row);
    }

    return data;
  }
}

class BarChartPage extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  BarChartPage({required this.data});

  @override
  Widget build(BuildContext context) {
    Map<String, int> categoryCounts = {};

    for (var game in data) {
      String category = game['Categorias'].toString();
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    List<String> categories = categoryCounts.keys.toList();

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
                  y: categoryCounts[entry.value]?.toDouble() ?? 0.0,
                  colors: [Colors.blue],
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
