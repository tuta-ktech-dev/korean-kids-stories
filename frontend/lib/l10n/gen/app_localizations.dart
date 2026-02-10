import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
    Locale('vi'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Korean Kids Stories'**
  String get appTitle;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @searchTab.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTab;

  /// No description provided for @libraryTab.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get settingsLanguageTitle;

  /// No description provided for @landingTitle.
  ///
  /// In en, this message translates to:
  /// **'Korean Kids Stories'**
  String get landingTitle;

  /// No description provided for @landingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From tradition to history, Korean stories for kids'**
  String get landingSubtitle;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @browseWithoutLogin.
  ///
  /// In en, this message translates to:
  /// **'Browse without login'**
  String get browseWithoutLogin;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @loginToAccount.
  ///
  /// In en, this message translates to:
  /// **'Login to your account to enjoy stories'**
  String get loginToAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new account to start stories'**
  String get createAccountSubtitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (Child\'s name)'**
  String get nameLabel;

  /// No description provided for @passwordLengthHint.
  ///
  /// In en, this message translates to:
  /// **'Password (6+ chars)'**
  String get passwordLengthHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @agreeTo.
  ///
  /// In en, this message translates to:
  /// **'I agree to'**
  String get agreeTo;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @enterEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter email and password'**
  String get enterEmailPassword;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter name'**
  String get enterName;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get enterEmail;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 chars'**
  String get passwordMinLength;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'Please agree to terms'**
  String get agreeTerms;

  /// No description provided for @stories.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get stories;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @popularStories.
  ///
  /// In en, this message translates to:
  /// **'Popular Stories'**
  String get popularStories;

  /// No description provided for @newStories.
  ///
  /// In en, this message translates to:
  /// **'New Stories'**
  String get newStories;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search stories...'**
  String get searchHint;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hello! 👋'**
  String get homeWelcome;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shall we listen to a fun story today?'**
  String get homeSubtitle;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Find fun stories...'**
  String get homeSearchHint;

  /// No description provided for @recommendedStories.
  ///
  /// In en, this message translates to:
  /// **'✨ Recommended'**
  String get recommendedStories;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @popularSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'🔥 Popular'**
  String get popularSectionTitle;

  /// No description provided for @audioStories.
  ///
  /// In en, this message translates to:
  /// **'🎧 Audio'**
  String get audioStories;

  /// No description provided for @mostReviewedStories.
  ///
  /// In en, this message translates to:
  /// **'⭐ Most Reviewed'**
  String get mostReviewedStories;

  /// No description provided for @mostViewedStories.
  ///
  /// In en, this message translates to:
  /// **'👁 Most Viewed'**
  String get mostViewedStories;

  /// No description provided for @recentStories.
  ///
  /// In en, this message translates to:
  /// **'🆕 New'**
  String get recentStories;

  /// No description provided for @loadStoryError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load stories'**
  String get loadStoryError;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your server connection'**
  String get checkConnection;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noStories.
  ///
  /// In en, this message translates to:
  /// **'No stories found'**
  String get noStories;

  /// No description provided for @addStoriesAdmin.
  ///
  /// In en, this message translates to:
  /// **'Please add stories in the admin page'**
  String get addStoriesAdmin;

  /// No description provided for @storyNotFound.
  ///
  /// In en, this message translates to:
  /// **'Story not found'**
  String get storyNotFound;

  /// No description provided for @tableOfContents.
  ///
  /// In en, this message translates to:
  /// **'Table of Contents'**
  String get tableOfContents;

  /// No description provided for @startReading.
  ///
  /// In en, this message translates to:
  /// **'Start Reading'**
  String get startReading;

  /// No description provided for @bookmark.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get bookmark;

  /// No description provided for @chapterTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Chapter {number}'**
  String chapterTitleFallback(Object number);

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @categoryFolktale.
  ///
  /// In en, this message translates to:
  /// **'Folktale'**
  String get categoryFolktale;

  /// No description provided for @categoryHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get categoryHistory;

  /// No description provided for @categoryLegend.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get categoryLegend;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login required'**
  String get loginRequired;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @loginAction.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginAction;

  /// No description provided for @reportAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Report & Support'**
  String get reportAndSupport;

  /// No description provided for @reportAppIssue.
  ///
  /// In en, this message translates to:
  /// **'Report App Issue'**
  String get reportAppIssue;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get appInfo;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @defaultUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUser;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @guestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Login to access all features'**
  String get guestSubtitle;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get deleteAccountConfirmation;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'• All reading history will be deleted\n• Saved bookmarks will be deleted\n• This action cannot be undone'**
  String get deleteAccountWarning;

  /// No description provided for @finalConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Final Confirmation'**
  String get finalConfirmation;

  /// No description provided for @deleteAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type \"DELETE\" to confirm account deletion'**
  String get deleteAccountPrompt;

  /// No description provided for @deleteKeyword.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteKeyword;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeleted;

  /// No description provided for @deleteKeywordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Please type \"DELETE\" correctly'**
  String get deleteKeywordMismatch;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noSearchResults(Object query);

  /// No description provided for @searchAgainHint.
  ///
  /// In en, this message translates to:
  /// **'Try searching with different keywords'**
  String get searchAgainHint;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @popularSearches.
  ///
  /// In en, this message translates to:
  /// **'Popular Searches'**
  String get popularSearches;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @ageGroups.
  ///
  /// In en, this message translates to:
  /// **'Age Groups'**
  String get ageGroups;

  /// No description provided for @ageGroup4to6.
  ///
  /// In en, this message translates to:
  /// **'4-6 years'**
  String get ageGroup4to6;

  /// No description provided for @ageGroup7to9.
  ///
  /// In en, this message translates to:
  /// **'7-9 years'**
  String get ageGroup7to9;

  /// No description provided for @ageGroup10to12.
  ///
  /// In en, this message translates to:
  /// **'10-12 years'**
  String get ageGroup10to12;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @tabFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get tabFavorites;

  /// No description provided for @tabBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get tabBookmarks;

  /// No description provided for @tabNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get tabNotes;

  /// No description provided for @libraryLoginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please login to save favorites and bookmarks'**
  String get libraryLoginPrompt;

  /// No description provided for @favoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favoritesEmpty;

  /// No description provided for @noBookmarksYet.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get noBookmarksYet;

  /// No description provided for @noNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get noNotesYet;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @chapterTitleFormatted.
  ///
  /// In en, this message translates to:
  /// **'Chapter {number}'**
  String chapterTitleFormatted(Object number);

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get otpTitle;

  /// No description provided for @otpSentMessage.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to\n'**
  String get otpSentMessage;

  /// No description provided for @checkEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkEmail;

  /// No description provided for @clickVerifyLink.
  ///
  /// In en, this message translates to:
  /// **'Click the verification link'**
  String get clickVerifyLink;

  /// No description provided for @loginInstruction.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginInstruction;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get goToLogin;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendEmail;

  /// No description provided for @resendTimer.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendTimer(Object seconds);

  /// No description provided for @spamCheckNote.
  ///
  /// In en, this message translates to:
  /// **'Check your spam folder if you don\'t see the email'**
  String get spamCheckNote;

  /// No description provided for @verificationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification completed!'**
  String get verificationSuccess;

  /// No description provided for @emailResent.
  ///
  /// In en, this message translates to:
  /// **'Verification email resent'**
  String get emailResent;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'My Activity'**
  String get historyTitle;

  /// No description provided for @readingHistory.
  ///
  /// In en, this message translates to:
  /// **'Reading History'**
  String get readingHistory;

  /// No description provided for @listeningHistory.
  ///
  /// In en, this message translates to:
  /// **'Listening History'**
  String get listeningHistory;

  /// No description provided for @searchHistory.
  ///
  /// In en, this message translates to:
  /// **'Search History'**
  String get searchHistory;

  /// No description provided for @historyLoginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please login to save your reading history'**
  String get historyLoginPrompt;

  /// No description provided for @weeklyStats.
  ///
  /// In en, this message translates to:
  /// **'Weekly Stats'**
  String get weeklyStats;

  /// No description provided for @totalListening.
  ///
  /// In en, this message translates to:
  /// **'Total Listening'**
  String get totalListening;

  /// No description provided for @completedStories.
  ///
  /// In en, this message translates to:
  /// **'Completed Stories'**
  String get completedStories;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @historyLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading history'**
  String get historyLoadError;

  /// No description provided for @noReadingHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No reading history yet'**
  String get noReadingHistoryYet;

  /// No description provided for @startReadingStories.
  ///
  /// In en, this message translates to:
  /// **'Start reading some stories!'**
  String get startReadingStories;

  /// No description provided for @noCompletedStoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No completed stories yet'**
  String get noCompletedStoriesYet;

  /// No description provided for @completeStoryHint.
  ///
  /// In en, this message translates to:
  /// **'Complete a story to see it here!'**
  String get completeStoryHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
