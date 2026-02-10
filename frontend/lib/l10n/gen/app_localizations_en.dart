// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Korean Kids Stories';

  @override
  String get homeTab => 'Home';

  @override
  String get searchTab => 'Search';

  @override
  String get libraryTab => 'Library';

  @override
  String get settingsTab => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageTitle => 'Language Settings';

  @override
  String get landingTitle => 'Korean Kids Stories';

  @override
  String get landingSubtitle =>
      'From tradition to history, Korean stories for kids';

  @override
  String get browse => 'Browse';

  @override
  String get browseWithoutLogin => 'Browse without login';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign up';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get loginToAccount => 'Login to your account to enjoy stories';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get or => 'Or';

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get createAccount => 'Create an account';

  @override
  String get createAccountSubtitle => 'Create a new account to start stories';

  @override
  String get nameLabel => 'Name (Child\'s name)';

  @override
  String get passwordLengthHint => 'Password (6+ chars)';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get agreeTo => 'I agree to';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get and => 'and';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get enterEmailPassword => 'Please enter email and password';

  @override
  String get enterName => 'Please enter name';

  @override
  String get enterEmail => 'Please enter email';

  @override
  String get passwordMinLength => 'Password must be at least 6 chars';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get agreeTerms => 'Please agree to terms';

  @override
  String get stories => 'Stories';

  @override
  String get viewAll => 'View All';

  @override
  String get popularStories => 'Popular Stories';

  @override
  String get newStories => 'New Stories';

  @override
  String get recommended => 'Recommended';

  @override
  String get searchHint => 'Search stories...';

  @override
  String get register => 'Register';

  @override
  String get logout => 'Logout';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get version => 'Version';

  @override
  String get homeWelcome => 'Hello! 👋';

  @override
  String get homeSubtitle => 'Shall we listen to a fun story today?';

  @override
  String get homeSearchHint => 'Find fun stories...';

  @override
  String get recommendedStories => '✨ Recommended';

  @override
  String get refresh => 'Refresh';

  @override
  String get popularSectionTitle => '🔥 Popular';

  @override
  String get audioStories => '🎧 Audio';

  @override
  String get mostReviewedStories => '⭐ Most Reviewed';

  @override
  String get mostViewedStories => '👁 Most Viewed';

  @override
  String get recentStories => '🆕 New';

  @override
  String get loadStoryError => 'Failed to load stories';

  @override
  String get checkConnection => 'Please check your server connection';

  @override
  String get retry => 'Retry';

  @override
  String get noStories => 'No stories found';

  @override
  String get addStoriesAdmin => 'Please add stories in the admin page';

  @override
  String get storyNotFound => 'Story not found';

  @override
  String get tableOfContents => 'Table of Contents';

  @override
  String get startReading => 'Start Reading';

  @override
  String get bookmark => 'Save';

  @override
  String chapterTitleFallback(Object number) {
    return 'Chapter $number';
  }

  @override
  String get free => 'Free';

  @override
  String get locked => 'Locked';

  @override
  String get categoryFolktale => 'Folktale';

  @override
  String get categoryHistory => 'History';

  @override
  String get categoryLegend => 'Legend';

  @override
  String get loginRequired => 'Login required';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get accountSection => 'Account';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get changePassword => 'Change Password';

  @override
  String get loginAction => 'Login';

  @override
  String get reportAndSupport => 'Report & Support';

  @override
  String get reportAppIssue => 'Report App Issue';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get appInfo => 'App Info';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get rateApp => 'Rate App';

  @override
  String get shareApp => 'Share App';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get defaultUser => 'User';

  @override
  String get guest => 'Guest';

  @override
  String get guestSubtitle => 'Login to access all features';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get continueAction => 'Continue';

  @override
  String get deleteAccountConfirmation =>
      'Are you sure you want to delete your account?';

  @override
  String get deleteAccountWarning =>
      '• All reading history will be deleted\n• Saved bookmarks will be deleted\n• This action cannot be undone';

  @override
  String get finalConfirmation => 'Final Confirmation';

  @override
  String get deleteAccountPrompt =>
      'Type \"DELETE\" to confirm account deletion';

  @override
  String get deleteKeyword => 'DELETE';

  @override
  String get accountDeleted => 'Account deleted';

  @override
  String get deleteKeywordMismatch => 'Please type \"DELETE\" correctly';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String noSearchResults(Object query) {
    return 'No results for \"$query\"';
  }

  @override
  String get searchAgainHint => 'Try searching with different keywords';

  @override
  String get recentSearches => 'Recent Searches';

  @override
  String get clearAll => 'Clear All';

  @override
  String get popularSearches => 'Popular Searches';

  @override
  String get categories => 'Categories';

  @override
  String get ageGroups => 'Age Groups';

  @override
  String get ageGroup4to6 => '4-6 years';

  @override
  String get ageGroup7to9 => '7-9 years';

  @override
  String get ageGroup10to12 => '10-12 years';

  @override
  String get libraryTitle => 'Library';

  @override
  String get tabFavorites => 'Favorites';

  @override
  String get tabBookmarks => 'Bookmarks';

  @override
  String get tabNotes => 'Notes';

  @override
  String get libraryLoginPrompt =>
      'Please login to save favorites and bookmarks';

  @override
  String get favoritesEmpty => 'No favorites yet';

  @override
  String get noBookmarksYet => 'No bookmarks yet';

  @override
  String get noNotesYet => 'No notes yet';

  @override
  String get fontSize => 'Font Size';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String chapterTitleFormatted(Object number) {
    return 'Chapter $number';
  }

  @override
  String get otpTitle => 'Check your email';

  @override
  String get otpSentMessage => 'We sent a verification link to\n';

  @override
  String get checkEmail => 'Check your email';

  @override
  String get clickVerifyLink => 'Click the verification link';

  @override
  String get loginInstruction => 'Login';

  @override
  String get goToLogin => 'Go to Login';

  @override
  String get resendEmail => 'Resend Verification Email';

  @override
  String resendTimer(Object seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get spamCheckNote =>
      'Check your spam folder if you don\'t see the email';

  @override
  String get verificationSuccess => 'Verification completed!';

  @override
  String get emailResent => 'Verification email resent';

  @override
  String get historyTitle => 'My Activity';

  @override
  String get readingHistory => 'Reading History';

  @override
  String get listeningHistory => 'Listening History';

  @override
  String get searchHistory => 'Search History';

  @override
  String get historyLoginPrompt => 'Please login to save your reading history';

  @override
  String get weeklyStats => 'Weekly Stats';

  @override
  String get totalListening => 'Total Listening';

  @override
  String get completedStories => 'Completed Stories';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get historyLoadError => 'Error loading history';

  @override
  String get noReadingHistoryYet => 'No reading history yet';

  @override
  String get startReadingStories => 'Start reading some stories!';

  @override
  String get noCompletedStoriesYet => 'No completed stories yet';

  @override
  String get completeStoryHint => 'Complete a story to see it here!';
}
