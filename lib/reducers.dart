// reducers.dart
import 'package:redux/redux.dart';
import 'actions.dart';

List<Listing> itemsReducer(List<Listing> state, dynamic action) {
  if (action is SetItemsAction) {
    return action.items;
  } else if (action is AddItemAction) {
    return List.from(state)..add(action.newItem);
  } else if (action is EditItemAction) {
    return List.from(state)..[action.index] = action.updatedItem;
  } else if (action is DeleteItemAction) {
    List<Listing> newState = List.from(state);
    newState.removeAt(action.index);
    return newState;
  }
  return state;
}

final rootReducer = combineReducers<List<Listing>>([
  TypedReducer<List<Listing>, SetItemsAction>(itemsReducer),
  TypedReducer<List<Listing>, AddItemAction>(itemsReducer),
  TypedReducer<List<Listing>, EditItemAction>(itemsReducer),
  TypedReducer<List<Listing>, DeleteItemAction>(itemsReducer),
]);

