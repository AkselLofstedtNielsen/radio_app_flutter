import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TableuWidget extends StatelessWidget {
  final int channelId;

  const TableuWidget({Key? key, required this.channelId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableu Widget'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>?>?>(
        future: fetchTableuApi(channelId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Map<String, dynamic>?> tableu = snapshot.data ?? [];

            return ListView.builder(
              itemCount: tableu.length,
              itemBuilder: (context, index) {
                final item = tableu[index]!;
                return Card(
                  margin: EdgeInsets.all(8.0), // Add margin around the cards
                  elevation: 5, // Add a shadow effect
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12.0), // Apply rounded corners
                    side: BorderSide(
                        color: Colors.grey, width: 1.0), // Add a silver outline
                  ),
                  child: ListTile(
                    leading: Image.network(
                      item['imageurl'], // Make sure the field name is correct
                      errorBuilder: (context, error, stackTrace) {
                        return Text('Image load failed');
                      },
                    ),
                    title: Text(item['title']),
                    subtitle: Text(item['description']),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>?>?> fetchTableuApi(int channelId) async {
    print("channel id: $channelId");
    final dio = Dio();
    try {
      final response = await dio.get(
          'http://api.sr.se/api/v2/scheduledepisodes?channelid=${channelId.toString()}&format=json');
      if (response.statusCode == 200) {
        final data = response.data['schedule'];
        List<Map<String, dynamic>?> tableu = List<Map<String, dynamic>?>.from(
            data.map((item) => item as Map<String, dynamic>?));
        return tableu;
      } else {
        throw Exception("Failed to load data from API");
      }
    } catch (e) {
      throw Exception('Failed to load data from the API: $e');
    }
  }
}
