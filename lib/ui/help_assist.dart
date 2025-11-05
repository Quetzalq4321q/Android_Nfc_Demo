import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:lottie/lottie.dart';

class AyudaPage extends StatefulWidget {
  const AyudaPage({super.key});

  @override
  State<AyudaPage> createState() => _AyudaPageState();
}

class _AyudaPageState extends State<AyudaPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/tutorial_nfc.mp4')
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Centro de Ayuda')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Guía de uso del sistema NexID Campus',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (_controller.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: VideoPlayer(_controller),
                ),
              )
            else
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              label: Text(
                _controller.value.isPlaying ? 'Pausar' : 'Reproducir',
              ),
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'Animación de lectura NFC',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Lottie.asset('assets/animations/nfc_read.json'),
          ],
        ),
      ),
    );
  }
}
