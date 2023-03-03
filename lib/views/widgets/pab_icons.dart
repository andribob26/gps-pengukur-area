import 'package:flutter/material.dart';

class FabIcons extends StatefulWidget {
  const FabIcons(
      {Key? key,
      required this.icons,
      required this.onIconTapped,
      required this.onPressed})
      : super(key: key);
  final List<IconData> icons;
  final ValueChanged<int> onIconTapped;
  final ValueChanged<int> onPressed;
  @override
  State createState() => FabIconsState(onPressed: onPressed);
}

class FabIconsState extends State<FabIcons> with TickerProviderStateMixin {
  late AnimationController _controller;
  late ValueChanged<int> onPressed;

  FabIconsState({required this.onPressed});

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.icons.length, (int index) {
        return _buildChild(index, onPressed);
      }).toList()
        ..add(
          _buildFab(),
        ),
    );
  }

  Widget _buildChild(int index, ValueChanged<int> onPressed) {
    return Container(
      height: 70.0,
      width: 56.0,
      alignment: FractionalOffset.topCenter,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _controller,
          curve: Interval(0.0, 1.0 - index / widget.icons.length / 2.0,
              curve: Curves.easeOut),
        ),
        child: FloatingActionButton(
          heroTag: "btn${index}",
          elevation: 2.0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          backgroundColor: Colors.grey.shade800,
          child: Icon(widget.icons[index], color: Colors.white),
          onPressed: () {
            onPressed(index);
          },
        ),
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      backgroundColor: Colors.amber,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      onPressed: () {
        if (_controller.isDismissed) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      elevation: 0.0,
      child: Icon(Icons.menu, color: Colors.grey.shade800),
    );
  }

  void _onTapped(int index) {
    _controller.reverse();
    widget.onIconTapped(index);
  }
}
