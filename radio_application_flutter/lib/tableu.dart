import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TableuWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>?>?>(
      future: fetchTableuApi(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
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
              return ListTile(
                leading: Image.network(item['imageurl']),
                title: Text(item['title']),
                subtitle: Text(item['description']),
              );
            },
          );
        }
      },
    );
  }

  Future<List<Map<String, dynamic>?>?> fetchTableuApi() async {
    final dio = Dio();
    try {
      final response = await dio.get(
          'https://api.sr.se/api/v2/scheduledepisodes?channelid=164&format=json');
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
