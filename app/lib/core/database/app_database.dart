/// Drift + SQLite se conecta en la semana 1 (D2–D3). Este contrato evita
/// que los features hablen SQL directo.
abstract interface class AppDatabase {
  Future<void> open();
  Future<void> close();
}

class UnimplementedAppDatabase implements AppDatabase {
  const UnimplementedAppDatabase();

  @override
  Future<void> open() async {}

  @override
  Future<void> close() async {}
}
