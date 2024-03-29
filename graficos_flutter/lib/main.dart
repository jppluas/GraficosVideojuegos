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
          child: HorizontalBarLabelChart.withSampleData(),
        ),
      ),
    );
  }
}

class HorizontalBarLabelChart extends StatelessWidget {
  final List<charts.Series<PeliculaGenero, String>> seriesList;
  final bool animate;

  HorizontalBarLabelChart(this.seriesList, {this.animate = false});

  /// Creates a [BarChart] with sample data and no transition.
  factory HorizontalBarLabelChart.withSampleData() {
    return new HorizontalBarLabelChart(
      _createSampleData(),
// Disable animations for image tests.
      animate: false,
    );
  }

// EXCLUDE_FROM_GALLERY_DOCS_START
// This section is excluded from being copied to the gallery.
// It is used for creating random series data to demonstrate animation in
// the example app only.
  factory HorizontalBarLabelChart.withRandomData() {
    return new HorizontalBarLabelChart(_createRandomData());
  }

  /// Create random data.
  static List<charts.Series<PeliculaGenero, String>> _createRandomData() {
    final random = new Random();

    final data = [
      new PeliculaGenero('Acción', random.nextInt(100)),
      new PeliculaGenero('Familia', random.nextInt(100)),
      new PeliculaGenero('Puzzle', random.nextInt(100)),
      new PeliculaGenero('Estrategia', random.nextInt(100)),
    ];

    return [
      new charts.Series<PeliculaGenero, String>(
        id: 'Reviews',
        domainFn: (PeliculaGenero pelicula, _) => pelicula.genero,
        measureFn: (PeliculaGenero pelicula, _) => pelicula.resena,
        data: data,
        labelAccessorFn: (PeliculaGenero pelicula, _) =>
            '<span class="math-inline">\{pelicula\.resena\.toString\(\)\}%',
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

  /// Create one series with sample hard coded data.
  static List<charts.Series<PeliculaGenero, String>> _createSampleData() {
    final data = [
      new PeliculaGenero('Acción', 70),
      new PeliculaGenero('Familia', 25),
      new PeliculaGenero('Puzzle', 35),
      new PeliculaGenero('Estrategia', 75),
    ];
    return [
      new charts.Series<PeliculaGenero, String>(
        id: 'Reviews',
        domainFn: (PeliculaGenero pelicula, _) => pelicula.genero,
        measureFn: (PeliculaGenero pelicula, _) => pelicula.resena,
        data: data,
        labelAccessorFn: (PeliculaGenero pelicula, _) =>
            '\$${pelicula.resena.toString()}'
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
