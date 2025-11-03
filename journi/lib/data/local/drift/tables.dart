part of 'app_database.dart';

@DataClassName('TripRow')
class Trips extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get coverImage => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('EntryRow')
class Entries extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text().references(Trips, #id, onDelete: KeyAction.cascade)();

  // enum como TEXT con converter
  TextColumn get type => text().map(const EntryTypeConverter())();

  TextColumn get textContent => text().nullable()();
  TextColumn get mediaUri => text().nullable()();
  RealColumn get lat => real().nullable()();
  RealColumn get lon => real().nullable()();
  TextColumn get tagsJson => text().map(const StringListConverter())();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
