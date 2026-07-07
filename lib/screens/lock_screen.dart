import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/launcher_settings.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlock;
  final WallpaperOption wallpaper;
  final String? customWallpaperPath;

  const LockScreen({
    super.key,
    required this.onUnlock,
    required this.wallpaper,
    this.customWallpaperPath,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with SingleTickerProviderStateMixin {
  late Timer _timer;
  DateTime _now = DateTime.now();
  String _digits = '';
  bool _entering = false;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  static const _pin = '1234';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(_shakeCtrl);
  }

  @override
  void dispose() {
    _timer.cancel();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onDigit(String d) {
    HapticFeedback.lightImpact();
    setState(() {
      _digits += d;
      if (_digits.length >= 4) {
        if (_digits == _pin) {
          widget.onUnlock();
        } else {
          _shakeCtrl.forward(from: 0);
          _digits = '';
        }
      }
    });
  }

  void _onDelete() {
    if (_digits.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  void _onSwipeUp() => setState(() => _entering = true);

  String get _timeStr => DateFormat('HH:mm').format(_now);
  String get _dateStr => DateFormat('EEEE, MMMM d').format(_now);

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).padding;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onVerticalDragEnd: (d) {
        if (d.primaryVelocity != null && d.primaryVelocity! < -200) {
          _onSwipeUp();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          if (widget.customWallpaperPath != null)
            Image.file(
              File(widget.customWallpaperPath!),
              fit: BoxFit.cover,
            )
          else
            Container(color: Color(widget.wallpaper.primaryHex)),

          // Dark overlay for legibility
          Container(color: Colors.black.withOpacity(0.35)),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Clock
                Text(
                  _timeStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 72,
                    fontWeight: FontWeight.w100,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _dateStr.toLowerCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),

                // Unlock indicator / PIN entry
                if (!_entering) ...[
                  Column(
                    children: [
                      Icon(Icons.keyboard_arrow_up,
                          color: Colors.white.withOpacity(0.7), size: 28),
                      const SizedBox(height: 4),
                      Text(
                        'swipe up to unlock',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  AnimatedBuilder(
                    animation: _shakeAnim,
                    builder: (ctx, child) => Transform.translate(
                      offset: Offset(_shakeAnim.value, 0),
                      child: child,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(4, (i) {
                        final filled = i < _digits.length;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: filled ? Colors.white : Colors.transparent,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _Keypad(onDigit: _onDigit, onDelete: _onDelete),
                ],
                SizedBox(height: 40 + insets.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  const _Keypad({required this.onDigit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      children: rows.map((row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: row.map((key) {
            return SizedBox(
              width: 88,
              height: 72,
              child: key.isEmpty
                  ? const SizedBox.shrink()
                  : TextButton(
                      onPressed: () => key == '⌫' ? onDelete() : onDigit(key),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                      ),
                      child: Text(
                        key,
                        style: const TextStyle(
                          fontSize: key == '⌫' ? 22 : 26,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
