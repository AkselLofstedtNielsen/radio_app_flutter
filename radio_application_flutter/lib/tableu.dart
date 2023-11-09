import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                  String startTime =
                      convertTimestampToReadableTime(item['starttimeutc']);
                  String endTime =
                      convertTimestampToReadableTime(item['endtimeutc']);
                  return Card(
                    color: const Color.fromARGB(255, 30, 30, 30),
                    margin: const EdgeInsets.all(8.0),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: const BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    child: ListTile(
                      // Image to the left
                      leading: Image.network(
                        item['imageurl'],
                        height: 80, // Set the height of the image
                        width: 80, // Set the width of the image
                        errorBuilder: (context, error, stackTrace) {
                          return const Text('Image load failed',
                              style: TextStyle(color: Colors.white));
                        },
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title at the top
                          Text(item['title'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          // Description in the middle next to the image
                          Text(item['description'],
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14)),
                        ],
                      ),
                      // Start and End Time at the bottom
                      subtitle: Text(
                        "$startTime-$endTime",
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  );
                },
              ),
            );
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

String convertTimestampToReadableTime(String timestamp) {
  try {
    final int milliseconds =
        int.parse(timestamp.replaceAll(RegExp(r'[^0-9]'), ''));
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

    // Format the DateTime to show only hour and minute
    final String formattedTime = DateFormat('HH:mm').format(dateTime);

    return formattedTime;
  } catch (e) {
    print("Error converting timestamp to readable time: $e");
    return "N/A";
  }
}
