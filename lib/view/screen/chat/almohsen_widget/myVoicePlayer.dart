import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class VoicePlayer extends StatefulWidget {
  final File? audioFile;
  final Function? onDelete;
  final String? audioUrl;

  const VoicePlayer({Key? key, this.audioFile, this.audioUrl, this.onDelete})
      : super(key: key);

  @override
  _VoicePlayerState createState() => _VoicePlayerState();
}

class _VoicePlayerState extends State<VoicePlayer> {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  double currentPlaybackPosition = 0;
  double maxPlaybackPosition = 0;

  @override
  void initState() {
    super.initState();

    if (widget.audioFile == null) {
      audioPlayer.setSource(UrlSource(widget.audioUrl!));
    } else {
      audioPlayer.setSource(DeviceFileSource(widget.audioFile!.path));
    }
    audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        maxPlaybackPosition = duration.inMilliseconds.toDouble();
      });
    });

    audioPlayer.onPositionChanged.listen((Duration duration) {
      setState(() {
        currentPlaybackPosition = duration.inMilliseconds.toDouble();
      });
    });

    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        currentPlaybackPosition = 0;
      });
    });
  }

  void onPlayButtonPressed() async {
    if (!isPlaying) {
      if (widget.audioFile == null ) {
        await audioPlayer.play(UrlSource(widget.audioUrl! ));
      }else { await audioPlayer.play(DeviceFileSource(widget.audioFile!.path));}

    } else {
      await audioPlayer.pause();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override@override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onPlayButtonPressed,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
          ),
          maxPlaybackPosition >= 0
              ? Expanded(
            child: Slider(
              value: currentPlaybackPosition,
              min: 0,
              max: maxPlaybackPosition,
              onChanged: (double value) {
                setState(() {
                  currentPlaybackPosition = value;
                });
                audioPlayer.seek(Duration(milliseconds: value.toInt()));
              },
              activeColor: Colors.blueGrey,
              inactiveColor: Colors.grey,
            ),
          )
              : Container(
            width: 100,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Text(
            '${(currentPlaybackPosition ~/ 1000).toString()} : ${(maxPlaybackPosition ~/ 1000).toString()}',
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(
            width: 10,
          ),
          widget.audioFile != null
              ? GestureDetector(
            onTap: () {
              if (widget.onDelete != null) {
                widget.onDelete!();
              }
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}