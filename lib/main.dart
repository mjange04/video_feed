import 'package:flutter/material.dart';
import 'package:video_test/utils.dart';
import 'package:video_test/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: VideoListView());
  }
}

class VideoListView extends StatelessWidget {
  const VideoListView({
    Key? key,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Feeds"),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return VideoPlayer(
            videoUrl: videos_url[index],
            thumbnailUrl:
                'https://i3.ytimg.com/vi/E5ufm-Hmt5U/maxresdefault.jpg',
          );
        },
        itemCount: videos_url.length,
        padding: EdgeInsets.symmetric(vertical: 10.0),
      ),
    );
  }
}
