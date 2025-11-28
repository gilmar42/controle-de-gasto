// Script para gerar ícone do app
// Execute com: flutter run -d windows tool/generate_icon.dart

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(const IconGeneratorApp());
}

class IconGeneratorApp extends StatelessWidget {
  const IconGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: IconGenerator(),
        ),
      ),
    );
  }
}

class IconGenerator extends StatefulWidget {
  const IconGenerator({super.key});

  @override
  State<IconGenerator> createState() => _IconGeneratorState();
}

class _IconGeneratorState extends State<IconGenerator> {
  final GlobalKey _iconKey = GlobalKey();
  final GlobalKey _foregroundKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateIcons();
    });
  }

  Future<void> _generateIcons() async {
    try {
      // Gerar ícone principal
      await _captureAndSave(_iconKey, 'assets/images/app_icon.png');
      
      // Gerar foreground
      await _captureAndSave(_foregroundKey, 'assets/images/app_icon_foreground.png');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Ícones gerados com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erro: $e')),
        );
      }
    }
  }

  Future<void> _captureAndSave(GlobalKey key, String path) async {
    final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    
    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsBytes(buffer);
    print('✅ Gerado: $path');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ícone completo
        RepaintBoundary(
          key: _iconKey,
          child: Container(
            width: 1024,
            height: 1024,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(180),
            ),
            child: _buildIconContent(),
          ),
        ),
        const SizedBox(height: 20),
        // Foreground apenas
        RepaintBoundary(
          key: _foregroundKey,
          child: Container(
            width: 1024,
            height: 1024,
            color: Colors.transparent,
            child: _buildIconContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildIconContent() {
    return Center(
      child: Container(
        width: 700,
        height: 700,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            // R$ principal
            Center(
              child: Text(
                'R\$',
                style: TextStyle(
                  fontSize: 320,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4CAF50),
                  height: 1.2,
                ),
              ),
            ),
            // Seta verde (receita)
            Positioned(
              top: 80,
              left: 180,
              child: Icon(
                Icons.arrow_upward,
                size: 100,
                color: const Color(0xFF4CAF50).withOpacity(0.6),
              ),
            ),
            // Seta vermelha (despesa)
            Positioned(
              bottom: 80,
              right: 180,
              child: Icon(
                Icons.arrow_downward,
                size: 100,
                color: const Color(0xFFF44336).withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
