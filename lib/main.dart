import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

const request = 'https://api.hgbrasil.com/finance?key=dfaf9a13';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
      theme: ThemeData(
        fontFamily: 'Raleway Regular',
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        ),
      ),
    ),
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return jsonDecode(response.body);
}

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();
  final yenController = TextEditingController();

  late double dollar;
  late double euro;
  late double yen;

  void _realChanged(String text) {
    if (text.isEmpty) {
      dollarController.text = '';
      euroController.text = '';
      yenController.text = '';
    } else {
      double inputReal = double.parse(text);
      double outputDollar = inputReal / dollar;
      double outputEuro = inputReal / euro;
      double outputYen = inputReal / yen;

      dollarController.text = outputDollar.toStringAsFixed(2);
      euroController.text = outputEuro.toStringAsFixed(2);
      yenController.text = outputYen.toStringAsFixed(2);
    }
  }

  void _dollarChanged(String text) {
    if (text.isEmpty) {
      realController.text = '';
      euroController.text = '';
      yenController.text = '';
    } else {
      double inputDollar = double.parse(text);
      double outputReal = inputDollar * dollar;
      double outputEuro = outputReal / euro;
      double outputYen = outputReal / yen;
      // outputYen = Convert Dollar to Real and after that to Yen

      realController.text = outputReal.toStringAsFixed(2);
      euroController.text = outputEuro.toStringAsFixed(2);
      yenController.text = outputYen.toStringAsFixed(2);
    }
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      realController.text = '';
      dollarController.text = '';
      yenController.text = '';
    } else {
      double inputEuro = double.parse(text);
      double outputReal = inputEuro * euro;
      double outputDollar = outputReal / dollar;
      double outputYen = outputReal / yen;
      // outputYen = Convert Dollar to Real and after that to Yen

      realController.text = outputReal.toStringAsFixed(2);
      dollarController.text = outputDollar.toStringAsFixed(2);
      yenController.text = outputYen.toStringAsFixed(2);
    }
  }

  void _yenChanged(String text) {
    if (text.isEmpty) {
      realController.text = '';
      dollarController.text = '';
      euroController.text = '';
    } else {
      double inputYen = double.parse(text);
      double outputReal = inputYen * yen;
      double outputDollar = outputReal / dollar;
      double outputEuro = outputReal / euro;

      realController.text = outputReal.toStringAsFixed(3);
      dollarController.text = outputDollar.toStringAsFixed(3);
      euroController.text = outputEuro.toStringAsFixed(3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Currency Converter',
            style: TextStyle(
              fontFamily: 'Raleway Bold',
            )),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25.0,
                  ),
                ),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Error!',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25.0,
                    ),
                  ),
                );
              } else {
                dollar = snapshot.data!['results']['currencies']['USD']['buy'];
                euro = snapshot.data!['results']['currencies']['EUR']['buy'];
                yen = snapshot.data!['results']['currencies']['JPY']['buy'];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.amber,
                      ),
                      const Divider(),
                      buildTextField('Brazilian Real', 'R\$ ', realController,
                          _realChanged),
                      const Divider(),
                      buildTextField('American Dollar', 'US\$ ',
                          dollarController, _dollarChanged),
                      const Divider(),
                      buildTextField(
                          'Euro', '€ ', euroController, _euroChanged),
                      const Divider(),
                      buildTextField(
                          'Japanese Yen', '¥ ', yenController, _yenChanged),
                      const Divider(),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController fieldController, Function(String) func) {
  return TextField(
    controller: fieldController,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.amber,
      ),
      prefixText: prefix,
    ),
    style: const TextStyle(
      color: Colors.amber,
      fontSize: 25.0,
    ),
    keyboardType: TextInputType.number,
    onChanged: func,
  );
}
