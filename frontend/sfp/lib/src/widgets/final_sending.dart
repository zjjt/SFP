import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sfp/assets.dart';
import 'package:sfp/src/blocs/blocs.dart';
import 'package:sfp/src/widgets/validation_steps.dart';
import 'package:sfp/utils.dart';

class FinalSending extends StatefulWidget {
  FinalSending({Key key}) : super(key: key);

  @override
  _FinalSendingState createState() => _FinalSendingState();
}

class _FinalSendingState extends State<FinalSending> {
  int _copieNumber;
  final _formKey = GlobalKey<FormState>();
  final _listKey = GlobalKey<AnimatedListState>();
  ListModel<int> _list;
  List<TextEditingController> _emailCtrl;
  TextEditingController textEditingController;
  DataBloc dataBloc;
  AuthBloc authBloc;
  AlertBloc alertBloc;

  @override
  void initState() {
    super.initState();
    _emailCtrl = List<TextEditingController>();
    _copieNumber = 1;
    _list = ListModel(
        listKey: _listKey,
        initialItems: <int>[_copieNumber],
        removedItemBuilder: _buildRemovedItem);
    textEditingController = TextEditingController();
    dataBloc = context.bloc<DataBloc>();
    authBloc = context.bloc<AuthBloc>();
    alertBloc = context.bloc<AlertBloc>();
  }

  @override
  void dispose() {
    super.dispose();
    _emailCtrl.forEach((element) {
      element.dispose();
    });
    textEditingController.dispose();
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    if (_emailCtrl.length > _list.length) {
      //due to a bug we have to match
      Utils.log(
          "emailCtrllength:${_emailCtrl.length}\nelementList:${_list.length}\nremoving last ${_emailCtrl.length - _list.length}\nrange:(${(_emailCtrl.length - 1) - (_emailCtrl.length - _list.length)},${_emailCtrl.length})");
      _emailCtrl.removeRange(
          (_emailCtrl.length - 1) - (_emailCtrl.length - _list.length),
          _emailCtrl.length);
    }
    _emailCtrl.add(TextEditingController());
    Utils.log(
        "adding 1 textController from _buildItem emailCtrllength: ${_emailCtrl.length} elementList length: ${_list.length}");
    return ValidatorField(
        animation: animation,
        label: "Email",
        item: _list[index],
        textEditingController: _emailCtrl[index]);
  }

  Widget _buildRemovedItem(
      int index, BuildContext context, Animation<double> animation) {
    _emailCtrl.removeLast();

    if (_emailCtrl.isEmpty) {
      _emailCtrl.add(TextEditingController());
    }
    Utils.log(
        "removing 1 textController from _buildRemovedItem length: ${_emailCtrl.length}");

    return ValidatorField(
        animation: animation,
        label: "Email",
        item: _list.length,
        textEditingController: _emailCtrl.last);
  }

  void _insert() {
    final int index = _list.length;
    _list.insert(index, index + 1);
  }

  void _remove() {
    _emailCtrl.removeLast();
    if (_emailCtrl.isEmpty) {
      _emailCtrl.add(TextEditingController());
    }
    _list.removeAt(_list.indexOf(_list.length));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DataBloc, DataState>(
      listener: (context, state) {
        if (state is FinalMailProcedureStarted) {
          Utils.log(
              "number of people en copie added is ${_emailCtrl.length}\nthey are:\n");
          var listOfMail = List<String>();
          _emailCtrl.forEach((element) {
            Utils.log(element.text);
            if (element.text.isNotEmpty) {
              listOfMail.add(element.text);
            }
          });
          var processingIds = List<String>();
          dataBloc.processedFiles.forEach((element) {
            processingIds.add(element.processingId);
          });

          if (_formKey.currentState.validate()) {
            alertBloc.add(ShowAlert(
              whatToShow: Container(
                height: 200,
                width: 200,
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: SpinKitRing(color: Assets.ubaRedColor, size: 80.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      "Please wait...",
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
              isDoc: false,
              title: Container(),
              actions: [],
            ));
            dataBloc.add(SendFinalMail(
                dataBloc.currentConfig.configName,
                authBloc.user.username,
                authBloc.user.id,
                textEditingController.text,
                listOfMail,
                processingIds));
          } else {
            dataBloc.add(PutFormInStandBy());
          }
        } else if (state is FinalMailSent) {
          Navigator.of(context).pop();
          alertBloc.add(CloseAlert());
          Timer(Duration(milliseconds: 200), () {
            alertBloc.add(ShowAlert(
                whatToShow: Container(
                  height: 200,
                  width: 350,
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child: Icon(Icons.done,
                              color: Assets.ubaRedColor, size: 70.0)),
                      SizedBox(height: 10.0),
                      Text(
                        "The final email has been sent to ${textEditingController.text}\n\n You will now be logged out and the processing pipeline for this particular file will be removed.\n\n Thank you for using this software.",
                        textAlign: TextAlign.justify,
                      )
                    ],
                  ),
                ),
                isDoc: false,
                title: Container(),
                actions: [
                  FlatButton(
                      onPressed: () {
                        alertBloc.add(CloseAlert());
                        authBloc.add(LogOut());
                        //here the validation box must show on the result page
                      },
                      child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("OK",
                              style: const TextStyle(color: Colors.black)))),
                ]));
          });
        } else if (state is FinalMailNotSent) {
          alertBloc.add(CloseAlert());
          alertBloc.add(CloseAlert());
          alertBloc.add(ShowAlert(
              whatToShow: Container(
                height: 200,
                width: 200,
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                        child: Icon(Icons.done,
                            color: Assets.ubaRedColor, size: 70.0)),
                    SizedBox(height: 10.0),
                    Text(
                      "The final email couldn't be delivered to ${textEditingController.text}.\n Please try again later or contact IT SUPPORT for further help",
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
              isDoc: false,
              title: Container(),
              actions: [
                FlatButton(
                    onPressed: () {
                      alertBloc.add(CloseAlert());
                      //here the validation box must show on the result page
                    },
                    child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("OK",
                            style: const TextStyle(color: Colors.black)))),
              ]));
        }
      },
      child: Container(
        width: 600.0,
        height: 700,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                validator: (mail) {
                  if (!EmailValidator.validate(mail)) {
                    return "Please fill in a proper email id";
                  }
                  return null;
                },
                controller: textEditingController,
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    Icons.person_outline,
                    color: Assets.ubaRedColor,
                  ),
                  labelText: "Main recipient email address",
                  labelStyle: TextStyle(
                    color: Assets.ubaRedColor,
                    fontSize: 15.0,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Assets.ubaRedColor,
                    ),
                  ),
                ),
              ),
              Divider(),
              Text(
                "Add Cc recipients to the mail transfer",
                textAlign: TextAlign.center,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline,
                          color: Assets.ubaRedColor),
                      onPressed: _insert,
                      tooltip: "Insert another member to the cc chain",
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline,
                          color: Assets.ubaRedColor),
                      onPressed: _remove,
                      tooltip: "remove one member from the cc chain",
                    ),
                  ],
                ),
              ),
              Container(
                height: 300,
                child: Column(
                  children: [
                    Expanded(
                      child: AnimatedList(
                          key: _listKey,
                          initialItemCount: _list.length,
                          itemBuilder: _buildItem),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
