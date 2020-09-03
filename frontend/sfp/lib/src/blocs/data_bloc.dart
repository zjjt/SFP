import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfp/blocs/events/data_events.dart';

import 'blocs.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  DataBloc(DataState initialState) : super(initialState);

  @override
  Stream<DataState> mapEventToState(DataEvent event) {
    // TODO: implement mapEventToState
    throw UnimplementedError();
  }
  //final
}
