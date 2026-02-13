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
  /// **'Korean Kids Tales'**
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
  /// **'Korean Kids Tales'**
  String get landingTitle;

  /// No description provided for @landingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From tradition to history, Korean stories for kids'**
  String get landingSubtitle;

  /// No description provided for @landingStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get landingStartButton;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In en, this message translates to:
  /// **'Korean Kids Tales'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Desc.
  ///
  /// In en, this message translates to:
  /// **'Discover Korean folktales, history and legends for kids ages 5-10.'**
  String get onboardingPage1Desc;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Read Stories & Collect Badges'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Desc.
  ///
  /// In en, this message translates to:
  /// **'Read stories, listen to audio and earn stickers when you finish. Track your progress in History.'**
  String get onboardingPage2Desc;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Parent Zone'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Desc.
  ///
  /// In en, this message translates to:
  /// **'Change language, view your child\'s activity and report issues. Protected by PIN or fingerprint.'**
  String get onboardingPage3Desc;

  /// No description provided for @onboardingNextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNextButton;

  /// No description provided for @onboardingStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingStartButton;

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

  /// No description provided for @basedOnYourReading.
  ///
  /// In en, this message translates to:
  /// **'📖 Based on what you\'ve read'**
  String get basedOnYourReading;

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

  /// No description provided for @listenNow.
  ///
  /// In en, this message translates to:
  /// **'Listen Now'**
  String get listenNow;

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

  /// No description provided for @nextChapter.
  ///
  /// In en, this message translates to:
  /// **'Next chapter'**
  String get nextChapter;

  /// No description provided for @previousChapter.
  ///
  /// In en, this message translates to:
  /// **'Previous chapter'**
  String get previousChapter;

  /// No description provided for @markComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get markComplete;

  /// No description provided for @chapterCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! 🎉'**
  String get chapterCompletedTitle;

  /// No description provided for @chapterCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'You finished this chapter!'**
  String get chapterCompletedMessage;

  /// No description provided for @storyCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Story finished! 🎉'**
  String get storyCompleteTitle;

  /// No description provided for @storyCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Want to do a quiz or listen to the next story?'**
  String get storyCompleteMessage;

  /// No description provided for @stickerEarnedCongrats.
  ///
  /// In en, this message translates to:
  /// **'You earned a new sticker! Check your Album 🎉'**
  String get stickerEarnedCongrats;

  /// No description provided for @stickerEarnedTitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You got a sticker! 🎉'**
  String get stickerEarnedTitle;

  /// No description provided for @doQuiz.
  ///
  /// In en, this message translates to:
  /// **'Do Quiz'**
  String get doQuiz;

  /// No description provided for @skipNextStory.
  ///
  /// In en, this message translates to:
  /// **'Next Story'**
  String get skipNextStory;

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

  /// No description provided for @nextChapterLocked.
  ///
  /// In en, this message translates to:
  /// **'Next chapter (Locked)'**
  String get nextChapterLocked;

  /// No description provided for @chapterLockedHint.
  ///
  /// In en, this message translates to:
  /// **'This chapter is locked. Go to Parent Zone to unlock.'**
  String get chapterLockedHint;

  /// No description provided for @chapterLocked.
  ///
  /// In en, this message translates to:
  /// **'This chapter is locked'**
  String get chapterLocked;

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

  /// No description provided for @categoryEdu.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEdu;

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

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

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

  /// No description provided for @minNextChapterTime.
  ///
  /// In en, this message translates to:
  /// **'Time before next chapter (by text length)'**
  String get minNextChapterTime;

  /// No description provided for @minNextChapterTimeOff.
  ///
  /// In en, this message translates to:
  /// **'No restriction'**
  String get minNextChapterTimeOff;

  /// No description provided for @minNextChapterTimeCharsPerSecond.
  ///
  /// In en, this message translates to:
  /// **'{chars} chars/sec'**
  String minNextChapterTimeCharsPerSecond(Object chars);

  /// No description provided for @minNextChapterCountdown.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String minNextChapterCountdown(Object seconds);

  /// No description provided for @reminderStreak.
  ///
  /// In en, this message translates to:
  /// **'Daily reading reminder'**
  String get reminderStreak;

  /// No description provided for @reminderStreakDesc.
  ///
  /// In en, this message translates to:
  /// **'Notify at end of day if no streak yet'**
  String get reminderStreakDesc;

  /// No description provided for @reminderOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get reminderOff;

  /// No description provided for @reminderOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get reminderOn;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily reading goal'**
  String get dailyGoal;

  /// No description provided for @dailyGoalOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get dailyGoalOff;

  /// No description provided for @dailyGoalStories.
  ///
  /// In en, this message translates to:
  /// **'Stories per day'**
  String get dailyGoalStories;

  /// No description provided for @dailyGoalChapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters per day'**
  String get dailyGoalChapters;

  /// No description provided for @dailyGoalFormat.
  ///
  /// In en, this message translates to:
  /// **'{current}/{target} today'**
  String dailyGoalFormat(Object current, Object target);

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @activityEmpty.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get activityEmpty;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{min} min'**
  String durationMinutes(Object min);

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

  /// No description provided for @playbackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Audio Speed'**
  String get playbackSpeed;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @voiceFemale.
  ///
  /// In en, this message translates to:
  /// **'Lady'**
  String get voiceFemale;

  /// No description provided for @voiceMale.
  ///
  /// In en, this message translates to:
  /// **'Man'**
  String get voiceMale;

  /// No description provided for @sleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep Timer'**
  String get sleepTimer;

  /// No description provided for @sleepTimerOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get sleepTimerOff;

  /// No description provided for @sleepTimer5min.
  ///
  /// In en, this message translates to:
  /// **'5 min'**
  String get sleepTimer5min;

  /// No description provided for @sleepTimer10min.
  ///
  /// In en, this message translates to:
  /// **'10 min'**
  String get sleepTimer10min;

  /// No description provided for @sleepTimer15min.
  ///
  /// In en, this message translates to:
  /// **'15 min'**
  String get sleepTimer15min;

  /// No description provided for @sleepTimerRemaining.
  ///
  /// In en, this message translates to:
  /// **'{min} min left'**
  String sleepTimerRemaining(Object min);

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

  /// No description provided for @otpEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Or enter the 6-digit code from email'**
  String get otpEnterCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

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

  /// No description provided for @completedChapters.
  ///
  /// In en, this message translates to:
  /// **'Completed Chapters'**
  String get completedChapters;

  /// No description provided for @historyPercentComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String historyPercentComplete(Object percent);

  /// No description provided for @timeAgoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String timeAgoMinutes(Object count);

  /// No description provided for @timeAgoHours.
  ///
  /// In en, this message translates to:
  /// **'{count} hrs ago'**
  String timeAgoHours(Object count);

  /// No description provided for @timeAgoDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String timeAgoDays(Object count);

  /// No description provided for @timeAgoWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count} wks ago'**
  String timeAgoWeeks(Object count);

  /// No description provided for @timeAgoMonths.
  ///
  /// In en, this message translates to:
  /// **'{count} mo ago'**
  String timeAgoMonths(Object count);

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @streakBadge.
  ///
  /// In en, this message translates to:
  /// **'🔥 {days} day streak!'**
  String streakBadge(Object days);

  /// No description provided for @streakBadgeText.
  ///
  /// In en, this message translates to:
  /// **'{days} day streak!'**
  String streakBadgeText(Object days);

  /// No description provided for @streakLongest.
  ///
  /// In en, this message translates to:
  /// **'Best: {days} days'**
  String streakLongest(Object days);

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

  /// No description provided for @noCompletedChaptersYet.
  ///
  /// In en, this message translates to:
  /// **'No completed chapters yet'**
  String get noCompletedChaptersYet;

  /// No description provided for @completeStoryHint.
  ///
  /// In en, this message translates to:
  /// **'Complete a story to see it here!'**
  String get completeStoryHint;

  /// No description provided for @completeChapterHint.
  ///
  /// In en, this message translates to:
  /// **'Complete a chapter to see it here!'**
  String get completeChapterHint;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Write a note for this story...'**
  String get noteHint;

  /// No description provided for @saveNote.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveNote;

  /// No description provided for @bookmarkAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to bookmarks'**
  String get bookmarkAdded;

  /// No description provided for @bookmarkRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from bookmarks'**
  String get bookmarkRemoved;

  /// No description provided for @addToBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Save for later'**
  String get addToBookmarks;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @reviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsTitle;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get writeReview;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get yourRating;

  /// No description provided for @optionalComment.
  ///
  /// In en, this message translates to:
  /// **'Optional comment'**
  String get optionalComment;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitReview;

  /// No description provided for @editReview.
  ///
  /// In en, this message translates to:
  /// **'Edit review'**
  String get editReview;

  /// No description provided for @yourReview.
  ///
  /// In en, this message translates to:
  /// **'Your review'**
  String get yourReview;

  /// No description provided for @deleteReview.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteReview;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @beFirstToReview.
  ///
  /// In en, this message translates to:
  /// **'Be the first to review!'**
  String get beFirstToReview;

  /// No description provided for @loginToReview.
  ///
  /// In en, this message translates to:
  /// **'Login to write a review'**
  String get loginToReview;

  /// No description provided for @deleteReviewConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your review?'**
  String get deleteReviewConfirmation;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @xp.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get xp;

  /// No description provided for @currentRank.
  ///
  /// In en, this message translates to:
  /// **'Current rank'**
  String get currentRank;

  /// No description provided for @nextRank.
  ///
  /// In en, this message translates to:
  /// **'Next rank'**
  String get nextRank;

  /// No description provided for @levelUpCongratsTitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations on your promotion! 🎉'**
  String get levelUpCongratsTitle;

  /// No description provided for @levelUpCongratsMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been promoted to {rank}!'**
  String levelUpCongratsMessage(Object rank);

  /// No description provided for @maxLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Maximum rank reached! 👑'**
  String get maxLevelTitle;

  /// No description provided for @stickerAlbum.
  ///
  /// In en, this message translates to:
  /// **'Sticker Album'**
  String get stickerAlbum;

  /// No description provided for @myStickers.
  ///
  /// In en, this message translates to:
  /// **'My Stickers'**
  String get myStickers;

  /// No description provided for @unlockedStickers.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlockedStickers;

  /// No description provided for @readStoriesToUnlockStickers.
  ///
  /// In en, this message translates to:
  /// **'Read stories to unlock stickers!'**
  String get readStoriesToUnlockStickers;

  /// No description provided for @storyStickers.
  ///
  /// In en, this message translates to:
  /// **'Story Stickers'**
  String get storyStickers;

  /// No description provided for @stickersLoginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Collect stickers by reading stories! Login to get started.'**
  String get stickersLoginPrompt;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @chapterNotFound.
  ///
  /// In en, this message translates to:
  /// **'Chapter not found'**
  String get chapterNotFound;

  /// No description provided for @chapterLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load chapter'**
  String get chapterLoadError;

  /// No description provided for @historyTab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get categoryFavorite;

  /// No description provided for @ageYearsFormat.
  ///
  /// In en, this message translates to:
  /// **'{min}-{max} years'**
  String ageYearsFormat(Object min, Object max);

  /// No description provided for @episodesFormat.
  ///
  /// In en, this message translates to:
  /// **'{count} eps'**
  String episodesFormat(Object count);

  /// No description provided for @illustration.
  ///
  /// In en, this message translates to:
  /// **'Illustration'**
  String get illustration;

  /// No description provided for @reportStory.
  ///
  /// In en, this message translates to:
  /// **'Report story'**
  String get reportStory;

  /// No description provided for @reportChapter.
  ///
  /// In en, this message translates to:
  /// **'Report chapter'**
  String get reportChapter;

  /// No description provided for @reportApp.
  ///
  /// In en, this message translates to:
  /// **'Report app issue'**
  String get reportApp;

  /// No description provided for @reportQuestion.
  ///
  /// In en, this message translates to:
  /// **'Report question'**
  String get reportQuestion;

  /// No description provided for @reportOther.
  ///
  /// In en, this message translates to:
  /// **'Other report'**
  String get reportOther;

  /// No description provided for @reportStoryHint.
  ///
  /// In en, this message translates to:
  /// **'What problem does the story have?'**
  String get reportStoryHint;

  /// No description provided for @reportChapterHint.
  ///
  /// In en, this message translates to:
  /// **'What problem does the chapter have?'**
  String get reportChapterHint;

  /// No description provided for @reportAppHint.
  ///
  /// In en, this message translates to:
  /// **'What problem occurred in the app?'**
  String get reportAppHint;

  /// No description provided for @reportQuestionHint.
  ///
  /// In en, this message translates to:
  /// **'What problem does the question have?'**
  String get reportQuestionHint;

  /// No description provided for @reportGeneralHint.
  ///
  /// In en, this message translates to:
  /// **'What problem do you have?'**
  String get reportGeneralHint;

  /// No description provided for @reportContentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the report content'**
  String get reportContentRequired;

  /// No description provided for @reportLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please login to report'**
  String get reportLoginRequired;

  /// No description provided for @reportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report submitted. We will review and take action.'**
  String get reportSuccess;

  /// No description provided for @reportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit report'**
  String get reportFailed;

  /// No description provided for @reportContent.
  ///
  /// In en, this message translates to:
  /// **'Report content'**
  String get reportContent;

  /// No description provided for @reportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get reportSubmit;

  /// No description provided for @reportTarget.
  ///
  /// In en, this message translates to:
  /// **'Target: {title}'**
  String reportTarget(Object title);

  /// No description provided for @parentZone.
  ///
  /// In en, this message translates to:
  /// **'Parent Zone'**
  String get parentZone;

  /// No description provided for @parentZoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View activity & manage premium'**
  String get parentZoneSubtitle;

  /// No description provided for @parentZoneEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get parentZoneEnterPin;

  /// No description provided for @parentZonePinHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 4-digit parent PIN'**
  String get parentZonePinHint;

  /// No description provided for @parentZoneWrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN. Try again.'**
  String get parentZoneWrongPin;

  /// No description provided for @parentZoneSetPin.
  ///
  /// In en, this message translates to:
  /// **'Set Parent PIN'**
  String get parentZoneSetPin;

  /// No description provided for @parentZoneSetPinHint.
  ///
  /// In en, this message translates to:
  /// **'Create a 4-digit PIN to protect Parent Zone'**
  String get parentZoneSetPinHint;

  /// No description provided for @parentZoneChildActivity.
  ///
  /// In en, this message translates to:
  /// **'Child\'s Activity'**
  String get parentZoneChildActivity;

  /// No description provided for @parentZonePremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get parentZonePremium;

  /// No description provided for @parentZoneComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get parentZoneComingSoon;

  /// No description provided for @parentZoneAuthReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to access Parent Zone'**
  String get parentZoneAuthReason;

  /// No description provided for @parentZoneAuthenticate.
  ///
  /// In en, this message translates to:
  /// **'Authenticate'**
  String get parentZoneAuthenticate;

  /// No description provided for @parentZoneNotSupported.
  ///
  /// In en, this message translates to:
  /// **'This device does not support biometric or PIN authentication.'**
  String get parentZoneNotSupported;

  /// No description provided for @parentZoneAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Try again.'**
  String get parentZoneAuthFailed;
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
