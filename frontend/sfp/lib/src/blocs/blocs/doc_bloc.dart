import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfp/src/blocs/state/state.dart';

import '../blocs.dart';

class DocBloc extends Bloc<DocEvent, DocState> {
  DocBloc() : super(DocInit());
  int currentPage = 1, totalPages = 0;
  @override
  Stream<DocState> mapEventToState(DocEvent event) async* {
    if (event is PageChanged) {
      currentPage = event.page;
      yield ChangePage(page: event.page);
    }
    if (event is GetTotalPages) {
      totalPages = event.pages;
      yield TotalPages(total: event.pages);
    }
    if (event is ResetDoc) {
      currentPage = 1;
      totalPages = 0;
      yield DocInit();
    }
  }

  @override
  void onChange(Change<DocState> change) {
    print(change);
    super.onChange(change);
  }

  @override
  void onEvent(DocEvent event) {
    print(event);
    super.onEvent(event);
  }

  @override
  void onTransition(Transition<DocEvent, DocState> transition) {
    print(transition);
    super.onTransition(transition);
  }
}
