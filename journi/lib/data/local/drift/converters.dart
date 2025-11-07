part of 'app_database.dart';

class EntryTypeConverter extends TypeConverter<EntryType, String> {
  const EntryTypeConverter();
  @override
  EntryType fromSql(String fromDb) =>
      EntryType.values.firstWhere((e) => e.name == fromDb);
  @override
  String toSql(EntryType value) => value.name;
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();
  @override
  List<String> fromSql(String fromDb) =>
      (JsonDecoder().convert(fromDb) as List).map((e) => e.toString()).toList();

  @override
  String toSql(List<String> value) => const JsonEncoder().convert(value);
}
