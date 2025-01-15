// lib/main.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Server Driven UI Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? uiConfig;
  bool isLoading = true;
  bool isDarkMode = false;
  final String _themePreferenceKey = 'isDarkMode';

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    fetchUIConfig();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool(_themePreferenceKey) ?? false;
    });
  }

  Future<void> _saveThemePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePreferenceKey, value);
  }

  Future<void> fetchUIConfig() async {
    try {
      final response = await http.get(Uri.parse('https://raw.githubusercontent.com/singhrishabh93/JSON-Hosting/refs/heads/main/uifinal.json'));
      if (response.statusCode == 200) {
        setState(() {
          uiConfig = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        uiConfig = {
          "uiConfig": {
            "theme": "light",
            "primaryColor": "#2196F3",
            "buttonStyle": {
              "radius": 8.0,
              "height": 48.0,
              "width": 200.0
            },
            "components": ["header", "searchBar", "productList"]
          },
          "features": {
            "darkMode": true,
            "search": true,
            "filters": true
          }
        };
        isLoading = false;
      });
    }
  }

  Color getPrimaryColor() {
    String colorHex = uiConfig?["uiConfig"]["primaryColor"] ?? "#2196F3";
    colorHex = colorHex.replaceAll("#", "");
    return Color(int.parse("0xFF$colorHex"));
  }

  ThemeData _getThemeData() {
    return isDarkMode
        ? ThemeData.dark().copyWith(
            primaryColor: getPrimaryColor(),
            appBarTheme: AppBarTheme(
              backgroundColor: getPrimaryColor(),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: getPrimaryColor(),
            ),
          )
        : ThemeData.light().copyWith(
            primaryColor: getPrimaryColor(),
            appBarTheme: AppBarTheme(
              backgroundColor: getPrimaryColor(),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: getPrimaryColor(),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _getThemeData(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Server Driven UI'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (uiConfig!["uiConfig"]["components"].contains("header"))
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: getPrimaryColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Text(
                    'Welcome to Server Driven UI Demo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

              const SizedBox(height: 16),

              if (uiConfig!["uiConfig"]["components"].contains("searchBar") &&
                  uiConfig!["features"]["search"])
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        uiConfig!["uiConfig"]["buttonStyle"]["radius"],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              if (uiConfig!["uiConfig"]["components"].contains("productList"))
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          color: getPrimaryColor().withOpacity(0.2),
                          child: Center(child: Text('${index + 1}')),
                        ),
                        title: Text('Product ${index + 1}'),
                        subtitle: Text('Description for product ${index + 1}'),
                        trailing: SizedBox(
                          width: uiConfig!["uiConfig"]["buttonStyle"]["width"] / 2,
                          height: uiConfig!["uiConfig"]["buttonStyle"]["height"],
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: getPrimaryColor(),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  uiConfig!["uiConfig"]["buttonStyle"]["radius"],
                                ),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text('Buy'),
                          ),
                        ),
                      ),
                    );
                  },
                ),

              if (uiConfig!["features"]["darkMode"])
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      isDarkMode = value;
                      _saveThemePreference(value);
                    });
                  },
                ),

              if (uiConfig!["features"]["filters"])
                ExpansionTile(
                  title: const Text('Filters'),
                  children: [
                    CheckboxListTile(
                      title: const Text('New Arrivals'),
                      value: false,
                      onChanged: (value) {},
                    ),
                    CheckboxListTile(
                      title: const Text('On Sale'),
                      value: false,
                      onChanged: (value) {},
                    ),
                    CheckboxListTile(
                      title: const Text('Popular'),
                      value: false,
                      onChanged: (value) {},
                    ),
                  ],
                ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            setState(() => isLoading = true);
            await fetchUIConfig();
          },
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}