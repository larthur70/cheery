import 'package:cheery/features/clients/domain/client.dart';

/// Contract for client persistence.
abstract class ClientsRepository {
  Future<List<Client>> listClients({String? query});

  Future<Client> createClient({
    required String name,
    required String phone,
    required DateTime birthDate,
    required String templateId,
    bool automaticEnabled = false,
  });

  /// Inserts multiple clients in a single transactional batch.
  Future<List<Client>> createClientsBatch(
    List<
        ({
          String name,
          String phone,
          DateTime birthDate,
          String templateId,
          bool automaticEnabled,
        })> rows,
  );

  Future<Client> updateClient({
    required String id,
    required String name,
    required String phone,
    required DateTime birthDate,
    required String templateId,
    bool automaticEnabled = false,
  });

  /// Marks (or clears) the birthday WhatsApp as sent for the current year.
  Future<Client> setBirthdayMessageSent({
    required String id,
    required bool sent,
  });

  Future<void> deleteClient(String id);

  Future<void> deleteClients(List<String> ids);
}
