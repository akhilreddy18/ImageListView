import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:favorite_button/favorite_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './modals/data.dart';

void main() => runApp(const MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Data>> futureData;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late SharedPreferences _pref;
  bool _isloading = false;

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
    getSharedPrefs();
  }

  Future<List<Data>> fetchData() async {
    final response = await http
        .get(Uri.parse("https://jsonplaceholder.typicode.com/photos"));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Data.fromJson(data)).toList();
    } else {
      throw Exception('Unexpected error occured!');
    }
  }

  getSharedPrefs() async {
    setState(() {
      _isloading = true;
    });
    _pref = await SharedPreferences.getInstance();
    setState(() {
      _isloading = false;
    });
  }

  Future<void> _addToFavorite(int index) async {
    final SharedPreferences prefs = await _prefs;
    String? _isFav = prefs.getString(index.toString());
    _isFav == "True"
        ? prefs.setString(index.toString(), "False")
        : prefs.setString(index.toString(), "True");
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return _isloading
        ? const Center(child: CircularProgressIndicator())
        : MaterialApp(
            title: 'Image lister',
            home: Scaffold(
              appBar: AppBar(
                title: const Center(child: Text('Images')),
              ),
              body: Center(
                child: FutureBuilder<List<Data>>(
                  future: futureData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Data>? data = snapshot.data;
                      return ListView.builder(
                          itemCount: data?.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                                child: ListTile(
                              leading: GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                            elevation: 16,
                                            child: SizedBox(
                                              child: Image.network(
                                                data![index].url,
                                              ),
                                              height: height * 0.42,
                                              width: width,
                                            ));
                                      });
                                },
                                child: CircleAvatar(
                                  radius: width * 0.06,
                                  child: ClipOval(
                                    child: Image.network(
                                      data![index].thumbnailUrl,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(data[index].title),
                              trailing: FavoriteButton(
                                isFavorite:
                                    _pref.getString(index.toString()) == "True"
                                        ? true
                                        : false,
                                valueChanged: (_isFavorite) {
                                  _addToFavorite(index);
                                },
                              ),
                            ));
                          });
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return const CircularProgressIndicator();
                  },
                ),
              ),
            ),
          );
  }
}
