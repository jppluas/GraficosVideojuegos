import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
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
                Tab(text: 'Dispersion'),
                Tab(text: 'Linea de tiempo')
              ],
            ),
          ),
          body: TabBarView(
            children: [BarChartPage(), ScatterChartSample(), LineChartSample()],
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
      future: loadCSV('datosGeneros.csv'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Map<String, dynamic>> data =
              snapshot.data as List<Map<String, dynamic>>;
          List<String> generos =
              data.map((item) => item['Generos'].toString()).toList();

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
                      if (value >= 0 && value < generos.length) {
                        return generos[value.toInt()];
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
                barGroups: generos.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key.toInt(),
                    barRods: [
                      BarChartRodData(
                        y: data[entry.key]['reseñas'].toDouble(),
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
    List<List<dynamic>> rowsAsListOfValues =
        CsvToListConverter().convert(csvData);
    dynamic accion = 0;
    dynamic familia = 0;
    dynamic puzzle = 0;
    dynamic estrategia = 0;

    for (int i = 1; i < rowsAsListOfValues.length; i++) {
      dynamic resenas = int.parse(rowsAsListOfValues[i]
          .toString()
          .replaceAll("]", "")
          .split(";")[4]
          .replaceAll(", ", ""));

      String genero =
          rowsAsListOfValues[i].toString().replaceAll("[", "").split(";")[0];

      if (genero == "accion") {
        accion += resenas;
      }
      if (genero == "familia") {
        familia += resenas;
      }
      if (genero == "puzzle") {
        puzzle += resenas;
      }
      if (genero == "estrategia") {
        estrategia += resenas;
      }
    }
    List<Map<String, dynamic>> data = [
      {'Generos': 'Accion', 'reseñas': accion},
      {'Generos': 'Familia', 'reseñas': familia},
      {'Generos': 'Puzzle', 'reseñas': puzzle},
      {'Generos': 'Estrategia', 'reseñas': estrategia},
    ];

    return data;
  }
}

class ScatterChartSample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadCSV('datosGallo.csv'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Map<String, dynamic>> data =
              snapshot.data as List<Map<String, dynamic>>;

          List<ScatterSpot> scatterSpots = data.map((item) {
            double precio = item['precio'] as double;
            double resena = item['resena'] as double;
            return ScatterSpot(precio, resena);
          }).toList();

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: ScatterChart(
              ScatterChartData(
                scatterSpots: scatterSpots,
                titlesData: FlTitlesData(
                  leftTitles: SideTitles(showTitles: true),
                  bottomTitles: SideTitles(showTitles: true),
                ),
                borderData: FlBorderData(show: true),
                gridData: FlGridData(show: true),
              ),
            ),
          );
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> loadCSV(String fileName) async {
    String csvData = await rootBundle.loadString('assets/$fileName');
    List<dynamic> rowsAsListOfValues = CsvToListConverter().convert(csvData);

    List<Map<String, dynamic>> data = [];

    for (int i = 1; i < rowsAsListOfValues.length; i++) {
      if (rowsAsListOfValues[i].toString().split(";").length == 4) {
        dynamic precio = double.parse(rowsAsListOfValues[i]
            .toString()
            .split(";")[1]
            .replaceAll("\$", ""));
        dynamic resena = int.parse(rowsAsListOfValues[i]
            .toString()
            .split(";")[3]
            .replaceAll("]", "")
            .replaceAll(", ", ""));
        data.add({'precio': precio, 'resena': resena});
      }
    }
    return data;
  }
}

class LineChartSample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadCSV('datosGallo.csv'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Map<String, dynamic>> data =
              snapshot.data as List<Map<String, dynamic>>;

          List<FlSpot> spots = data.map((entry) {
            DateTime fecha = DateFormat('d-MMM-yyyy').parse(entry['fecha']);
            double tiempo = fecha.millisecondsSinceEpoch.toDouble(); // Convertir la fecha a milisegundos desde la época
            double positividad = entry['resena'].toDouble();
            return FlSpot(tiempo, positividad);
          }).toList();

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    margin: 10,
                    getTitles: (value) {
                      // Convertir milisegundos desde la época a una cadena de fecha
                      return DateFormat('dd MMM').format(DateTime.fromMillisecondsSinceEpoch(value.toInt()));
                    },
                  ),
                  leftTitles: SideTitles(showTitles: true),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    colors: [Colors.blue],
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> loadCSV(String fileName) async {
    String csvData = await rootBundle.loadString('assets/$fileName');
    List<dynamic> rowsAsListOfValues = CsvToListConverter().convert(csvData);

    List<Map<String, dynamic>> data = [];

    for (int i = 1; i < rowsAsListOfValues.length; i++) {
      if (rowsAsListOfValues[i].toString().split(";").length == 4) {
       
        dynamic fecha = rowsAsListOfValues[i].toString().split(";")[2].replaceAll(",  ", "-").replaceAll(" ", "-");
        
        dynamic tiempo = DateFormat('d-MMM-yyyy').parse(fecha).millisecondsSinceEpoch.toDouble();
        
        dynamic positividad = double.parse(rowsAsListOfValues[i]
            .toString()
            .split(";")[3]
            .replaceAll("]", "")
            .replaceAll(", ", ""));
        
        // Agregar datos a la lista
        data.add({'fecha': fecha, 'tiempo': tiempo, 'resena': positividad});
      }
    }
    print(data);

    return data;
  }
}