import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'dart:math' show pi;

class QiblahScreen extends StatefulWidget {
  const QiblahScreen({super.key});

  @override
  State<QiblahScreen> createState() => _QiblahScreenState();
}

class _QiblahScreenState extends State<QiblahScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qiblah Direction'),
      ),
      body: FutureBuilder(
        future: FlutterQiblah.checkLocationStatus(),
        builder: (context, AsyncSnapshot<QiblahLocationStatus> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.data!.enabled == false) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Location service is disabled or permissions denied',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return StreamBuilder(
            stream: FlutterQiblah.qiblahStream,
            builder: (context, AsyncSnapshot<QiblahDirection> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final qiblahDirection = snapshot.data!;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Prayer Direction',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    _QiblahCompass(qiblahDirection: qiblahDirection),
                    const SizedBox(height: 24),
                    Text(
                      'Direction: ${qiblahDirection.direction.toStringAsFixed(2)}°',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Accuracy: ${_getAccuracyText(qiblahDirection.accuracy)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: _getAccuracyColor(context, qiblahDirection.accuracy),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getAccuracyText(SensorAccuracy accuracy) {
    switch (accuracy) {
      case SensorAccuracy.high:
        return 'High';
      case SensorAccuracy.medium:
        return 'Medium';
      case SensorAccuracy.low:
        return 'Low';
      default:
        return 'Unknown';
    }
  }

  Color _getAccuracyColor(BuildContext context, SensorAccuracy accuracy) {
    switch (accuracy) {
      case SensorAccuracy.high:
        return Colors.green;
      case SensorAccuracy.medium:
        return Colors.orange;
      case SensorAccuracy.low:
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.error;
    }
  }
}

class _QiblahCompass extends StatelessWidget {
  final QiblahDirection qiblahDirection;

  const _QiblahCompass({required this.qiblahDirection});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      width: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceVariant,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          Transform.rotate(
            angle: (qiblahDirection.qiblah * (pi / 180) * -1),
            child: Image.network(
              'https://www.iconpacks.net/icons/2/free-compass-icon-2948-thumb.png',
              width: 200,
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.navigation, size: 50, color: Theme.of(context).primaryColor),
                      const Text('Qiblah'),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Qiblah',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
