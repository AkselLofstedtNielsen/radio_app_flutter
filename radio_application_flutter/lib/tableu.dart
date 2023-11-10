import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TableuWidget extends StatefulWidget {
  final int channelId;
  final DateTime selectedDate;

  const TableuWidget(
      {Key? key, required this.channelId, required this.selectedDate})
      : super(key: key);

  @override
  _TableuWidgetState createState() => _TableuWidgetState();
}

class _TableuWidgetState extends State<TableuWidget> {
  late ScrollController _scrollController;
  late List<Map<String, dynamic>?> tableu;
  bool isLoading = false;
  late DateTime _latestLoadedDate;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    tableu = [];
    _latestLoadedDate = widget.selectedDate;

    if (_latestLoadedDate == widget.selectedDate) {
      fetchData(_latestLoadedDate);
    }

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!isLoading) {
        final nextDate = _latestLoadedDate.add(const Duration(days: 1));
        print("next date: $nextDate");
        fetchData(nextDate);
      }
    }
  }

  Future<void> fetchData(DateTime date) async {
    setState(() {
      isLoading = true;
    });

    try {
      final dio = Dio();
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await dio.get(
          'http://api.sr.se/api/v2/scheduledepisodes?channelid=${widget.channelId}&date=$formattedDate&format=json');
      if (response.statusCode == 200) {
        final data = response.data['schedule'];
        List<Map<String, dynamic>?> newTableu =
            List<Map<String, dynamic>?>.from(
                data.map((item) => item as Map<String, dynamic>?));

        setState(() {
          if (tableu.isEmpty) {
            tableu.addAll(newTableu);
          } else {
            tableu.addAll(newTableu);
          }
        });
      } else {
        throw Exception("Failed to load data from API");
      }
    } catch (e) {
      print('Failed to load data from the API: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    _latestLoadedDate = date.add(const Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableu'),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              _scrollController.position.extentAfter == 0) {
            fetchData(_latestLoadedDate);
          }
          return false;
        },
        child: Container(
          color: const Color.fromARGB(255, 30, 30, 30),
          child: ListView.builder(
            controller: _scrollController,
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
                  leading: Image.network(
                    item['imageurl'],
                    height: 80,
                    width: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('Image load failed',
                          style: TextStyle(color: Colors.white));
                    },
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text(item['description'],
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14)),
                    ],
                  ),
                  subtitle: Text(
                    "$startTime-$endTime",
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

String convertTimestampToReadableTime(String timestamp) {
  try {
    final int milliseconds =
        int.parse(timestamp.replaceAll(RegExp(r'[^0-9]'), ''));
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

    final String formattedTime = DateFormat('HH:mm').format(dateTime);

    return formattedTime;
  } catch (e) {
    print("Error converting timestamp to readable time: $e");
    return "No time";
  }
}
