import 'package:flutter/material.dart';

class LinesExample extends StatelessWidget {
  const LinesExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: const [
            IgnorePointer(
              child: Boxes(),
            ),
            Lines(),
          ],
        ),
      ),
    );
  }
}

class Boxes extends StatelessWidget {
  const Boxes({Key? key}) : super(key: key);

  @override
  build(_) => GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 25,
        crossAxisSpacing: 25,
        padding: const EdgeInsets.all(25),
        children: <Widget>[
          for (int i = 0; i < 6; i++)
            Container(
              color: Colors.grey[800],
              foregroundDecoration: BoxDecoration(
                  border: Border.all(
                color: Colors.grey[900]!,
                width: 2,
              )),
              child: const Center(
                child: Text('MyBox'),
              ),
            )
        ],
      );
}

class Lines extends StatefulWidget {
  const Lines({Key? key}) : super(key: key);

  @override
  createState() => _LinesState();
}

class _LinesState extends State<Lines> {
  Offset? start;
  Offset? end;

  @override
  build(_) => GestureDetector(
        onTap: () => print('t'),
        onPanStart: (details) {
          print(details.localPosition);
          setState(() {
            start = details.localPosition;
            end = null;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            end = details.localPosition;
          });
        },
        child: CustomPaint(
          size: Size.infinite,
          painter: LinesPainter(start, end),
        ),
      );
}

class LinesPainter extends CustomPainter {
  final Offset? start;
  final Offset? end;

  LinesPainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    if (start == null || end == null) return;
    canvas.drawLine(
        start ?? const Offset(0, 0),
        end ?? const Offset(0, 0),
        Paint()
          ..strokeWidth = 4
          ..color = Colors.redAccent);
  }

  @override
  bool shouldRepaint(LinesPainter oldDelegate) {
    return oldDelegate.start != start || oldDelegate.end != end;
  }
}
