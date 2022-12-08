import 'dart:async';

import 'package:cached_video_player/cached_video_player.dart';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:visibility_detector/visibility_detector.dart';

CachedVideoPlayerController? activeController;

class VideoPlayer extends StatefulWidget {
  final String videoUrl;

  final String thumbnailUrl;

  const VideoPlayer({
    Key? key,
    required this.videoUrl,
    required this.thumbnailUrl,
  }) : super(key: key);

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  CachedVideoPlayerController? _videoController;
  

  final UniqueKey stickyKey = UniqueKey();

  bool isControllerReady = false;

  bool isPlaying = false;

  Completer videoPlayerInitializedCompleter = Completer();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() async {
    if (_videoController != null)
      await _videoController?.dispose()?.then((_) {
        isControllerReady = false;

        _videoController = null;

        videoPlayerInitializedCompleter = Completer(); // resets the Completer
      });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0),
      child: VisibilityDetector(
        key: stickyKey,
        onVisibilityChanged: (VisibilityInfo info) async {
          if (info.visibleFraction > 0.70) {
            if (_videoController == null) {
              _videoController =
                  CachedVideoPlayerController.network(widget.videoUrl);

              _videoController!.initialize().then((_) async {
                videoPlayerInitializedCompleter.complete(true);

                setState(() {
                  isControllerReady = true;
                });

                _videoController!.setLooping(true);
              });
            }
          } else if (info.visibleFraction < 0.30) {
            setState(() {
              isControllerReady = false;
            });

            _videoController?.pause();

            setState(() {
              isPlaying = false;
            });

            WidgetsBinding.instance!.addPostFrameCallback((_) {
              if (activeController == _videoController) {
                activeController = null;
              }

              _videoController?.dispose()?.then((_) {
                setState(() {
                  _videoController = null;

                  videoPlayerInitializedCompleter =
                      Completer(); // resets the Completer
                });
              });
            });
          }
        },
        child: FutureBuilder( 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                _videoController != null &&
                isControllerReady) {
              // should also check that the video has not been disposed

              return GestureDetector(
                  onTap: () async {
                    setState(() {
                      if (_videoController!.value.isPlaying) {
                        _videoController?.pause();

                        setState(() {
                          isPlaying = false;
                        });
                      } else {
                        if (activeController != null) {
                          setState(() {
                            activeController!.pause();
                          });
                        }

                        activeController = _videoController;

                        _videoController?.play();

                        setState(() {
                          isPlaying = true;
                        });
                      }
                    });
                  },
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      AspectRatio(
                          aspectRatio: 4 / 3,
                          child: CachedVideoPlayer(_videoController!)),
                      !isPlaying
                          ? Icon(
                              CupertinoIcons.play_arrow_solid,
                              color: Colors.white70,
                              size: 54,
                            )
                          : Container(
                              height: 0.0,
                            ),
                    ],
                  )); // display the video

            }

            return AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          },
          future: videoPlayerInitializedCompleter.future,
        ),
      ),
    );
  }
}
