// ignore_for_file: prefer_conditional_assignment

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:snake/control_panel.dart';
import 'package:snake/piece.dart';
import 'package:snake/direction.dart';
import 'dart:math';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int upperBoundX = 0,
      upperBoundY = 0,
      lowerBoundX = 0,
      lowerBoundY = 0;
  double screenWidth = 0,
      screenHeight = 0;
  int step = 30;
  int length = 5;

  Offset ?foodPosition;
  late Piece food;


  int score = 0;
  double speed = 1.0;
  Timer ?timer;

  List<Offset> positions = [];
  Direction direction = Direction.right;


  void changeSpeed() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
    timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() {

      });
    });
  }

  Widget getControls() {
    return ControlPanel(onTapped: (Direction newDirection) {
      direction = newDirection;
    },
    );
  }

  Direction getRandomDirection() {
    int val = Random().nextInt(4);
    direction = Direction.values[val];
    return direction;
  }

  void restart() {
    length = 5;
    score = 0;
    speed = 1;
    positions = [];
    direction = getRandomDirection();
    changeSpeed();
  }

  @override
  initState() {
    super.initState();
    restart();
  }

  int getNearestTens(int num) {
    int output;
    output = (num ~/ step) * step;
    if (output == 0) {
      output += step;
    }
    return output;
  }

  Offset getRandomPosition() {
    Offset position;
    int posX = Random().nextInt(upperBoundY) + lowerBoundY;
    int posY = Random().nextInt(upperBoundY) + lowerBoundY;
    position = Offset(
        getNearestTens(posX).toDouble(), getNearestTens(posY).toDouble());
    return position;
  }

  void draw() async {
    if (positions == null) {
      positions.add(getRandomPosition());
    }
    while (length > positions.length) {
      positions.add(positions[positions.length - 1]);
    }
    for (var i = positions.length - 1; i > 0; i--) {
      positions[i] = positions[i - 1];
    }
    positions[0] = (await getNextPosition(positions[0]))!;
  }

  bool detectCollision(Offset position) {
    if (position.dx >= upperBoundX && direction == Direction.right) {
      return true;
    }
    else if (position.dx <= lowerBoundX && direction == Direction.left) {
      return true;
    }
    else if (position.dy >= upperBoundY && direction == Direction.down) {
      return true;
    }
    else if (position.dy >= upperBoundY && direction == Direction.up) {
      return true;
    }
    return false;
  }

  void showGameOverDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: Colors.red,
            shape: const RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.blue,
                  width: 3.0,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10.0))
            ),
            title: const Text(
              "Game over",
              style: TextStyle(color: Colors.white),


            ),
            content: Text(
              "Your game is over but played well. your score is"+score.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  restart();
                },
                child: const Text(
                  "Restart",
                  style: TextStyle(fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        }
    );
  }


  //Future<Offset> getNextPosition(Offset position) async{
  // Offset nextPosition;
  // if (direction==Direction.right){
  // nextPosition = Offset(position.dx+step, position.dy);

  //}
  //else if (direction==Direction.left){
  //nextPosition= Offset(position.dx-step, position.dy);
  //}
  //else if(direction==Direction.up){
  //nextPosition= Offset(position.dx, position.dy-step);
  //}[
  //else if(direction==Direction.down){
  //nextPosition= Offset(position.dx, position.dy+step);
  //}

  //return nextPosition;
  //}
  Future<Offset?> getNextPosition(Offset position) async {
    Offset?nextPosition;


    if (direction == Direction.right) {
      nextPosition = Offset(position.dx + step, position.dy);
    } else if (direction == Direction.left) {
      nextPosition = Offset(position.dx - step, position.dy);
    } else if (direction == Direction.up) {
      nextPosition = Offset(position.dx, position.dy - step);
    } else if (direction == Direction.down) {
      nextPosition = Offset(position.dx, position.dy + step);
    }
    if (detectCollision(position) == true) {
      if (timer != null && timer!.isActive) {
        timer?.cancel();
      }
      await Future.delayed(
          const Duration(milliseconds: 200), () => showGameOverDialog());
      return position;
    }
    return nextPosition;
  }

  void drawFood() {
    if (foodPosition == null) {
      foodPosition = getRandomPosition();
    }
    if (foodPosition == positions[0]) {
      length++;
      score = score + 5;
      speed = speed + 0.25;
      foodPosition = getRandomPosition();
    }


    food = Piece(
      posX: foodPosition!.dx.toInt(),
      posY: foodPosition!.dy.toInt(),
      size: step,
      color: Colors.red,
      isAnimated: true,
    );
  }


  List<Piece> getPieces() {
    final pieces = <Piece>[];
    draw();
    drawFood();
    for (var i = 0; i < length; i++) {
      if (i >= positions.length) {
        continue;
      }
      pieces.add(Piece(
        posY: positions[i].dx.toInt(),
        posX: positions[i].dy.toInt(),
        size: step,
        color: i.isEven ? Colors.red : Colors.green,
        isAnimated: false,
      ));
    }
    return pieces;
  }

  Widget getScore() {
    return Positioned(
        top: 80.0,
        right: 50.0,
        child: Text(
          "Score :"+score.toString(),
          style: const TextStyle(fontSize: 30, color: Colors.white),
        ));
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    lowerBoundX = step;
    lowerBoundY = step;
    upperBoundX = getNearestTens(screenHeight.toInt() - step);
    upperBoundY = getNearestTens(screenWidth.toInt() - step);


    return Scaffold(
      body: Container(
          color: Colors.amber,
          child: Stack(
            children: [
              Stack(
                children: getPieces(),
              ),
              getControls(),
              food,
              getScore(),
            ],
          )
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Timer>('timer', timer));
    properties.add(DiagnosticsProperty<Timer>('timer', timer));
    properties.add(DiagnosticsProperty<Piece>('food', food));
    properties.add(DiagnosticsProperty<Offset>('foodPosition', foodPosition));
  }
}