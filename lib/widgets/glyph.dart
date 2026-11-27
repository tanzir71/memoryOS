import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../app/tokens.dart';

enum GlyphKind {
  call,
  message,
  email,
  meeting,
  order,
  payment,
  place,
  trip,
  voice,
  note,
  person,
}

class Glyph extends StatelessWidget {
  const Glyph({
    super.key,
    required this.kind,
    this.size = 36,
    this.iconSize = 18,
  });

  final GlyphKind kind;
  final double size;
  final double iconSize;

  IconData get _icon => switch (kind) {
    GlyphKind.call => LucideIcons.phone,
    GlyphKind.message => LucideIcons.messageSquare,
    GlyphKind.email => LucideIcons.mail,
    GlyphKind.meeting => LucideIcons.calendar,
    GlyphKind.order => LucideIcons.package,
    GlyphKind.payment => LucideIcons.creditCard,
    GlyphKind.place => LucideIcons.mapPin,
    GlyphKind.trip => LucideIcons.navigation,
    GlyphKind.voice => LucideIcons.mic,
    GlyphKind.note => LucideIcons.fileText,
    GlyphKind.person => LucideIcons.user,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.sunken,
        borderRadius: BorderRadius.circular(AppRadius.glyph),
      ),
      alignment: Alignment.center,
      child: Icon(_icon, size: iconSize, color: AppColors.ink),
    );
  }
}
