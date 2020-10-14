import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfp/assets.dart';
import 'package:sfp/src/blocs/blocs.dart';
import 'package:sfp/src/widgets/file_upload_val_web.dart';
import 'package:sfp/utils.dart';

class ValidationSteps extends StatefulWidget {
  ValidationSteps({Key key}) : super(key: key);

  @override
  _ValidationStepsState createState() => _ValidationStepsState();
}

class _ValidationStepsState extends State<ValidationSteps> {
  int _validatorNumber;
  final _formKey = GlobalKey<FormState>();
  final _listKey = GlobalKey<AnimatedListState>();
  final _filesUploadKey = GlobalKey<FileUploadValidatorWebState>();
  ListModel<int> _list;
  List<TextEditingController> _emailCtrl;
  DataBloc dataBloc;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dataBloc = context.bloc<DataBloc>();
    _emailCtrl = List<TextEditingController>();
    _validatorNumber = 1;
    _list = ListModel(
        listKey: _listKey,
        initialItems: <int>[_validatorNumber],
        removedItemBuilder: _buildRemovedItem);
  }

  void _removeBlankTextCtrl() {
    _emailCtrl.forEach((element) {
      if (element.text.isEmpty) {
        _emailCtrl.remove(element);
      }
    });
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
    return _ValidatorField(
        animation: animation,
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

    return _ValidatorField(
        animation: animation,
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
        if (state is ApprovalChainSubmited) {
          Utils.log(
              "number of validators added is ${_emailCtrl.length}\nthey are:\n");
          _emailCtrl.forEach((element) {
            Utils.log(element.text);
          });
          Utils.log(
              "\n number of attachement files is ${_filesUploadKey.currentState.noFiles}");
          if (_formKey.currentState.validate()) {
          } else {
            dataBloc.add(PutFormInStandBy());
          }
        }
      },
      child: Container(
        width: 600.0,
        height: 700,
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: Assets.ubaRedColor),
                    onPressed: _insert,
                    tooltip: "Insert another member to the approval chain",
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Assets.ubaRedColor),
                    onPressed: _remove,
                    tooltip: "remove one member from the approval chain",
                  ),
                ],
              ),
            ),
            Container(
              height: 300,
              child: Form(
                key: _formKey,
                child: AnimatedList(
                    key: _listKey,
                    initialItemCount: _list.length,
                    itemBuilder: _buildItem),
              ),
            ),
            SizedBox(height: 5.0),
            Divider(),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Join files by clicking the button below"),
                  SizedBox(
                    height: 20.0,
                  ),
                  FileUploadValidatorWeb(key: _filesUploadKey)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ValidatorField extends StatelessWidget {
  final Animation<double> animation;
  final int item;
  final TextEditingController textEditingController;
  const _ValidatorField(
      {@required this.animation,
      @required this.item,
      @required this.textEditingController})
      : assert(animation != null),
        assert(item != null && item >= 0);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizeTransition(
        sizeFactor: animation,
        axis: Axis.vertical,
        child: TextFormField(
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
            labelText: "Validator Email Id $item",
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
      ),
    );
  }
}

class ListModel<E> {
  final GlobalKey<AnimatedListState> listKey;
  final dynamic removedItemBuilder;
  final List<E> _items;
  ListModel(
      {@required this.listKey,
      @required this.removedItemBuilder,
      Iterable<E> initialItems})
      : assert(listKey != null),
        assert(removedItemBuilder != null),
        _items = List<E>.from(initialItems ?? <E>[]);
  AnimatedListState get _animatedList => listKey.currentState;
  int get length => _items.length;
  E operator [](int index) => _items[index];
  int indexOf(E item) => _items.indexOf(item);

  void insert(int index, E item) {
    _items.insert(index, item);
    _animatedList.insertItem(index);
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    if (removedItem != null) {
      _animatedList.removeItem(
          index,
          (context, animation) =>
              removedItemBuilder(removedItem, context, animation));
      return removedItem;
    }
  }
}
