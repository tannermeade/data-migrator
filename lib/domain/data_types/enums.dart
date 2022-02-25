enum SchemaIndexType {
  key,
  unique,
  fullText,
}

enum SchemaOrder {
  asc,
  desc,
}

enum PermissionLevel {
  data,
  schema,
}

enum IntType {
  int,
  tinyInt,
  smallInt,
  mediumInt,
  bigInt,
}

enum FloatType {
  float,
  decimal,
  double,
}

enum StringType {
  char,
  varChar,
  text,
  tinyText,
  mediumText,
  longText,
  url,
  email,
  ip,
}

enum DateType {
  date,
  datetime,
  timestamp,
  time,
  year,
}

enum FieldStatus {
  available,
  failed,
  processing,
  none,
}
