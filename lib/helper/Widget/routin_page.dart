import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class RoutinePage extends StatefulWidget {
  @override
  _RoutinePageState createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  double progress = 0;
  currentProgressColor() {
    if (progress >= 0.6 && progress < 0.8) {
      return Colors.orange;
    }
    if(progress >= 0.8){
      return Colors.red;
    }
    else{
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          color: Colors.white,
          alignment: Alignment(0, 0),
          child: CircularPercentIndicator(
            animationDuration: 200,
            animateFromLastPercent: true,
            arcType: ArcType.FULL,
            arcBackgroundColor: Colors.black12,
            backgroundColor: Colors.white,
            progressColor: currentProgressColor(),
            percent: progress,
            animation: true,
            radius: 250.0,
            lineWidth: 12.0,
            circularStrokeCap: CircularStrokeCap.butt,
          ),
        ),
        Container(
          alignment: Alignment(0, 0),
          child: Text(
            "${this.progress * 100}%",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          alignment: Alignment(0.3, 0.5),
          child: RaisedButton(
              color: Colors.green,
              onPressed: () {
                final updated = ((this.progress + 0.1).clamp(0.0, 1.0) * 100);
                setState(() {
                  this.progress = updated.round() / 100;
                });
                print(progress);
              },
              child: Text(
                '+10%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )),
        ),
        Container(
          alignment: Alignment(-0.3, 0.5),
          child: RaisedButton(
              color: Colors.red,
              onPressed: () {
                final updated = ((this.progress - 0.1).clamp(0.0, 1.0) * 100);
                setState(() {
                  this.progress = updated.round() / 100;
                });
                print(progress);
              },
              child: Text(
                '-10%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )),
        ),
      ],
    );
  }
}