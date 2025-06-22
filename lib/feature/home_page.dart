import 'dart:math';

import 'package:flutter/material.dart';

class CShapeBoxes extends StatefulWidget {
  const CShapeBoxes({super.key});

  @override
  State<CShapeBoxes> createState() => _CShapeBoxesState();
}

class _CShapeBoxesState extends State<CShapeBoxes>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();

  int n = 0;

  List<Color> boxColors = [];

  List<int> greenOrder = [];

  bool isAnimating = false;

  // Animation controllers for each box
  List<AnimationController> _animationControllers = [];

  List<Animation<Color?>> _colorAnimations = [];

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  void generateBoxes(int count) {
    // Dispose existing controllers
    for (var controller in _animationControllers) {
      controller.dispose();
    }

    setState(() {
      n = count;
      boxColors = List.generate(n, (_) => Colors.red);
      greenOrder.clear();
      isAnimating = false;

      // Create new animation controllers
      _animationControllers = List.generate(
        n,
        (_) => AnimationController(
          duration: Duration(milliseconds: 300),
          vsync: this,
        ),
      );

      // Create color animations for each box
      _colorAnimations = _animationControllers.map((controller) {
        return ColorTween(
          begin: Colors.red,
          end: Colors.green,
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
      }).toList();
    });
  }

  void onBoxTap(int index) {
    if (isAnimating || boxColors[index] == Colors.green) return;

    setState(() {
      boxColors[index] = Colors.green;
      greenOrder.add(index);
    });

    // Animate to green
    _animationControllers[index].forward();

    if (greenOrder.length == n) {
      startReverseAnimation();
    }
  }

  Future<void> startReverseAnimation() async {
    setState(() {
      isAnimating = true;
    });

    for (int i = greenOrder.length - 1; i >= 0; i--) {
      await Future.delayed(Duration(seconds: 1));
      int boxIndex = greenOrder[i];
      _animationControllers[boxIndex].reverse();

      setState(() {
        boxColors[boxIndex] = Colors.red;
      });
    }

    setState(() {
      greenOrder.clear();
      isAnimating = false;
    });
  }

  List<Widget> buildCShapeBoxes() {
    if (n == 0) return [];

    int top = (n / 3).ceil();
    int bottom = top;
    int middle = n - (2 * top);

    List<Widget> widgets = [];

    // Top row
    widgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(top, (i) => buildBox(i, top, middle)),
      ),
    );

    // Middle rows (left side only)
    for (int i = 0; i < middle; i++) {
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [buildBox(top + i, top, middle)],
        ),
      );
    }

    // Bottom row
    widgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(
          bottom,
          (i) => buildBox(top + middle + i, top, middle),
        ),
      ),
    );

    return widgets;
  }

  Widget buildBox(int index, int boxNoAtTop, int boxNoAtMid) {
    double width =
        (MediaQuery.sizeOf(context).width - (boxNoAtTop * 8)) / boxNoAtTop;
    width = min(width, 40);
    if (index >= _colorAnimations.length) {
      return Container(
        margin: EdgeInsets.all(4),
        width: width,
        height: width,
        color: Colors.red,
      );
    }

    return GestureDetector(
      onTap: () => onBoxTap(index),
      child: AnimatedBuilder(
        animation: _colorAnimations[index],
        builder: (context, child) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            margin: EdgeInsets.all(4),
            width: width,

            height: width,
            decoration: BoxDecoration(
              color: _colorAnimations[index].value ?? boxColors[index],
            ),

            child: AnimatedOpacity(
              duration: Duration(milliseconds: 100),
              opacity: isAnimating && boxColors[index] == Colors.red
                  ? 0.7
                  : 1.0,
              child: Container(),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("C-Shape Boxes"),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter N (5-25)',
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(Icons.send, color: Colors.blue.shade600),
                  onPressed: () {
                    final input = int.tryParse(_controller.text);
                    if (input != null && input >= 5 && input <= 25) {
                      generateBoxes(input);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please enter a number between 5 and 25',
                          ),
                          backgroundColor: Colors.red.shade400,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          if (isAnimating)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.orange.shade700,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Reversing animation...',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: buildCShapeBoxes(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
