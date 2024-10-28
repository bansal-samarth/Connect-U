import 'package:chat/models/chat.dart';
import 'package:chat/models/message.dart';
import 'package:chat/models/user_profile.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

class DatabaseService {
  final GetIt _getIt = GetIt.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  late AuthService _authService;

  CollectionReference? _userCollection;
  CollectionReference? _chatCollection;

  DatabaseService() {
    _setupCollectionReference();
    _authService = _getIt.get<AuthService>();
  }

  void _setupCollectionReference() {
    _userCollection =
        _firebaseFirestore.collection('users').withConverter<UserProfile>(
              fromFirestore: (snapshots, _) => UserProfile.fromJson(
                snapshots.data()!,
              ),
              toFirestore: (userProfile, _) => userProfile.toJson(),
            );
    _chatCollection = _firebaseFirestore
        .collection("chats")
        .withConverter<Chat>(
            fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
            toFirestore: (chat, _) => chat.toJson());
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    await _userCollection?.doc(userProfile.uid).set(userProfile);
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
    return _userCollection
        ?.where("uid", isNotEqualTo: _authService.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  Future<bool> checkChatExist(String uid1, String uid2) async {
    String chatID = generateChatId(uid1: uid1, uid2: uid2);
    final result = await _chatCollection?.doc(chatID).get();
    if (result != null) return result.exists;
    return false;
  }

  Future<void> createNewChat(String uid1, String uid2) async {
    String chatID = generateChatId(uid1: uid1, uid2: uid2);
    final docRef = _chatCollection?.doc(chatID);
    final chat = Chat(
      id: chatID,
      participants: [uid1, uid2],
      messages: [],
    );
    await docRef?.set(chat);
  }

  Future<void> sendChatMessage(
      String uid1, String uid2, Message message) async {
    String chatID = generateChatId(uid1: uid1, uid2: uid2);
    final docRef = _chatCollection!.doc(chatID);
    await docRef.update(
      {
        "messages": FieldValue.arrayUnion([message.toJson()]),
      },
    );
  }

  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2) {
    String chatID = generateChatId(uid1: uid1, uid2: uid2);
    return _chatCollection?.doc(chatID).snapshots()
        as Stream<DocumentSnapshot<Chat>>;
  }
}
