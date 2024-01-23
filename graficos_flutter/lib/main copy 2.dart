import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:csv/csv.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gráfico de Barras Horizontales',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Gráfico de Barras Horizontales'),
        ),
        body: Center(
          child: VerticalBarLabelChart.withSampleData(),
        ),
      ),
    );
  }
}

class VerticalBarLabelChart extends StatelessWidget {
  final List<charts.Series<PeliculaGenero, String>> seriesList;
  final bool animate;

  VerticalBarLabelChart(this.seriesList, {this.animate = false});

  /// Creates a [BarChart] with sample data and no transition.
  factory VerticalBarLabelChart.withSampleData() {
    return VerticalBarLabelChart(
      _getData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  // EXCLUDE_FROM_GALLERY_DOCS_START
  // This section is excluded from being copied to the gallery.
  // It is used for creating random series data to demonstrate animation in
  // the example app only.
  factory VerticalBarLabelChart.withRandomData() {
    return VerticalBarLabelChart(_createRandomData());
  }

  /// Create random data.
  static List<charts.Series<PeliculaGenero, String>> _createRandomData() {
    final random = Random();

    final data = [
      PeliculaGenero('Acción', random.nextInt(100)),
      PeliculaGenero('Familia', random.nextInt(100)),
      PeliculaGenero('Puzzle', random.nextInt(100)),
      PeliculaGenero('Estrategia', random.nextInt(100)),
    ];

    return [
      charts.Series<PeliculaGenero, String>(
        id: 'Reviews',
        domainFn: (PeliculaGenero pelicula, _) => pelicula.genero,
        measureFn: (PeliculaGenero pelicula, _) => pelicula.resena,
        data: data,
        labelAccessorFn: (PeliculaGenero pelicula, _) =>
            '${pelicula.resena.toString()}%',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      barRendererDecorator: new charts.BarLabelDecorator<String>(),
      domainAxis: new charts.OrdinalAxisSpec(),
    );
  }

  /// Create one series with data from CSV file.
  static List<charts.Series<PeliculaGenero, String>> _getData() {
   
    String path = "assets/datosGeneros.csv";
    List<String> lineas = [];

    try {
      File file = File(path);
      lineas = file.readAsLinesSync();
      print(lineas);
    } catch (e) {
      print(e);
    }
    
    List<PeliculaGenero> data = [];

    for (int i = 0; i < lineas.length; i++) {
      List<String> datos = lineas[i].split(';');
      String genero = datos[0];
      int resena = int.tryParse(datos[4]) ?? 0;
      PeliculaGenero pelicula = PeliculaGenero(genero, resena);
      print(pelicula.genero);
      print(pelicula.resena);
      data.add(pelicula);
    }

    return [
      charts.Series<PeliculaGenero, String>(
        id: 'Reviews',
        domainFn: (PeliculaGenero pelicula, _) => pelicula.genero,
        measureFn: (PeliculaGenero pelicula, _) => pelicula.resena,
        data: data,
        labelAccessorFn: (PeliculaGenero pelicula, _) =>
            '${pelicula.resena.toString()}%',
      ),
    ];
  }
}

/// Sample ordinal data type.
class PeliculaGenero {
  final String genero;
  final int resena;

  PeliculaGenero(this.genero, this.resena);
}
