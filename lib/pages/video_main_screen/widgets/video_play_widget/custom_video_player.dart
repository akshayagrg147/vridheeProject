import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  const CustomVideoPlayer({super.key, required this.controller});

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  bool _isPlaying = true;
  ValueNotifier<int> currentPosition = ValueNotifier(0);
  String formatDuration(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    String hoursStr = hours.toString().padLeft(1, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');
    String result = '';
    if (hours > 0) {
      result += "$hoursStr:";
    }
    result += '$minutesStr:$secondsStr';
    return result;
  }

  updatePosition() {
    currentPosition.value = widget.controller.value.position.inSeconds;
    if (widget.controller.value.isPlaying) {
      _isPlaying = true;
    }
    if (widget.controller.value.position.inSeconds ==
        widget.controller.value.duration.inSeconds) {
      _isPlaying = false;
    }
  }

  @override
  void initState() {
    widget.controller.addListener(updatePosition);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(updatePosition);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.controller.value.aspectRatio,
      child: Stack(
        children: [
          VideoPlayer(widget.controller),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 34,
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              color: Colors.black.withOpacity(0.5),
              child: ValueListenableBuilder(
                  valueListenable: currentPosition,
                  builder: (context, value, _) {
                    return Row(
                      children: [
                        GestureDetector(
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onTap: () {
                              if (_isPlaying) {
                                widget.controller.pause();
                              } else if (widget
                                      .controller.value.position.inSeconds ==
                                  widget.controller.value.duration.inSeconds) {
                                widget.controller.seekTo(Duration(seconds: 0));
                                widget.controller.play();
                              } else {
                                widget.controller.play();
                              }

                              setState(() {
                                _isPlaying = !_isPlaying;
                              });
                            }),
                        SizedBox(
                          width: 2,
                        ),
                        Text(
                          formatDuration(
                              widget.controller.value.position.inSeconds),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w600),
                        ),
                        Expanded(
                          child: Slider(
                              activeColor: Colors.blue,
                              inactiveColor: Colors.grey.shade300,
                              value: widget
                                      .controller.value.position.inSeconds /
                                  widget.controller.value.duration.inSeconds,
                              onChanged: (value) {
                                widget.controller.seekTo(Duration(
                                    seconds: (widget.controller.value.duration
                                                .inSeconds *
                                            value)
                                        .round()));
                              }),
                        ),
                        Text(
                          formatDuration(
                              widget.controller.value.duration.inSeconds),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    );
                  }),
            ),
          )
        ],
      ),
    );
  }
}
