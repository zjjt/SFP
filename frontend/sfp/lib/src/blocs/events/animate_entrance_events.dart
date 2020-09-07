import 'package:equatable/equatable.dart';

abstract class AnimateEntranceEvent extends Equatable {
  const AnimateEntranceEvent();
  @override
  List<Object> get props => [];
}

class LeavingPage extends AnimateEntranceEvent {}

class SignalEndAnimation extends AnimateEntranceEvent {}

class EnteringPage extends AnimateEntranceEvent {}
