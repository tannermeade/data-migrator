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
  id, // Valid chars are a-z, A-Z, 0-9, and underscore. Can't start with a leading underscore
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

enum SchemaClassification {
  regular,
  appwriteUsers,
}
