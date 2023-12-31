import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:radio_application_flutter/tableu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, Key? keys});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key, Key? keys});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime selectedDate = DateTime.now();
  bool isPlaying = false;
  late int currentPlayingChannelId;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Radio'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>?>?>(
        future: fetchChannelsApi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Map<String, dynamic>?> channels = snapshot.data ?? [];

            return Container(
              color: const Color.fromARGB(255, 28, 28, 28),
              child: ListView.builder(
                itemCount: channels.length,
                itemBuilder: (context, index) {
                  final item = channels[index]!;
                  int channelId = item['id'];
                  return Card(
                    color: const Color.fromARGB(255, 28, 28, 28),
                    margin: const EdgeInsets.all(8.0),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 220, 220, 220),
                        width: 1.0,
                      ),
                    ),
                    child: ListTile(
                      leading: SizedBox(
                        width: 60,
                        height: 60,
                        child: Center(
                          child: Image.network(
                            item['image'],
                            errorBuilder: (context, error, stackTrace) {
                              return const Text('Image load failed',
                                  style: TextStyle(color: Colors.white));
                            },
                          ),
                        ),
                      ),
                      title: Text(
                        item['name'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        item['tagline'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isPlaying && currentPlayingChannelId == channelId
                                  ? Icons.stop
                                  : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                isPlaying = !isPlaying ||
                                    currentPlayingChannelId != channelId;
                                currentPlayingChannelId = channelId;
                                if (isPlaying) {
                                  playAudio(item['liveaudio']['url']);
                                } else {
                                  stopAudio();
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.info,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TableuWidget(
                                    channelId: channelId,
                                    selectedDate: selectedDate,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
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

  void playAudio(String url) {
    audioPlayer.play(UrlSource(url));
    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
      });
    });
  }

  void stopAudio() {
    audioPlayer.stop();
    setState(() {
      isPlaying = false;
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
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
