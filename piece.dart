import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Piece extends StatefulWidget {
   final int posX, posY, size;
   final bool isAnimated;
   final Color color;
   const Piece({   Key? key, required this.color,  required this.size,  required this.posX ,  required this.posY , required this.isAnimated}) :super(key: key);

  @override
  State<Piece> createState() => _PieceState();


}

class _PieceState extends State<Piece> with SingleTickerProviderStateMixin {
   late AnimationController _animationController;
  @override
  initState(){
    super.initState();
    _animationController=AnimationController(
        lowerBound: 0.25,
        upperBound: 1.0,
        duration: const Duration(milliseconds: 1000),
        vsync: this);
    _animationController.addStatusListener((status) {
      if(status==AnimationStatus.completed){
        _animationController.reset();
      }
      else if(status==AnimationStatus.dismissed){
        _animationController.forward();
      }
    });
    _animationController.forward();
  }
  @override
  Widget build(BuildContext context) {
    return Positioned(

        top: widget.posY.toDouble(),
        left: widget.posX.toDouble(),
        child: Opacity(
          opacity: widget.isAnimated?_animationController.value:1,
          child: Container(
            width: widget.size.toDouble(),
            height: widget.size.toDouble(),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              border: Border.all(width: 2.0,color: Colors.white),
            ),
          ),

    ));
  }
}
