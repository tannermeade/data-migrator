abstract class SchemaSizeInt {
  SchemaSizeInt({this.size});

  int? size;
}

abstract class SchemaSizeRange {
  SchemaSizeRange();

  dynamic get min;
  dynamic get max;

  set minByDynamic(dynamic value);
  set maxByDynamic(dynamic value);
}
