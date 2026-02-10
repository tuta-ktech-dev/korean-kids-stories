import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../services/pocketbase_service.dart';

/// User model representing authenticated user
class User {
  final String id;
  final String? name;
  final String? email;
  final bool isVerified;
  final DateTime? created;
  final DateTime? updated;

  User({
    required this.id,
    this.name,
    this.email,
    this.isVerified = false,
    this.created,
    this.updated,
  });

  factory User.fromRecord(RecordModel record) {
    return User(
      id: record.id,
      name: record.data['name']?.toString(),
      email: record.data['email']?.toString(),
      isVerified: record.data['verified'] == true,
      created: record.data['created'] != null
          ? DateTime.tryParse(record.data['created'].toString())
          : null,
      updated: record.data['updated'] != null
          ? DateTime.tryParse(record.data['updated'].toString())
          : null,
    );
  }
}

/// Repository for authentication-related operations
///
/// Provides a clean API for user authentication and management
@injectable
class AuthRepository {
  final PocketbaseService _pbService;

  AuthRepository({PocketbaseService? pbService})
      : _pbService = pbService ?? PocketbaseService();

  /// Initialize the repository
  Future<void> initialize() async {
    await _pbService.initialize();
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _pbService.isAuthenticated;

  /// Get current user
  User? get currentUser {
    final record = _pbService.currentUser;
    if (record == null) return null;
    return User.fromRecord(record);
  }

  /// Login with email and password
  /// 
  /// [email] - User's email address
  /// [password] - User's password
  /// 
  /// Returns authenticated user or throws [PocketbaseException]
  Future<User> login(String email, String password) async {
    try {
      final authData = await _pbService.pb
          .collection('users')
          .authWithPassword(email, password);

      return User.fromRecord(authData.record);
    } on ClientException {
      rethrow;
    } catch (e) {
      throw PocketbaseException(
        message: '로그인에 실패했습니다',
        originalError: e,
      );
    }
  }

  /// Register a new user
  /// 
  /// [name] - User's display name
  /// [email] - User's email address
  /// [password] - User's password
  /// 
  /// Returns created user or throws [PocketbaseException]
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final record = await _pbService.pb.collection('users').create(body: {
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'name': name,
        'emailVisibility': false,
      });

      // Send email verification
      await _pbService.pb
          .collection('users')
          .requestVerification(email);

      return User.fromRecord(record);
    } on ClientException {
      rethrow;
    } catch (e) {
      throw PocketbaseException(
        message: '회원가입에 실패했습니다',
        originalError: e,
      );
    }
  }

  /// Logout current user
  Future<void> logout() async {
    await _pbService.logout();
  }

  /// Request password reset email
  /// 
  /// [email] - User's email address
  Future<void> requestPasswordReset(String email) async {
    try {
      await _pbService.pb.collection('users').requestPasswordReset(email);
    } on ClientException {
      rethrow;
    } catch (e) {
      throw PocketbaseException(
        message: '비밀번호 재설정 요청에 실패했습니다',
        originalError: e,
      );
    }
  }

  /// Verify email with token
  /// 
  /// [token] - Verification token from email
  Future<void> verifyEmail(String token) async {
    try {
      await _pbService.pb.collection('users').confirmVerification(token);
    } on ClientException {
      rethrow;
    } catch (e) {
      throw PocketbaseException(
        message: '이메일 인증에 실패했습니다',
        originalError: e,
      );
    }
  }

  /// Resend email verification
  /// 
  /// [email] - User's email address
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _pbService.pb
          .collection('users')
          .requestVerification(email);
    } on ClientException {
      rethrow;
    } catch (e) {
      throw PocketbaseException(
        message: '인증 메일 재발송에 실패했습니다',
        originalError: e,
      );
    }
  }

  /// Login with OAuth provider
  /// 
  /// [provider] - OAuth provider name (e.g., 'google', 'facebook')
  Future<User> loginWithOAuth(String provider) async {
    try {
      final authData = await _pbService.loginWithOAuth(provider);
      return User.fromRecord(authData.record);
    } catch (e) {
      throw PocketbaseException(
        message: '소셜 로그인에 실패했습니다',
        originalError: e,
      );
    }
  }

  /// Update user profile
  ///
  /// [name] - New display name
  /// [avatarFile] - Avatar file (optional). Pass [MultipartFile] for file upload.
  Future<User> updateProfile({
    String? name,
    http.MultipartFile? avatarFile,
  }) async {
    try {
      final currentUser = _pbService.currentUser;
      if (currentUser == null) {
        throw PocketbaseException(message: '사용자가 로그인되어 있지 않습니다');
      }

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;

      final files = avatarFile != null ? [avatarFile] : <http.MultipartFile>[];
      final record = await _pbService.pb.collection('users').update(
            currentUser.id,
            body: body,
            files: files,
          );

      // Refresh auth to ensure avatar is in authStore (merge may not include file URLs)
      if (avatarFile != null) {
        await _pbService.pb.collection('users').authRefresh();
      }

      return User.fromRecord(record);
    } on ClientException {
      rethrow;
    } catch (e) {
      throw PocketbaseException(
        message: '프로필 업데이트에 실패했습니다',
        originalError: e,
      );
    }
  }

  /// Change user password
  /// 
  /// [oldPassword] - Current password
  /// [newPassword] - New password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final currentUser = _pbService.currentUser;
      if (currentUser == null) {
        throw PocketbaseException(message: '사용자가 로그인되어 있지 않습니다');
      }

      await _pbService.pb.collection('users').update(
        currentUser.id,
        body: {
          'oldPassword': oldPassword,
          'password': newPassword,
          'passwordConfirm': newPassword,
        },
      );
    } on ClientException {
      rethrow;
    } catch (e) {
      throw PocketbaseException(
        message: '비밀번호 변경에 실패했습니다',
        originalError: e,
      );
    }
  }

  /// Confirm password reset with token
  /// 
  /// [token] - Reset token from email
  /// [newPassword] - New password
  Future<void> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _pbService.pb.collection('users').confirmPasswordReset(
        token,
        newPassword,
        newPassword,
      );
    } on ClientException {
      rethrow;
    } catch (e) {
      throw PocketbaseException(
        message: '비밀번호 재설정에 실패했습니다',
        originalError: e,
      );
    }
  }
}
