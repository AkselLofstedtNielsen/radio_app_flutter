import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TableuWidget extends StatelessWidget {
  final int channelId;

  const TableuWidget({Key? key, required this.channelId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableu Widget'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>?>?>(
        future: fetchTableuApi(channelId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Map<String, dynamic>?> tableu = snapshot.data ?? [];

            return Container(
                color: const Color.fromARGB(255, 30, 30, 30),
                child: ListView.builder(
                  itemCount: tableu.length,
                  itemBuilder: (context, index) {
                    final item = tableu[index]!;
                    return Card(
                      color: const Color.fromARGB(255, 30, 30, 30),
                      margin:
                          const EdgeInsets.all(8.0), // Margin around the cards
                      elevation: 5, // Shadow effect
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12.0), // Rounded corners
                        side: const BorderSide(
                            color: Colors.grey, width: 1.0), // Silver outline
                      ),
                      child: ListTile(
                        leading: Image.network(
                          item['imageurl'],
                          errorBuilder: (context, error, stackTrace) {
                            return const Text('Image load failed',
                                style: TextStyle(color: Colors.white));
                          },
                        ),
                        title: Text(item['title'],
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(item['description'],
                            style: const TextStyle(color: Colors.white)),
                      ),
                    );
                  },
                ));
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>?>?> fetchTableuApi(int channelId) async {
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
