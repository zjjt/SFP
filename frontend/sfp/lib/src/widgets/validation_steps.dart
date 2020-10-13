import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:sfp/assets.dart';

class ValidationSteps extends StatefulWidget {
  ValidationSteps({Key key}) : super(key: key);

  @override
  _ValidationStepsState createState() => _ValidationStepsState();
}

class _ValidationStepsState extends State<ValidationSteps> {
  int _validatorNumber;
  List<TextEditingController> _validatorsCtrl = List<TextEditingController>();
  final _formKey = GlobalKey<FormState>();
  final _validatorlistKey = GlobalKey<AnimatedListState>();
  ListModel<int> _list;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _validatorNumber = 1;
    _validatorsCtrl.add(TextEditingController());
    _list = ListModel(
        listKey: _validatorlistKey,
        initialItems: <int>[_validatorNumber],
        removedItemBuilder: _buildRemovedItem);
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return _ValidatorField(
        animation: animation,
        item: _list[index],
        textEditingController: _validatorsCtrl[index]);
  }

  Widget _buildRemovedItem(
      int index, BuildContext context, Animation<double> animation) {
    return _ValidatorField(
        animation: animation,
        item: _list[index],
        textEditingController: _validatorsCtrl[index]);
  }

  void _insert() {
    final int index = _list.length;
    print("lenght of email list is $index");
    _list.insert(index - 1, index);
  }

  void _remove() {
    _list.removeAt(_list.indexOf(_list.length));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500.0,
      height: 300,
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
                  tooltip: "Insert another member to the validation chain",
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: Assets.ubaRedColor),
                  onPressed: _remove,
                  tooltip: "Insert another member to the validation chain",
                ),
              ],
            ),
          ),
          Container(
            height: _list.length * 80.0,
            child: Form(
              key: _formKey,
              child: AnimatedList(
                  key: _validatorlistKey,
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
              ],
            ),
          )
        ],
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
