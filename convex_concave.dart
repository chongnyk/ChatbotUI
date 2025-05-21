import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Animated Concave/Convex Border with BackdropFilter')),
        body: Stack(
          children: [
            SizedBox.expand(
              child: Image.asset('assets/images/kermit_asshole.jpg', fit: BoxFit.cover),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedConcaveConvexBorder(),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedConcaveConvexBorder extends StatefulWidget {
  @override
  _AnimatedConcaveConvexBorderState createState() => _AnimatedConcaveConvexBorderState();
}

class _AnimatedConcaveConvexBorderState extends State<AnimatedConcaveConvexBorder> with SingleTickerProviderStateMixin {
  bool isFocus = false;
  late AnimationController _controller;
  List<String> messages = [];
  final TextEditingController _controllerText = TextEditingController();
  double totalHeight = 150;
  final double TEXTFIELDHEIGHT = 100.0;
  final double NOTCHATHEIGHT = 80;

  @override
  void initState() {
    super.initState();
    //messages = ['Hello', 'How are you?', 'I am good!', 'Nice to meet you!', 'Let\'s chat!'];
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _updateHeight();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerText.dispose();
    super.dispose();
  }

  void toggleFocus() {
    setState(() {
      isFocus = !isFocus;
      isFocus ? _controller.forward() : _controller.reverse();
    });
  }

  void _sendMessage() {
    setState(() {
      if (_controllerText.text.isNotEmpty) {
        messages.add(_controllerText.text);
        _controllerText.clear();
        _updateHeight();
      }
    });
  }

  void _updateHeight() {
    double calculatedHeight = messages.fold(0, (previous, message) {
      TextPainter textPainter = TextPainter(
        text: TextSpan(text: message, style: TextStyle(fontSize: 16)),
        maxLines: null,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: 300); // Assuming 300px wide
      double height = textPainter.size.height + 16 + 4; // Including padding
      return previous + height;
    });
    setState(() {
      totalHeight = min(max(calculatedHeight, 120), 360);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 500,
                minHeight: 100,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: screenWidth,
                    height: min(TEXTFIELDHEIGHT + NOTCHATHEIGHT + _controller.value * (totalHeight - NOTCHATHEIGHT) + 40, 500),
                  ),
                  Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    child: ClipPath(
                      clipper: ConcaveConvexClipper(_controller.value),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          color: Colors.transparent,
                          width: screenWidth,
                          height: min(TEXTFIELDHEIGHT + NOTCHATHEIGHT + _controller.value * (totalHeight - NOTCHATHEIGHT), 460),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    child: CustomPaint(
                      painter: ConcaveConvexBorderPainter(_controller.value),
                      child: Container(
                        width: screenWidth,
                        height: min(TEXTFIELDHEIGHT + NOTCHATHEIGHT + _controller.value * (totalHeight - NOTCHATHEIGHT), 460),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: screenWidth,
                              height: NOTCHATHEIGHT + _controller.value * (totalHeight - NOTCHATHEIGHT),
                              child: Stack(
                                children: [
                                  SizedBox(
                                    width: screenWidth,
                                    height: NOTCHATHEIGHT + _controller.value * (totalHeight - NOTCHATHEIGHT),
                                  ),
                                  Opacity(
                                    opacity: 1 - _controller.value,
                                    child: Container(
                                      width: screenWidth,
                                      height: NOTCHATHEIGHT + _controller.value * (totalHeight - NOTCHATHEIGHT),
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(Icons.location_on_outlined, size: 24),
                                          Icon(Icons.link_outlined, size: 24),
                                          Icon(Icons.image_outlined, size: 24),
                                          Icon(Icons.notifications_outlined, size: 24),
                                          Icon(Icons.repeat_outlined, size: 24),
                                          Icon(Icons.comment_outlined, size: 24),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Opacity(
                                    opacity: _controller.value,
                                    child: ListView.builder(
                                      itemCount: messages.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return Align(
                                            alignment: index.isEven ? Alignment.centerRight: Alignment.centerLeft,
                                            child: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 8),
                                              padding: EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(width: 1.0),
                                                borderRadius: BorderRadius.circular(8.0),
                                                color: Color(0xFFCBC9C1),
                                              ),
                                              child: Text(
                                                messages[index],
                                                style: TextStyle(color: Colors.black),
                                              ),
                                            )
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _controllerText,
                                      decoration: InputDecoration(hintText: 'Type a message'),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.send),
                                    onPressed: _sendMessage,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: Center(
                        child: GestureDetector(
                          onTap: toggleFocus,
                          onVerticalDragUpdate: (DragUpdateDetails details) {
                            // details.delta.dy is positive when dragging down, negative when dragging up
                            // We invert it so dragging up increases the value.
                            final dragDelta = -details.delta.dy;
                            // Normalize by the total height range you want to cover:
                            // here we pick 1.5 * textfieldHeight as the full drag span
                            final fractionDelta = dragDelta / (1.5 * TEXTFIELDHEIGHT);
                            // Increment controller value, clamped between 0 and 1
                            final newValue = (_controller.value + fractionDelta).clamp(0.0, 1.0);
                            _controller.value = newValue;
                          },
                          onVerticalDragEnd: (_) {
                            // Compute the current panel height
                            final currentHeight = TEXTFIELDHEIGHT + _controller.value * totalHeight;
                            final thresholdHeight = 1.5 * TEXTFIELDHEIGHT;
                            final shouldFocus = currentHeight >= thresholdHeight;

                            setState(() {
                              if (shouldFocus && !isFocus) {
                                isFocus = true;
                                _controller.forward();
                              } else if (!shouldFocus && isFocus) {
                                isFocus = false;
                                _controller.reverse();
                              }
                            });
                          },
                          child: Image.asset('assets/images/capy_stare.png',),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}


class ConcaveConvexClipper extends CustomClipper<Path> {
  final double animationValue;

  ConcaveConvexClipper(this.animationValue);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);

    double controlPointY = 40 + -80 * animationValue;
    double centerStart = size.width / 2 - 120;
    double centerEnd = size.width / 2 + 120;
    double mu = (centerEnd + centerStart) / 2;
    double sigma = 40;

    path.lineTo(centerStart, 0);

    for (double x = centerStart; x <= centerEnd; x += 1) {
      double y = exp(-pow((x - mu) / sigma, 2) / 2) * controlPointY;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class ConcaveConvexBorderPainter extends CustomPainter {
  final double animationValue;

  ConcaveConvexBorderPainter(this.animationValue);

  double gaussian(double x, double mu, double sigma) {
    return exp(-pow((x - mu) / sigma, 2) / 2);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, 0);

    double controlPointY = 40 + -80 * animationValue;
    double centerStart = size.width / 2 - 120;
    double centerEnd = size.width / 2 + 120;
    double mu = (centerEnd + centerStart) / 2;
    double sigma = 40;

    path.lineTo(centerStart, 0);

    for (double x = centerStart; x <= centerEnd; x += 1) {
      double y = gaussian(x, mu, sigma) * controlPointY;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
