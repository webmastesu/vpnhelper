import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class AppScreen extends StatefulWidget {
  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  List<dynamic> apps = [];
  List<dynamic> filteredApps = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAppData();
    _searchController.addListener(_filterApps);
  }

  Future<void> fetchAppData() async {
    String encodedUrl = "VjFaV2IxVXdNVWhVYTJ4VlZrWndUbHBXVW5OT1ZtUlhZVWR3YTFadE9UVlphMUpEWVVaT1IxZHVRbUZTYldoUVdXdGtUMlJHVW5WWGJXeHBZa1Z3ZWxkWE1ERlZiVkpYWVROc1VGZEdTazVVVjNSYVRWWmtjMWt6YUU5V2JYaFpWRlpTVjFkc1dYcFZWRVpZVm0xb2NWcEhNVk5rVmtaMVZtMW9hV0Y2VlhsWFZ6RnlUbGRTUjJKR2FHbFRSbHBPVkZkMFlVMHhhM2RhUms1b1VqRktTVlZzYUZkaFIwcHlUbFJLV21KWFRUVlZSa1U1VUZFOVBRPT0=";
    String url = decodeBase64MultipleTimes(encodedUrl, 5);

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        apps = data['apps'];
        filteredApps = apps;
      });
    } else {
      throw Exception('Failed to load app data');
    }
  }

  String decodeBase64MultipleTimes(String encodedData, int times) {
    String decodedData = encodedData;
    for (int i = 0; i < times; i++) {
      decodedData = utf8.decode(base64Decode(decodedData));
    }
    return decodedData;
  }

  void _filterApps() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredApps = apps.where((app) {
        final appName = app['name'].toLowerCase();
        return appName.contains(query);
      }).toList();
    });
  }

  void _showDownloadDialog(Map<String, dynamic> downloads) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7), // Set maximum height
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDownloadButton('xxx.png', downloads['mac']),
                    _buildDownloadButton('android.png', downloads['android']),
                    _buildDownloadButton('windows.png', downloads['windows']),
                    _buildDownloadButton('ios.png', downloads['ios']),
                    SizedBox(height: 20),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDownloadButton(String iconName, String downloadUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center( // Centering the button horizontally
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Image.asset(
                'lib/assets/icons/$iconName',
                height: 40,
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _launchURL(downloadUrl),
              child: Text('Download'),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Page'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredApps.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: filteredApps.length,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: EdgeInsets.all(10),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        ClipOval(
                          child: Image.network(
                            filteredApps[index]['logo'],
                            height: 60,
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            filteredApps[index]['name'],
                            style: TextStyle(fontSize: 20),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () =>
                              _showDownloadDialog(filteredApps[index]['downloads']),
                          child: Text('Download'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
