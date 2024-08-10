import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:teaching_app/database/datebase_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_win/video_player_win.dart';

class CustomVideoPlayer extends StatefulWidget {
  final dynamic controller;
  final int onlineTopicDataId;
  final int instituteTopicId;
  const CustomVideoPlayer(
      {super.key,
      required this.controller,
      required this.onlineTopicDataId,
      required this.instituteTopicId});

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  ValueNotifier<bool> _isPlaying = ValueNotifier(true);
  ValueNotifier<bool> _isFullScreen = ValueNotifier(false);

  ValueNotifier<int> currentPosition = ValueNotifier(0);
  ValueNotifier<double> volume = ValueNotifier(0.5);
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
      _isPlaying.value = true;
    }
    if (widget.controller.value.position.inSeconds ==
        widget.controller.value.duration.inSeconds) {
      _isPlaying.value = false;
      final dbController = Get.find<DatabaseController>();
      dbController.updateContentProgress(widget.onlineTopicDataId,
          instituteTopicId: widget.instituteTopicId);
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

  void showFullScreen() {
    showDialog(
        context: context,
        builder: (context) {
          return Material(child: videoWidget());
        });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: _isFullScreen,
        builder: (context, value, _) {
          return _isFullScreen.value ? const SizedBox.shrink() : videoWidget();
        });
  }

  Widget videoWidget() {
    return Stack(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: widget.controller.value.aspectRatio,
            child: GetPlatform.isWindows
                ? WinVideoPlayer(widget.controller)
                : VideoPlayer(widget.controller),
          ),
        ),
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
                      ValueListenableBuilder<bool>(
                          valueListenable: _isPlaying,
                          builder: (context, value, _) {
                            return GestureDetector(
                                child: Icon(
                                  value ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                onTap: () {
                                  if (value) {
                                    widget.controller.pause();
                                  } else if (widget.controller.value.position
                                          .inSeconds ==
                                      widget.controller.value.duration
                                          .inSeconds) {
                                    widget.controller
                                        .seekTo(Duration(seconds: 0));
                                    widget.controller.play();
                                  } else {
                                    widget.controller.play();
                                  }

                                  _isPlaying.value = !value;
                                });
                          }),
                      const SizedBox(
                        width: 2,
                      ),
                      ValueListenableBuilder<double>(
                          valueListenable: volume,
                          builder: (context, value, _) {
                            return GestureDetector(
                                child: Icon(
                                  value == 0
                                      ? Icons.volume_off
                                      : Icons.volume_up_sharp,
                                  color: Colors.white,
                                ),
                                onTap: () {
                                  if (value == 0) {
                                    widget.controller.setVolume(1.0);
                                    volume.value = 1;
                                  } else {
                                    widget.controller.setVolume(0);
                                    volume.value = 0;
                                  }
                                });
                          }),
                      const SizedBox(
                        width: 10,
                      ),
                      ValueListenableBuilder<double>(
                          valueListenable: volume,
                          builder: (context, value, _) {
                            return SizedBox(
                              width: 45,
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackShape: CustomTrackShape(),
                                  thumbShape:
                                      CustomSliderThumbShape(thumbRadius: 7),
                                ),
                                child: Slider(
                                    activeColor: Colors.blue,
                                    inactiveColor: Colors.grey.shade300,
                                    value: value,
                                    onChanged: (value) {
                                      widget.controller.setVolume(value);
                                      volume.value = value;
                                    }),
                              ),
                            );
                          }),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        formatDuration(
                            widget.controller.value.position.inSeconds),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackShape: CustomTrackShape(),
                            thumbShape: CustomSliderThumbShape(thumbRadius: 8),
                          ),
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
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Text(
                        formatDuration(
                            widget.controller.value.duration.inSeconds),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      GestureDetector(
                          child: Icon(
                            _isFullScreen.value
                                ? Icons.fullscreen_exit
                                : Icons.fullscreen,
                            color: Colors.white,
                          ),
                          onTap: () {
                            if (_isFullScreen.value) {
                              Navigator.pop(context);
                            } else {
                              showFullScreen();
                            }

                            _isFullScreen.value = !_isFullScreen.value;
                          }),
                    ],
                  );
                }),
          ),
        )
      ],
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 0;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class CustomSliderThumbShape extends RoundSliderThumbShape {
  final double thumbRadius;

  CustomSliderThumbShape({this.thumbRadius = 10.0});

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final Paint paint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, thumbRadius, paint);
  }

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }
}
