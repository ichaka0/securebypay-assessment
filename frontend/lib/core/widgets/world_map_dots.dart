import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dotted world map drawn from `assets/data/world_map_dots.json`
/// (land coordinates on a grid, generated with the `dotted-map` npm package).
///
/// Painting ~4.7k points with one `drawRawPoints` call keeps it cheap and
/// crisp at any size, unlike a large SVG.
class WorldMapDots extends StatelessWidget {
  const WorldMapDots({
    super.key,
    this.color = const Color(0x2EFFFFFF),
    this.dotScale = 0.55,
  });

  final Color color;

  /// Dot size relative to grid spacing (1.0 = dots touch).
  final double dotScale;

  static Future<_MapData>? _cache;

  static Future<_MapData> _load() => _cache ??= rootBundle
      .loadString('assets/data/world_map_dots.json')
      .then(_MapData.parse);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_MapData>(
      future: _load(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) return const SizedBox.shrink();
        return AspectRatio(
          aspectRatio: data.width / data.height,
          child: CustomPaint(
            painter: _DotsPainter(data, color, dotScale),
          ),
        );
      },
    );
  }
}

class _MapData {
  _MapData(this.width, this.height, this.points);

  factory _MapData.parse(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    final raw = (json['points'] as List).cast<num>();
    return _MapData(
      (json['width'] as num).toDouble(),
      (json['height'] as num).toDouble(),
      Float32List.fromList(raw.map((n) => n.toDouble()).toList()),
    );
  }

  final double width;
  final double height;

  /// Interleaved x,y pairs in map units.
  final Float32List points;
}

class _DotsPainter extends CustomPainter {
  _DotsPainter(this.data, this.color, this.dotScale);

  final _MapData data;
  final Color color;
  final double dotScale;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / data.width;
    canvas.save();
    canvas.scale(scale);
    final paint = Paint()
      ..color = color
      ..strokeWidth = dotScale
      ..strokeCap = StrokeCap.square;
    canvas.drawRawPoints(ui.PointMode.points, data.points, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DotsPainter old) =>
      old.color != color || old.dotScale != dotScale || old.data != data;
}
