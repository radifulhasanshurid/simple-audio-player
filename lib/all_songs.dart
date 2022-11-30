import 'dart:developer';

import 'package:audio_player1/now_playing.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class AllSongs extends StatefulWidget {
  const AllSongs({super.key});

  @override
  State<AllSongs> createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermission();
  }

  void requestPermission() {
    Permission.storage.request();
  }

  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  playSongs(String? uri) {
    try {
      _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
      _audioPlayer.play();
    } on Exception {
      log("Error parsing song");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Music Player-Shurid'),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
        ),
        body: FutureBuilder<List<SongModel>>(
          future: _audioQuery.querySongs(
              sortType: null,
              orderType: OrderType.ASC_OR_SMALLER,
              uriType: UriType.EXTERNAL,
              ignoreCase: true),
          builder: ((context, item) {
            if (item.data == null) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (item.data!.isEmpty) {
              return Text("No Songs Found!");
            }
            return ListView.builder(
              itemBuilder: ((context, index) => ListTile(
                    leading: QueryArtworkWidget(
                      id: item.data![index].id,
                      type: ArtworkType.AUDIO,
                      nullArtworkWidget: Icon(Icons.music_note),
                    ),
                    title: Text(item.data![index].displayNameWOExt),
                    subtitle: Text("${item.data![index].artist}"),
                    trailing: Icon(Icons.more_horiz),
                    onTap: () {
                      // playSongs(item.data![index].uri);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: ((context) => NowPlaying(
                                songModel: item.data![index],
                                audioPlayer: _audioPlayer,
                              )),
                        ),
                      );
                    },
                  )),
              itemCount: item.data!.length,
            );
          }),
        ));
  }
}
