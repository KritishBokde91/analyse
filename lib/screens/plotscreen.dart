import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlotScreen extends StatefulWidget {
  const PlotScreen({super.key});

  @override
  State<PlotScreen> createState() => _PlotScreenState();
}

class _PlotScreenState extends State<PlotScreen> {
  String selectedPlot = 'scatterplot';
  Map<String, dynamic>? plotData;
  List<String> plotsList = ['scatterplot', 'linegraph', 'splinechart'];
  final ScreenshotController screenshotController = ScreenshotController();

  Future<void> fetchPlotData() async {
    final response = await http.get(
        Uri.parse('http://10.0.2.2:4019/plotdata?plot_type=$selectedPlot'));
    if (response.statusCode == 200) {
      setState(() {
        plotData = jsonDecode(response.body);
      });
    } else {
      throw Exception('Failed to load plot data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPlotData();
  }

  Future<void> savePlot() async {
    final imageFile = await screenshotController.capture();
    if (imageFile != null) {
      String imageUrl = await uploadImageToFirebase(imageFile);
      await saveImageUrlToFirestore(imageUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plot saved successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error capturing plot.')),
      );
    }
  }

  Future<String> uploadImageToFirebase(Uint8List imageFile) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('plots/$uid/${DateTime.now().millisecondsSinceEpoch}.png');
    UploadTask uploadTask = ref.putData(imageFile);
    await uploadTask;
    String downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> saveImageUrlToFirestore(String imageUrl) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String formattedDate = DateFormat('dd/MM/yy').format(DateTime.now());
    String formattedTime = DateFormat('h:mm a').format(DateTime.now());
    await FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('savedPlots')
        .add({
      'imageUrl': imageUrl,
      'title': selectedPlot,
      'date': "$formattedDate at $formattedTime"
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xFF226f54),
          title: const Text(
            'Plot',
            style: TextStyle(color: Color(0xFFf4f0bb)),
          )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 60,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: plotsList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 10),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.grey[200])),
                      onPressed: () {
                        setState(() {
                          selectedPlot = plotsList[index];
                          fetchPlotData();
                        });
                      },
                      child: Text(
                        plotsList[index],
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            plotData == null
                ? const Center(child: CircularProgressIndicator())
                : _buildPlot(),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.green[200])),
              onPressed: savePlot,
              child: const Text('Save Plot'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlot() {
    return SizedBox(
      height: 400,
      child: Screenshot(
        controller: screenshotController,
        child: Stack(
          children: [
            selectedPlot == 'scatterplot'
                ? _buildScatterPlot()
                : selectedPlot == 'linegraph'
                    ? _buildLineGraph()
                    : selectedPlot == 'splinechart'
                        ? _buildSplineChart()
                        : const Center(
                            child: Text('Plot type not supported yet.')),
          ],
        ),
      ),
    );
  }

  Widget _buildScatterPlot() {
    if (plotData == null || plotData!['x'] == null || plotData!['y'] == null) {
      return const Center(child: Text('No data available for scatterplot.'));
    }

    return ScatterChart(
      ScatterChartData(
        scatterSpots: List.generate(
          plotData!['x'].length,
          (index) => ScatterSpot(
            _sanitizeData(plotData!['x'][index]),
            _sanitizeData(plotData!['y'][index]),
          ),
        ),
      ),
    );
  }

  Widget _buildLineGraph() {
    if (plotData == null ||
        plotData!['index'] == null ||
        plotData!['y'] == null) {
      return const Center(child: Text('No data available for linegraph.'));
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              plotData!['index'].length,
              (index) => FlSpot(
                _sanitizeData(plotData!['index'][index]),
                _sanitizeData(plotData!['y'][index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplineChart() {
    if (plotData == null ||
        plotData!['index'] == null ||
        plotData!['y'] == null) {
      return const Center(child: Text('No data available for spline chart.'));
    }

    List<SplineChartData> data = List.generate(
      plotData!['index'].length,
      (index) => SplineChartData(
        x: _sanitizeData(plotData!['index'][index]),
        y: _sanitizeData(plotData!['y'][index]),
      ),
    );

    return SfCartesianChart(
      series: <SplineSeries<SplineChartData, double>>[
        SplineSeries<SplineChartData, double>(
          dataSource: data,
          xValueMapper: (SplineChartData data, _) => data.x,
          yValueMapper: (SplineChartData data, _) => data.y,
          name: 'Spline Data',
        ),
      ],
      primaryXAxis: const NumericAxis(),
      primaryYAxis: const NumericAxis(),
    );
  }

  double _sanitizeData(dynamic value) {
    final doubleValue = (value as num?)?.toDouble() ?? 0.0;
    if (doubleValue.isNaN || doubleValue.isInfinite) {
      return 0.0;
    }
    return doubleValue;
  }
}

class SplineChartData {
  final double x;
  final double y;

  SplineChartData({required this.x, required this.y});
}
