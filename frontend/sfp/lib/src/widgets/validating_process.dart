import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:sfp/src/blocs/blocs.dart';
import 'package:sfp/string_extensions.dart';
import 'package:sfp/utils.dart';

import '../../assets.dart';

class ValidatingProcess extends StatefulWidget {
  final String whichProcess;

  const ValidatingProcess({Key key, this.whichProcess}) : super(key: key);
  @override
  _ValidatingProcessState createState() => _ValidatingProcessState();
}

class _ValidatingProcessState extends State<ValidatingProcess>
    with TickerProviderStateMixin {
  IconData _handleIcon;
  Color _loadingColor;
  DataBloc dataBloc;
  @override
  void initState() {
    super.initState();
    dataBloc = context.bloc<DataBloc>();
    _handleIcon = Icons.done;
    _loadingColor = Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    Size appB = Size(MediaQuery.of(context).size.width, 80.0);
    double progress = widget.whichProcess == "CONTROLLER"
        ? dataBloc.validationControlProgress
        : widget.whichProcess == "VALIDATOR"
            ? dataBloc.validationProgress
            : 0;
    var validatorMap = widget.whichProcess == "VALIDATOR"
        ? dataBloc.currentValidation.validators
        : widget.whichProcess == "CONTROLLER"
            ? dataBloc.currentControlValidation.validators
            : {};
    var validatorMotivesMap = widget.whichProcess == "VALIDATOR"
        ? dataBloc.currentValidation.validatorMotives
        : widget.whichProcess == "CONTROLLER"
            ? dataBloc.currentControlValidation.validatorMotives
            : {};
    Utils.log("validator map\n $validatorMap");
    return Container(
      width: appB.width * 0.5,
      margin:
          EdgeInsets.only(top: widget.whichProcess == "VALIDATOR" ? 20.0 : 0.0),
      height: 260.0,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          Text(
              "${widget.whichProcess.capitalize1stLetter()}'s Compliance Validations status",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 30.0,
              )),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: widget.whichProcess == "VALIDATOR"
                  ? dataBloc.currentValidation.validators.keys.length
                  : widget.whichProcess == "CONTROLLER"
                      ? dataBloc.currentControlValidation.validators.keys.length
                      : 0,
              itemBuilder: (BuildContext context, int index) => Container(
                width: 100.0,
                height: 150.0,
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    IconButton(
                      iconSize: 50,
                      icon: Icon(validatorMap[
                                  validatorMap.keys.toList()[index]] ==
                              "REJECTED"
                          ? Icons.highlight_off
                          : validatorMap[validatorMap.keys.toList()[index]] ==
                                  "OK"
                              ? Icons.done
                              : Icons.hourglass_empty_outlined),
                      onPressed: () {},
                      tooltip:
                          "${validatorMap[validatorMap.keys.toList()[index]]}\n\n${validatorMotivesMap != null ? validatorMotivesMap[validatorMap.keys.toList()[index]] : ""}",
                    ),
                    SizedBox(height: 5.0),
                    Text(
                        widget.whichProcess == "VALIDATOR"
                            ? dataBloc.validatorsName.values.toList()[index]
                            : widget.whichProcess == "CONTROLLER"
                                ? dataBloc.controllersName.values
                                    .toList()[index]
                                : "",
                        style: const TextStyle(fontSize: 10.0)),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          FlutterSlider(
            disabled: true,
            min: 0,
            max: 100.0,
            values: [progress],
            trackBar: FlutterSliderTrackBar(
              activeDisabledTrackBarColor:
                  progress < 100 ? _loadingColor : Assets.ubaRedColor,
            ),
            handler: FlutterSliderHandler(
              child: Material(
                type: MaterialType.circle,
                color: Colors.grey[100],
                elevation: 3.0,
                child: Container(
                    padding: EdgeInsets.all(5),
                    child: Icon(_handleIcon, color: _loadingColor, size: 15.0)),
              ),
            ),
            handlerAnimation: FlutterSliderHandlerAnimation(
              curve: Curves.elasticOut,
              reverseCurve: Curves.bounceIn,
              duration: Duration(milliseconds: 500),
              scale: 1.5,
            ),
            tooltip: FlutterSliderTooltip(
              textStyle: const TextStyle(
                fontSize: 17,
                color: Colors.white,
              ),
              boxStyle: FlutterSliderTooltipBox(
                decoration: BoxDecoration(color: Colors.black),
              ),
            ),
            hatchMark: FlutterSliderHatchMark(
                density: 0.5,
                linesDistanceFromTrackBar: 10.0,
                displayLines: false,
                labelsDistanceFromTrackBar: 50.0,
                labels: [
                  FlutterSliderHatchMarkLabel(percent: 0, label: Text('0%')),
                  FlutterSliderHatchMarkLabel(percent: 25, label: Text('25%')),
                  FlutterSliderHatchMarkLabel(percent: 50, label: Text('50%')),
                  FlutterSliderHatchMarkLabel(percent: 75, label: Text('75%')),
                  FlutterSliderHatchMarkLabel(percent: 100, label: Text('Ok'))
                ]),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
