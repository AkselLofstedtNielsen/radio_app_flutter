import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:radio_application_flutter/tableu.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>?>?>(
        future: fetchChannelsApi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Map<String, dynamic>?> channels = snapshot.data ?? [];

            return ListView.builder(
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final item = channels[index]!;
                int channelId = item['id'];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TableuWidget(channelId: channelId),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: Image.network(item['image']),
                    title: Text(item['name']),
                    subtitle: Text(item['tagline']),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>?>?> fetchChannelsApi() async {
    final dio = Dio();
    try {
      final response =
          await dio.get('http://api.sr.se/api/v2/channels?format=json');
      if (response.statusCode == 200) {
        final data = response.data['channels'];
        List<Map<String, dynamic>?> channels = List<Map<String, dynamic>?>.from(
            data.map((item) => item as Map<String, dynamic>?));
        return channels;
      } else {
        throw Exception('Failed to load channels from API');
      }
    } catch (e) {
      throw Exception('Failed to load channels from API: $e');
    }
  }
}
