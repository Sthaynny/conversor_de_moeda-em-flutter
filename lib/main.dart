import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=3465ba11";

void main() async {
  //http.Response response = await http.get(request);
  //print(json.decode(response.body)["results"]["currencies"]["USD"]);

  print(await getData());

  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
          hintColor: Colors.amber,
          primaryColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber))))));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

// Cria so é digitar statful
class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsPrecision(2);
    euroController.text = (real / euro).toStringAsPrecision(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
    }
    double ddolar = double.parse(text);
    realController.text = (ddolar * dolar).toStringAsPrecision(2);
    euroController.text = ((ddolar * dolar) / euro).toStringAsPrecision(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
    }
    double eeuro = double.parse(text);
    realController.text = (eeuro * euro).toStringAsPrecision(2);
    dolarController.text = ((eeuro * euro) / dolar).toStringAsPrecision(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Convesor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados...",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
              );
              break;
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregar Dados... :(",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  //Tela rolavel
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.amber,
                      ),
                      buildTextField(
                          "Reais", "R\$", realController, _realChanged),
                      Divider(),
                      buildTextField(
                          "Dolares", "US\$", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField(
                          "Euros", "€", euroController, _euroChanged),
                    ],
                  ),
                );
              }
              break;
          }
        },
      ), //Fica carregando até rwceber os dados
    );
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber, fontSize: 20.0),
      border: OutlineInputBorder(),
      prefixText: prefix + " ",
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}
