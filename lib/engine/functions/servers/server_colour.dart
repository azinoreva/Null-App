// module name: server_colour.dart

import 'dart:math';

/// Generate a bright colour (0xRRGGBB) that is not in [usedColours].
/// If all palette colours are used, returns the one farthest from all used.
int pickDistinctColour(List<int> usedColours) {
  // Pre‑generate a palette of 256 bright, evenly‑spaced colours.
  // We use HSL with full saturation (1.0) and medium lightness (0.6),
  // and spread hues using the golden ratio for maximum spacing.
  const int paletteSize = 256;
  const double saturation = 1.0;
  const double lightness = 0.6;
  const double golden = 0.618033988749895;

  final palette = List.generate(paletteSize, (i) {
    final hue = (i * golden) % 1.0;
    return _hslToRgbInt(hue, saturation, lightness);
  });

  // Try to pick the first unused colour.
  final usedSet = usedColours.toSet();
  for (final colour in palette) {
    if (!usedSet.contains(colour)) {
      return colour;
    }
  }

  // If all palette colours are used (unlikely), pick the one with maximum
  // minimum Euclidean distance (in RGB) to the used colours.
  int bestColour = palette.first;
  double bestMinDist = -1;
  for (final colour in palette) {
    double minDist = double.infinity;
    for (final used in usedColours) {
      final d = _colourDistance(colour, used);
      if (d < minDist) minDist = d;
    }
    if (minDist > bestMinDist) {
      bestMinDist = minDist;
      bestColour = colour;
    }
  }
  return bestColour;
}

/// Convert HSL (h in 0..1, s/l in 0..1) to 24‑bit RGB int (0xRRGGBB).
int _hslToRgbInt(double h, double s, double l) {
  double r, g, b;

  if (s == 0) {
    // Achromatic (grey) — shouldn't happen here since s is always 1.0,
    // but handled for completeness.
    r = g = b = l;
  } else {
    double hueToRgb(double p, double q, double t) {
      var tt = t;
      if (tt < 0) tt += 1;
      if (tt > 1) tt -= 1;
      if (tt < 1 / 6) return p + (q - p) * 6 * tt;
      if (tt < 1 / 2) return q;
      if (tt < 2 / 3) return p + (q - p) * (2 / 3 - tt) * 6;
      return p;
    }

    final q = l < 0.5 ? l * (1 + s) : l + s - l * s;
    final p = 2 * l - q;

    r = hueToRgb(p, q, h + 1 / 3);
    g = hueToRgb(p, q, h);
    b = hueToRgb(p, q, h - 1 / 3);
  }

  final ri = (r * 255).round().clamp(0, 255);
  final gi = (g * 255).round().clamp(0, 255);
  final bi = (b * 255).round().clamp(0, 255);

  return (ri << 16) | (gi << 8) | bi;
}

/// Euclidean distance between two 24‑bit colours.
double _colourDistance(int c1, int c2) {
  final r1 = (c1 >> 16) & 0xFF, g1 = (c1 >> 8) & 0xFF, b1 = c1 & 0xFF;
  final r2 = (c2 >> 16) & 0xFF, g2 = (c2 >> 8) & 0xFF, b2 = c2 & 0xFF;
  return sqrt(pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2));
}