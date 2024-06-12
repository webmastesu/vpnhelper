import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'app_screen.dart';
import 'dart:html' as html;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> buttons = [];
  List<dynamic> slider = [];
  late PageController _pageController;
  Timer? _timer;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    fetchData();
    startSlider();
  }

  void startSlider() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients && slider.isNotEmpty) {
        int nextPage = ((_pageController.page ?? 0).round() + 1) % slider.length;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  Future<void> fetchData() async {
    String encodedUrl = "VjFaV2IxVXdNVWhVYTJ4VlZrWndUbHBXVW5OT1ZtUlhZVWR3YTFadE9UVlphMUpEWVVaT1IxZHVRbUZTYldoUVdXdGtUMlJHVW5WWGJXeHBZa1Z3ZWxkWE1ERlZiVkpYWVROc1VGZEdTazVVVjNSYVRWWmtjMWt6YUU5V2JYaFpWRlpTVjFkc1dYcFZWRVpZVm0xb2NWcEhNVk5rVmtaMVZtMW9hV0Y2VlhsWFZ6RnlUbGRTUjJKR2FHbFRSbHBPVkZSR2QwMHhiSFJOV0dSc1lsVnNOVlJyYUZkaFIwcHlUbFJLV21KWFRUVlZSa1U1VUZFOVBRPT0=";
    String url = decodeBase64MultipleTimes(encodedUrl, 5);

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        buttons = data['buttons'];
        slider = data['slider'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  String decodeBase64MultipleTimes(String encodedData, int times) {
    String decodedData = encodedData;
    for (int i = 0; i < times; i++) {
      decodedData = utf8.decode(base64Decode(decodedData));
    }
    return decodedData;
  }

  void _launchURL(String url) async {
    try {
      // Open the URL using html.window.open
      html.window.open(url, '_blank');
    } catch (e) {
      // Handle error
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _widgetOptions() {
    return [
      _buildHomeScreen(),
      _buildAppScreen(),
      _buildSettingsScreen(),
    ];
  }

  Widget _buildHomeScreen() {
    return slider.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Column(
      children: [
        // Slider
        Expanded(
          flex: 2,
          child: PageView.builder(
            controller: _pageController,
            itemCount: slider.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _launchURL(slider[index]['link']),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  margin: EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      slider[index]['image'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Buttons
        Expanded(
          flex: 3,
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3,
            ),
            itemCount: buttons.length,
            itemBuilder: (context, index) {
              return ElevatedButton(
                onPressed: () => _launchURL(buttons[index]['link']),
                child: Text(buttons[index]['name']),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppScreen() {
    return AppScreen(); // Navigate to AppScreen
  }

  Widget _buildSettingsScreen() {
    return Center(
      child: Text('Settings Screen', style: TextStyle(fontSize: 24)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CatBook'),
      ),
      body: _widgetOptions().elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: 'App',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
