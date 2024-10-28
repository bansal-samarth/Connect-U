import 'package:chat/firebase_options.dart';
import 'package:chat/services/alert_service.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/database_service.dart';
import 'package:chat/services/media_service.dart';
import 'package:chat/services/navigation_service.dart';
import 'package:chat/services/storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

Future<void> setupFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> registerServices() async {
  final GetIt getit = GetIt.instance;
  getit.registerSingleton<AuthService>(
    AuthService(),
  );
  getit.registerSingleton<NavigationService>(
    NavigationService(),
  );
  getit.registerSingleton<AlertService>(
    AlertService(),
  );
  getit.registerSingleton<MediaService>(
    MediaService(),
  );
  getit.registerSingleton<StorageService>(
    StorageService(),
  );
  getit.registerSingleton<DatabaseService>(
    DatabaseService(),
  );
}

String generateChatId({required String uid1, required String uid2}) {
  List uids = [uid1, uid2];
  uids.sort();
  String chatID = uids.fold("", (id, uid) => "$id$uid");
  return chatID;
}
