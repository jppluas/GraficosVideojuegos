/*import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

var gamesByCategory = {"AcTion": 24, "Adventure": 2, "Casual": 1};
var gameCounts = {'multijugador': 0, 'no multijugador': 0};

void main() {
  //loadData();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Graficos'),
        ),
        body: ChartSwitcher(),
      ),
    );
  }
}

void loadData() {
  final filePath = 'datosPluas.csv';
  final csvFile = File(filePath);

  if (csvFile.existsSync()) {
    final contents = csvFile.readAsStringSync();
    final lines = LineSplitter.split(contents);

    // Ignorar la primera línea si contiene encabezados
    final dataLines = lines.skip(1);

  for (var line in dataLines) {
    final values = line.split(';');
    final isMultiplayer = values[4].trim().toLowerCase() == 'multijugador';

    if (isMultiplayer) {
      gameCounts['multijugador'] = (gameCounts['multijugador'] ?? 0) + 1;
    } else {
      gameCounts['no multijugador'] = (gameCounts['no multijugador'] ?? 0) + 1;
    }
  }
  
  for (var line in dataLines) {
    final values = line.split(';');
    final category = values[5].trim();

    if (gamesByCategory.containsKey(category)) {
      gamesByCategory[category] = (gamesByCategory[category] ?? 0) + 1;
    } else {
      gamesByCategory[category] = 1;
    }
  }
}
}



class ChartSwitcher extends StatefulWidget {
  @override
  _ChartSwitcherState createState() => _ChartSwitcherState();
}

class _ChartSwitcherState extends State<ChartSwitcher> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(30.0),
            child: _buildChart(),
          ),
        ),
        BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Barras',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart),
              label: 'Pastel',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.scatter_plot),
              label: 'Dispersión',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ],
    );
  }

  Widget _buildChart() {
    switch (_selectedIndex) {
      case 0:
        return BarChartWidget(gamesByCategory);
      case 1:
        return PieChartWidget();
      case 2:
        return ScatterChartWidget();
      default:
        return Container();
    }
  }
}

class BarChartWidget extends StatelessWidget {
  final Map<String, int> generoJuegos;

  BarChartWidget(this.generoJuegos);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        maxY:
            generoJuegos.values.reduce((a, b) => a > b ? a : b).toDouble() + 5,
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: true),
        barGroups: generoJuegos.entries
            .map(
              (entry) => BarChartGroupData(
                x: generoJuegos.keys.toList().indexOf(entry.key),
                barRods: [
                  BarChartRodData(
                    y: entry.value.toDouble(),
                    colors: [Colors.blue],
                  ),
                ],
                showingTooltipIndicators: [0],
              ),
            )
            .toList(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueAccent,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String genero = generoJuegos.keys.toList()[group.x.toInt()];
              return BarTooltipItem(
                '$genero: ${rod.y.toInt()} juegos',
                TextStyle(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}

class PieChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: 17,
                  color: Colors.blue,
                  title: 'Multijugador',
                  radius: 40,
                  titleStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 16),
                ),
                PieChartSectionData(
                  value: 3,
                  color: Colors.green,
                  title: 'No multijugador',
                  radius: 40,
                  titleStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 16),
                ),
              ],
              borderData: FlBorderData(show: false),
              sectionsSpace: 0,
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(30.0),
              child: Text(
                'Total',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScatterChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: [
            ScatterSpot(200, 10, radius: 15, color: Colors.blue),
            ScatterSpot(50000, 8, radius: 20, color: Colors.green),
            ScatterSpot(100, 12, radius: 25, color: Colors.red),
            ScatterSpot(2456, 7, radius: 15, color: Colors.blue),
            ScatterSpot(2733, 20, radius: 20, color: Colors.green),
            ScatterSpot(100, 12, radius: 25, color: Colors.red),
            ScatterSpot(12, 22, radius: 15, color: Colors.blue),
            ScatterSpot(7734, 2, radius: 20, color: Colors.green),
            ScatterSpot(100, 12, radius: 25, color: Colors.red),
          ],
          borderData: FlBorderData(show: true),
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: SideTitles(
              showTitles: true,
            ),
            rightTitles: SideTitles(
              showTitles: false,
            ),
            topTitles: SideTitles(
              showTitles: false,
            ),
            bottomTitles: SideTitles(
              showTitles: true,
            ),
          ),
        ),
      ),
    );
  }
}
*/