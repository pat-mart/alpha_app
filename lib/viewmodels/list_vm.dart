abstract class ListViewModel<Model> {

  late List<Model> _list;

  List<Model> get modelList => _list;

  void addToList(Model model);

  void removeModelAt(int index);

  void debugClearList();

}
