import 'package:flutter/material.dart';
import 'locaction_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Map Locator',
      home: QuoteGenerator(),
    );
  }
}

class QuoteGenerator extends StatefulWidget {
  const QuoteGenerator({super.key});

  @override
  State<QuoteGenerator> createState() => _QuoteGeneratorState();
}

class _QuoteGeneratorState extends State<QuoteGenerator> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Locator'),
      ),
      body: const Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LocationScreen(
              useGeoJsonFormat: false,
              autoUpdateLocation: true,
            ),
          ],
        ),
      ),
    );
  }
}





// void main() {
//   runApp(const LocationApp());
// }

// class LocationApp extends StatelessWidget {
//   const LocationApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Location App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const LocationScreen(),
//     );
//   }
// }
