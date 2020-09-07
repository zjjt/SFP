import 'package:equatable/equatable.dart';

enum AnimationEntranceStatus { unknown, done, start, reverse }

class AnimateEntranceState extends Equatable {
  final AnimationEntranceStatus status;
  const AnimateEntranceState._({this.status = AnimationEntranceStatus.unknown});
  const AnimateEntranceState.unknown() : this._();
  const AnimateEntranceState.starting()
      : this._(status: AnimationEntranceStatus.start);
  const AnimateEntranceState.reversing()
      : this._(status: AnimationEntranceStatus.reverse);
  const AnimateEntranceState.stopping()
      : this._(status: AnimationEntranceStatus.done);
  @override
  List<Object> get props => [status];
}
