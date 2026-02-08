import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In de, this message translates to:
  /// **'Nuuray Glow'**
  String get appName;

  /// No description provided for @appNameGlow.
  ///
  /// In de, this message translates to:
  /// **'Nuuray Glow'**
  String get appNameGlow;

  /// No description provided for @appNameTide.
  ///
  /// In de, this message translates to:
  /// **'Nuuray Tide'**
  String get appNameTide;

  /// No description provided for @appNamePath.
  ///
  /// In de, this message translates to:
  /// **'Nuuray Path'**
  String get appNamePath;

  /// No description provided for @appTagline.
  ///
  /// In de, this message translates to:
  /// **'Dein Mondlicht'**
  String get appTagline;

  /// No description provided for @commonNext.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get commonBack;

  /// No description provided for @commonDone.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get commonDone;

  /// No description provided for @commonSave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get commonCancel;

  /// No description provided for @commonRetry.
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get commonRetry;

  /// No description provided for @commonLoading.
  ///
  /// In de, this message translates to:
  /// **'Wird geladen...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In de, this message translates to:
  /// **'Etwas ist schiefgelaufen.'**
  String get commonError;

  /// No description provided for @commonErrorPrefix.
  ///
  /// In de, this message translates to:
  /// **'Fehler: '**
  String get commonErrorPrefix;

  /// No description provided for @commonComingSoon.
  ///
  /// In de, this message translates to:
  /// **'Coming Soon!'**
  String get commonComingSoon;

  /// No description provided for @commonLogout.
  ///
  /// In de, this message translates to:
  /// **'Logout'**
  String get commonLogout;

  /// No description provided for @commonLearnMore.
  ///
  /// In de, this message translates to:
  /// **'Mehr erfahren'**
  String get commonLearnMore;

  /// No description provided for @commonTryAgain.
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get commonTryAgain;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In de, this message translates to:
  /// **'Guten Morgen'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In de, this message translates to:
  /// **'Guten Tag'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingDay.
  ///
  /// In de, this message translates to:
  /// **'Guten Tag'**
  String get homeGreetingDay;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In de, this message translates to:
  /// **'Guten Abend'**
  String get homeGreetingEvening;

  /// No description provided for @homeDailyEnergyTitle.
  ///
  /// In de, this message translates to:
  /// **'Tagesenergie'**
  String get homeDailyEnergyTitle;

  /// No description provided for @homeDailyEnergy.
  ///
  /// In de, this message translates to:
  /// **'Tagesenergie'**
  String get homeDailyEnergy;

  /// No description provided for @homeMoonPhaseExample.
  ///
  /// In de, this message translates to:
  /// **'Zunehmender Mond in Steinbock'**
  String get homeMoonPhaseExample;

  /// No description provided for @homeDailyEnergyMoonExample.
  ///
  /// In de, this message translates to:
  /// **'Zunehmender Mond in Steinbock'**
  String get homeDailyEnergyMoonExample;

  /// No description provided for @homeEnergyDescriptionExample.
  ///
  /// In de, this message translates to:
  /// **'Heute ist ein guter Tag für Struktur und Planung. Die kosmische Energie unterstützt dich dabei, deine Ziele klar zu definieren.'**
  String get homeEnergyDescriptionExample;

  /// No description provided for @homeDailyEnergyDescriptionExample.
  ///
  /// In de, this message translates to:
  /// **'Heute ist ein guter Tag für Struktur und Planung. Die kosmische Energie unterstützt dich dabei, deine Ziele klar zu definieren.'**
  String get homeDailyEnergyDescriptionExample;

  /// No description provided for @homeSignatureSectionTitle.
  ///
  /// In de, this message translates to:
  /// **'Deine Signatur'**
  String get homeSignatureSectionTitle;

  /// No description provided for @homeYourSignature.
  ///
  /// In de, this message translates to:
  /// **'Deine Signatur'**
  String get homeYourSignature;

  /// No description provided for @homeSignatureIncompleteTitle.
  ///
  /// In de, this message translates to:
  /// **'Geburtsdaten unvollständig'**
  String get homeSignatureIncompleteTitle;

  /// No description provided for @homeSignatureIncomplete.
  ///
  /// In de, this message translates to:
  /// **'Geburtsdaten unvollständig'**
  String get homeSignatureIncomplete;

  /// No description provided for @homeSignatureIncompleteDescription.
  ///
  /// In de, this message translates to:
  /// **'Bitte vervollständige deine Geburtsdaten im Onboarding, um deine kosmische Signatur zu berechnen.'**
  String get homeSignatureIncompleteDescription;

  /// No description provided for @homeSignatureErrorTitle.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden'**
  String get homeSignatureErrorTitle;

  /// No description provided for @homeSignatureLoadError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden'**
  String get homeSignatureLoadError;

  /// No description provided for @homeDiscoverMoreTitle.
  ///
  /// In de, this message translates to:
  /// **'Entdecke mehr'**
  String get homeDiscoverMoreTitle;

  /// No description provided for @homeQuickActions.
  ///
  /// In de, this message translates to:
  /// **'Entdecke mehr'**
  String get homeQuickActions;

  /// No description provided for @homeActionMoonCalendar.
  ///
  /// In de, this message translates to:
  /// **'Mondkalender'**
  String get homeActionMoonCalendar;

  /// No description provided for @homeMoonCalendar.
  ///
  /// In de, this message translates to:
  /// **'Mondkalender'**
  String get homeMoonCalendar;

  /// No description provided for @homeActionMoonPhasesSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Alle Mondphasen'**
  String get homeActionMoonPhasesSubtitle;

  /// No description provided for @homeMoonCalendarSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Alle Mondphasen'**
  String get homeMoonCalendarSubtitle;

  /// No description provided for @homeActionPartnerCheck.
  ///
  /// In de, this message translates to:
  /// **'Partner-Check'**
  String get homeActionPartnerCheck;

  /// No description provided for @homePartnerCheck.
  ///
  /// In de, this message translates to:
  /// **'Partner-Check'**
  String get homePartnerCheck;

  /// No description provided for @homeActionCompatibilitySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Kompatibilität'**
  String get homeActionCompatibilitySubtitle;

  /// No description provided for @homePartnerCheckSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Kompatibilität'**
  String get homePartnerCheckSubtitle;

  /// No description provided for @homeProfileLoadError.
  ///
  /// In de, this message translates to:
  /// **'Profil konnte nicht geladen werden'**
  String get homeProfileLoadError;

  /// No description provided for @horoscopeTitle.
  ///
  /// In de, this message translates to:
  /// **'Dein Tageshoroskop'**
  String get horoscopeTitle;

  /// No description provided for @horoscopePersonalForYou.
  ///
  /// In de, this message translates to:
  /// **'Persönlich für dich'**
  String get horoscopePersonalForYou;

  /// No description provided for @horoscopeBaziInsightTitle.
  ///
  /// In de, this message translates to:
  /// **'Dein Bazi heute'**
  String get horoscopeBaziInsightTitle;

  /// No description provided for @horoscopeNumerologyInsightTitle.
  ///
  /// In de, this message translates to:
  /// **'Deine Numerologie'**
  String get horoscopeNumerologyInsightTitle;

  /// No description provided for @horoscopeLoading.
  ///
  /// In de, this message translates to:
  /// **'Lade dein Horoskop...'**
  String get horoscopeLoading;

  /// No description provided for @horoscopeErrorTitle.
  ///
  /// In de, this message translates to:
  /// **'Horoskop konnte nicht geladen werden'**
  String get horoscopeErrorTitle;

  /// No description provided for @horoscopeErrorRetry.
  ///
  /// In de, this message translates to:
  /// **'Bitte versuche es später erneut.'**
  String get horoscopeErrorRetry;

  /// No description provided for @horoscopeMissingBirthdataTitle.
  ///
  /// In de, this message translates to:
  /// **'Geburtsdaten fehlen'**
  String get horoscopeMissingBirthdataTitle;

  /// No description provided for @horoscopeMissingBirthdataDescription.
  ///
  /// In de, this message translates to:
  /// **'Bitte vervollständige deine Geburtsdaten, um dein persönliches Horoskop zu sehen.'**
  String get horoscopeMissingBirthdataDescription;

  /// No description provided for @zodiacAries.
  ///
  /// In de, this message translates to:
  /// **'Widder'**
  String get zodiacAries;

  /// No description provided for @zodiacTaurus.
  ///
  /// In de, this message translates to:
  /// **'Stier'**
  String get zodiacTaurus;

  /// No description provided for @zodiacGemini.
  ///
  /// In de, this message translates to:
  /// **'Zwillinge'**
  String get zodiacGemini;

  /// No description provided for @zodiacCancer.
  ///
  /// In de, this message translates to:
  /// **'Krebs'**
  String get zodiacCancer;

  /// No description provided for @zodiacLeo.
  ///
  /// In de, this message translates to:
  /// **'Löwe'**
  String get zodiacLeo;

  /// No description provided for @zodiacVirgo.
  ///
  /// In de, this message translates to:
  /// **'Jungfrau'**
  String get zodiacVirgo;

  /// No description provided for @zodiacLibra.
  ///
  /// In de, this message translates to:
  /// **'Waage'**
  String get zodiacLibra;

  /// No description provided for @zodiacScorpio.
  ///
  /// In de, this message translates to:
  /// **'Skorpion'**
  String get zodiacScorpio;

  /// No description provided for @zodiacSagittarius.
  ///
  /// In de, this message translates to:
  /// **'Schütze'**
  String get zodiacSagittarius;

  /// No description provided for @zodiacCapricorn.
  ///
  /// In de, this message translates to:
  /// **'Steinbock'**
  String get zodiacCapricorn;

  /// No description provided for @zodiacAquarius.
  ///
  /// In de, this message translates to:
  /// **'Wassermann'**
  String get zodiacAquarius;

  /// No description provided for @zodiacPisces.
  ///
  /// In de, this message translates to:
  /// **'Fische'**
  String get zodiacPisces;

  /// No description provided for @authAppTagline.
  ///
  /// In de, this message translates to:
  /// **'Kosmische Unterhaltung'**
  String get authAppTagline;

  /// No description provided for @authEmailLabel.
  ///
  /// In de, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get authPasswordLabel;

  /// No description provided for @authEmailRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte Email eingeben'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In de, this message translates to:
  /// **'Ungültige Email'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte Passwort eingeben'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordMinLength.
  ///
  /// In de, this message translates to:
  /// **'Passwort muss mindestens 6 Zeichen haben'**
  String get authPasswordMinLength;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In de, this message translates to:
  /// **'Passwort muss mindestens 6 Zeichen haben'**
  String get authPasswordTooShort;

  /// No description provided for @authForgotPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort vergessen?'**
  String get authForgotPassword;

  /// No description provided for @authPasswordForgot.
  ///
  /// In de, this message translates to:
  /// **'Passwort vergessen?'**
  String get authPasswordForgot;

  /// No description provided for @authSignIn.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get authSignIn;

  /// No description provided for @authNoAccount.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Account?'**
  String get authNoAccount;

  /// No description provided for @authRegisterNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt registrieren'**
  String get authRegisterNow;

  /// No description provided for @authSignUpNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt registrieren'**
  String get authSignUpNow;

  /// No description provided for @authCreateAccountTitle.
  ///
  /// In de, this message translates to:
  /// **'Account erstellen'**
  String get authCreateAccountTitle;

  /// No description provided for @authCreateAccount.
  ///
  /// In de, this message translates to:
  /// **'Account erstellen'**
  String get authCreateAccount;

  /// No description provided for @authCosmicJourneySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Starte deine kosmische Reise'**
  String get authCosmicJourneySubtitle;

  /// No description provided for @authSignupSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Starte deine kosmische Reise'**
  String get authSignupSubtitle;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In de, this message translates to:
  /// **'Passwort bestätigen'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authPasswordConfirm.
  ///
  /// In de, this message translates to:
  /// **'Passwort bestätigen'**
  String get authPasswordConfirm;

  /// No description provided for @authConfirmPasswordRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte Passwort bestätigen'**
  String get authConfirmPasswordRequired;

  /// No description provided for @authPasswordConfirmRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte Passwort bestätigen'**
  String get authPasswordConfirmRequired;

  /// No description provided for @authPasswordsMismatch.
  ///
  /// In de, this message translates to:
  /// **'Passwörter stimmen nicht überein'**
  String get authPasswordsMismatch;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In de, this message translates to:
  /// **'Passwörter stimmen nicht überein'**
  String get authPasswordMismatch;

  /// No description provided for @authRegisterButton.
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get authRegisterButton;

  /// No description provided for @authSignUp.
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get authSignUp;

  /// No description provided for @authAlreadyRegistered.
  ///
  /// In de, this message translates to:
  /// **'Schon registriert?'**
  String get authAlreadyRegistered;

  /// No description provided for @authSignInNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt anmelden'**
  String get authSignInNow;

  /// No description provided for @authSignInFailed.
  ///
  /// In de, this message translates to:
  /// **'Login fehlgeschlagen'**
  String get authSignInFailed;

  /// No description provided for @authLoginFailed.
  ///
  /// In de, this message translates to:
  /// **'Login fehlgeschlagen'**
  String get authLoginFailed;

  /// No description provided for @authRegistrationFailed.
  ///
  /// In de, this message translates to:
  /// **'Registrierung fehlgeschlagen'**
  String get authRegistrationFailed;

  /// No description provided for @authSignupFailed.
  ///
  /// In de, this message translates to:
  /// **'Registrierung fehlgeschlagen'**
  String get authSignupFailed;

  /// No description provided for @authPasswordResetComingSoon.
  ///
  /// In de, this message translates to:
  /// **'Passwort-Reset kommt bald!'**
  String get authPasswordResetComingSoon;

  /// No description provided for @onboardingNameTitle.
  ///
  /// In de, this message translates to:
  /// **'Wie heißt du?'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Dein vollständiger Name hilft uns, deine numerologische Energie zu verstehen.'**
  String get onboardingNameSubtitle;

  /// No description provided for @onboardingNameDisplayLabel.
  ///
  /// In de, this message translates to:
  /// **'Rufname / Username *'**
  String get onboardingNameDisplayLabel;

  /// No description provided for @onboardingNameDisplayHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. Natalie'**
  String get onboardingNameDisplayHint;

  /// No description provided for @onboardingNameDisplayHelper.
  ///
  /// In de, this message translates to:
  /// **'Wie sollen wir dich nennen?'**
  String get onboardingNameDisplayHelper;

  /// No description provided for @onboardingNameDisplayRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib deinen Rufnamen ein'**
  String get onboardingNameDisplayRequired;

  /// No description provided for @onboardingNameFullnamesLabel.
  ///
  /// In de, this message translates to:
  /// **'Vornamen lt. Geburtsurkunde (optional)'**
  String get onboardingNameFullnamesLabel;

  /// No description provided for @onboardingNameFullnamesHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. Natalie Frauke'**
  String get onboardingNameFullnamesHint;

  /// No description provided for @onboardingNameFullnamesHelper.
  ///
  /// In de, this message translates to:
  /// **'Alle Vornamen aus der Geburtsurkunde'**
  String get onboardingNameFullnamesHelper;

  /// No description provided for @onboardingNameBirthLabel.
  ///
  /// In de, this message translates to:
  /// **'Geburtsname (optional)'**
  String get onboardingNameBirthLabel;

  /// No description provided for @onboardingNameBirthHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. Pawlowski'**
  String get onboardingNameBirthHint;

  /// No description provided for @onboardingNameBirthHelper.
  ///
  /// In de, this message translates to:
  /// **'Nachname bei Geburt (Maiden Name)'**
  String get onboardingNameBirthHelper;

  /// No description provided for @onboardingNameCurrentLabel.
  ///
  /// In de, this message translates to:
  /// **'Nachname aktuell (optional)'**
  String get onboardingNameCurrentLabel;

  /// No description provided for @onboardingNameCurrentHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. Günes'**
  String get onboardingNameCurrentHint;

  /// No description provided for @onboardingNameCurrentHelper.
  ///
  /// In de, this message translates to:
  /// **'Aktueller Nachname (falls geändert)'**
  String get onboardingNameCurrentHelper;

  /// No description provided for @onboardingNameInfoText.
  ///
  /// In de, this message translates to:
  /// **'Für präzise Numerologie empfehlen wir, alle Felder auszufüllen. Besonders wichtig: Vornamen + Geburtsname zeigen deine Urenergie.'**
  String get onboardingNameInfoText;

  /// No description provided for @onboardingBirthdataTitle.
  ///
  /// In de, this message translates to:
  /// **'Wann & wo wurdest du geboren?'**
  String get onboardingBirthdataTitle;

  /// No description provided for @onboardingBirthdataSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Deine Geburtsdaten bestimmen deine kosmische Signatur.'**
  String get onboardingBirthdataSubtitle;

  /// No description provided for @onboardingBirthdateLabel.
  ///
  /// In de, this message translates to:
  /// **'Geburtsdatum *'**
  String get onboardingBirthdateLabel;

  /// No description provided for @onboardingBirthdatePlaceholder.
  ///
  /// In de, this message translates to:
  /// **'Datum wählen'**
  String get onboardingBirthdatePlaceholder;

  /// No description provided for @onboardingBirthtimeLabel.
  ///
  /// In de, this message translates to:
  /// **'Geburtszeit (optional)'**
  String get onboardingBirthtimeLabel;

  /// No description provided for @onboardingBirthtimePlaceholder.
  ///
  /// In de, this message translates to:
  /// **'Zeit wählen'**
  String get onboardingBirthtimePlaceholder;

  /// No description provided for @onboardingBirthtimeFormat.
  ///
  /// In de, this message translates to:
  /// **'{hour}:{minute} Uhr'**
  String onboardingBirthtimeFormat(String hour, String minute);

  /// No description provided for @onboardingBirthtimeUnknown.
  ///
  /// In de, this message translates to:
  /// **'Geburtszeit ist mir nicht bekannt'**
  String get onboardingBirthtimeUnknown;

  /// No description provided for @onboardingBirthplaceSectionTitle.
  ///
  /// In de, this message translates to:
  /// **'Geburtsort (optional)'**
  String get onboardingBirthplaceSectionTitle;

  /// No description provided for @onboardingBirthplaceHelper.
  ///
  /// In de, this message translates to:
  /// **'Für präzise Aszendent-Berechnung'**
  String get onboardingBirthplaceHelper;

  /// No description provided for @onboardingBirthplaceLabel.
  ///
  /// In de, this message translates to:
  /// **'Stadt oder Ort'**
  String get onboardingBirthplaceLabel;

  /// No description provided for @onboardingBirthplaceHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. München, Deutschland'**
  String get onboardingBirthplaceHint;

  /// No description provided for @onboardingBirthplaceHelperText.
  ///
  /// In de, this message translates to:
  /// **'Tippe mindestens 3 Buchstaben'**
  String get onboardingBirthplaceHelperText;

  /// No description provided for @onboardingBirthplaceNotFound.
  ///
  /// In de, this message translates to:
  /// **'Kein Ort gefunden. Versuche \"Stadt, Land\" (z.B. \"München, Deutschland\")'**
  String get onboardingBirthplaceNotFound;

  /// No description provided for @onboardingBirthplaceError.
  ///
  /// In de, this message translates to:
  /// **'Fehler {status}: {data}'**
  String onboardingBirthplaceError(String status, String data);

  /// No description provided for @onboardingBirthplaceNetworkError.
  ///
  /// In de, this message translates to:
  /// **'Netzwerkfehler: '**
  String get onboardingBirthplaceNetworkError;

  /// No description provided for @onboardingBirthplaceSkip.
  ///
  /// In de, this message translates to:
  /// **'Geburtsort überspringen'**
  String get onboardingBirthplaceSkip;

  /// No description provided for @onboardingBirthdateRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte wähle dein Geburtsdatum'**
  String get onboardingBirthdateRequired;

  /// No description provided for @onboardingWelcome.
  ///
  /// In de, this message translates to:
  /// **'Willkommen bei Nuuray'**
  String get onboardingWelcome;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Entdecke, was die Sterne für dich bereithalten.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingBirthDate.
  ///
  /// In de, this message translates to:
  /// **'Wann bist du geboren?'**
  String get onboardingBirthDate;

  /// No description provided for @onboardingBirthTime.
  ///
  /// In de, this message translates to:
  /// **'Weißt du deine Geburtszeit?'**
  String get onboardingBirthTime;

  /// No description provided for @onboardingBirthTimeOptional.
  ///
  /// In de, this message translates to:
  /// **'Optional — ermöglicht genauere Analyse'**
  String get onboardingBirthTimeOptional;

  /// No description provided for @onboardingBirthCity.
  ///
  /// In de, this message translates to:
  /// **'Wo bist du geboren?'**
  String get onboardingBirthCity;

  /// No description provided for @onboardingBirthCityOptional.
  ///
  /// In de, this message translates to:
  /// **'Optional — für Aszendent-Berechnung'**
  String get onboardingBirthCityOptional;

  /// No description provided for @onboardingComplete.
  ///
  /// In de, this message translates to:
  /// **'Dein kosmisches Profil ist bereit!'**
  String get onboardingComplete;

  /// No description provided for @onboardingContinue.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get onboardingContinue;

  /// No description provided for @onboardingSkip.
  ///
  /// In de, this message translates to:
  /// **'Überspringen'**
  String get onboardingSkip;

  /// No description provided for @signatureScreenTitle.
  ///
  /// In de, this message translates to:
  /// **'Deine Signatur'**
  String get signatureScreenTitle;

  /// No description provided for @signatureCalculating.
  ///
  /// In de, this message translates to:
  /// **'Profil wird berechnet...'**
  String get signatureCalculating;

  /// No description provided for @signatureCosmicIdentityTitle.
  ///
  /// In de, this message translates to:
  /// **'Deine kosmische Identität'**
  String get signatureCosmicIdentityTitle;

  /// No description provided for @signatureCosmicIdentitySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Eine Synthese aus drei Weisheitstraditionen'**
  String get signatureCosmicIdentitySubtitle;

  /// No description provided for @signatureSystemsInfo.
  ///
  /// In de, this message translates to:
  /// **'Alle drei Systeme arbeiten zusammen und ergänzen sich gegenseitig.'**
  String get signatureSystemsInfo;

  /// No description provided for @signatureErrorLoading.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden des Profils'**
  String get signatureErrorLoading;

  /// No description provided for @signatureWesternAstrologyTitle.
  ///
  /// In de, this message translates to:
  /// **'Western Astrology'**
  String get signatureWesternAstrologyTitle;

  /// No description provided for @signatureWesternAstrologySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Deine Planetenpositionen'**
  String get signatureWesternAstrologySubtitle;

  /// No description provided for @astrologyPlanetSun.
  ///
  /// In de, this message translates to:
  /// **'Sonne'**
  String get astrologyPlanetSun;

  /// No description provided for @astrologyPlanetMoon.
  ///
  /// In de, this message translates to:
  /// **'Mond'**
  String get astrologyPlanetMoon;

  /// No description provided for @astrologyPlanetAscendant.
  ///
  /// In de, this message translates to:
  /// **'Aszendent'**
  String get astrologyPlanetAscendant;

  /// No description provided for @signatureAscendantRequiresCoordinates.
  ///
  /// In de, this message translates to:
  /// **'Aszendent: Geburtsort-Koordinaten erforderlich'**
  String get signatureAscendantRequiresCoordinates;

  /// No description provided for @signatureBaziTitle.
  ///
  /// In de, this message translates to:
  /// **'Bazi (四柱)'**
  String get signatureBaziTitle;

  /// No description provided for @signatureBaziSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Vier Säulen des Schicksals'**
  String get signatureBaziSubtitle;

  /// No description provided for @signatureBaziDayMaster.
  ///
  /// In de, this message translates to:
  /// **'Tages-Meister'**
  String get signatureBaziDayMaster;

  /// No description provided for @signatureBaziYear.
  ///
  /// In de, this message translates to:
  /// **'Jahr'**
  String get signatureBaziYear;

  /// No description provided for @signatureBaziMonth.
  ///
  /// In de, this message translates to:
  /// **'Monat'**
  String get signatureBaziMonth;

  /// No description provided for @signatureBaziDay.
  ///
  /// In de, this message translates to:
  /// **'Tag'**
  String get signatureBaziDay;

  /// No description provided for @signatureBaziHour.
  ///
  /// In de, this message translates to:
  /// **'Stunde'**
  String get signatureBaziHour;

  /// No description provided for @signatureBaziDominantElement.
  ///
  /// In de, this message translates to:
  /// **'Dominantes Element:'**
  String get signatureBaziDominantElement;

  /// No description provided for @baziElementWood.
  ///
  /// In de, this message translates to:
  /// **'Holz'**
  String get baziElementWood;

  /// No description provided for @baziElementFire.
  ///
  /// In de, this message translates to:
  /// **'Feuer'**
  String get baziElementFire;

  /// No description provided for @baziElementEarth.
  ///
  /// In de, this message translates to:
  /// **'Erde'**
  String get baziElementEarth;

  /// No description provided for @baziElementMetal.
  ///
  /// In de, this message translates to:
  /// **'Metall'**
  String get baziElementMetal;

  /// No description provided for @baziElementWater.
  ///
  /// In de, this message translates to:
  /// **'Wasser'**
  String get baziElementWater;

  /// No description provided for @signatureNumerologyTitle.
  ///
  /// In de, this message translates to:
  /// **'Numerologie'**
  String get signatureNumerologyTitle;

  /// No description provided for @signatureNumerologySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Deine Lebenszahlen'**
  String get signatureNumerologySubtitle;

  /// No description provided for @numerologyLifePath.
  ///
  /// In de, this message translates to:
  /// **'Lebensweg'**
  String get numerologyLifePath;

  /// No description provided for @numerologyBirthday.
  ///
  /// In de, this message translates to:
  /// **'Geburtstag'**
  String get numerologyBirthday;

  /// No description provided for @numerologyAttitude.
  ///
  /// In de, this message translates to:
  /// **'Haltung'**
  String get numerologyAttitude;

  /// No description provided for @numerologyPersonalYear.
  ///
  /// In de, this message translates to:
  /// **'Jahr {year}'**
  String numerologyPersonalYear(String year);

  /// No description provided for @numerologyMaturity.
  ///
  /// In de, this message translates to:
  /// **'Reife'**
  String get numerologyMaturity;

  /// No description provided for @numerologyBirthEnergy.
  ///
  /// In de, this message translates to:
  /// **'Urenergie'**
  String get numerologyBirthEnergy;

  /// No description provided for @numerologyCurrentEnergy.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Energie'**
  String get numerologyCurrentEnergy;

  /// No description provided for @numerologyExpression.
  ///
  /// In de, this message translates to:
  /// **'Ausdruck'**
  String get numerologyExpression;

  /// No description provided for @numerologyExpressionMeaning.
  ///
  /// In de, this message translates to:
  /// **'Talent & Fähigkeiten'**
  String get numerologyExpressionMeaning;

  /// No description provided for @numerologySoulUrge.
  ///
  /// In de, this message translates to:
  /// **'Seelenwunsch'**
  String get numerologySoulUrge;

  /// No description provided for @numerologySoulUrgeMeaning.
  ///
  /// In de, this message translates to:
  /// **'Innere Sehnsucht'**
  String get numerologySoulUrgeMeaning;

  /// No description provided for @numerologyPersonality.
  ///
  /// In de, this message translates to:
  /// **'Persönlichkeit'**
  String get numerologyPersonality;

  /// No description provided for @numerologyPersonalityMeaning.
  ///
  /// In de, this message translates to:
  /// **'Äußere Wirkung'**
  String get numerologyPersonalityMeaning;

  /// No description provided for @signatureNumerologyFullNameRequired.
  ///
  /// In de, this message translates to:
  /// **'Vollständiger Name für weitere Zahlen erforderlich'**
  String get signatureNumerologyFullNameRequired;

  /// No description provided for @signatureNumerologyAdvancedTitle.
  ///
  /// In de, this message translates to:
  /// **'Erweiterte Numerologie'**
  String get signatureNumerologyAdvancedTitle;

  /// No description provided for @numerologyKarmicDebtTitle.
  ///
  /// In de, this message translates to:
  /// **'Karmic Debt'**
  String get numerologyKarmicDebtTitle;

  /// No description provided for @numerologyKarmicDebtSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Karmische Schuldzahlen'**
  String get numerologyKarmicDebtSubtitle;

  /// No description provided for @numerologyChallengesTitle.
  ///
  /// In de, this message translates to:
  /// **'Challenges'**
  String get numerologyChallengesTitle;

  /// No description provided for @numerologyChallengesSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Herausforderungen'**
  String get numerologyChallengesSubtitle;

  /// No description provided for @numerologyChallengePhase.
  ///
  /// In de, this message translates to:
  /// **'Phase {number}'**
  String numerologyChallengePhase(String number);

  /// No description provided for @numerologyKarmicLessonsTitle.
  ///
  /// In de, this message translates to:
  /// **'Karmic Lessons'**
  String get numerologyKarmicLessonsTitle;

  /// No description provided for @numerologyKarmicLessonsSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Zu lernende Lektionen'**
  String get numerologyKarmicLessonsSubtitle;

  /// No description provided for @numerologyBridgesTitle.
  ///
  /// In de, this message translates to:
  /// **'Bridges'**
  String get numerologyBridgesTitle;

  /// No description provided for @numerologyBridgesSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Verbindungen'**
  String get numerologyBridgesSubtitle;

  /// No description provided for @numerologyBridgeLifepathExpression.
  ///
  /// In de, this message translates to:
  /// **'Lebensweg ↔ Ausdruck'**
  String get numerologyBridgeLifepathExpression;

  /// No description provided for @numerologyBridgeLifepathMeaning.
  ///
  /// In de, this message translates to:
  /// **'Verbinde Weg & Talent'**
  String get numerologyBridgeLifepathMeaning;

  /// No description provided for @numerologyBridgeSoulPersonality.
  ///
  /// In de, this message translates to:
  /// **'Seele ↔ Außen'**
  String get numerologyBridgeSoulPersonality;

  /// No description provided for @numerologyBridgeSoulMeaning.
  ///
  /// In de, this message translates to:
  /// **'Verbinde Innen & Außen'**
  String get numerologyBridgeSoulMeaning;

  /// No description provided for @signatureLearnMore.
  ///
  /// In de, this message translates to:
  /// **'Mehr erfahren'**
  String get signatureLearnMore;

  /// No description provided for @signatureAscendantRequired.
  ///
  /// In de, this message translates to:
  /// **'Aszendent: Geburtsort-Koordinaten erforderlich'**
  String get signatureAscendantRequired;

  /// No description provided for @baziBranchRat.
  ///
  /// In de, this message translates to:
  /// **'Ratte'**
  String get baziBranchRat;

  /// No description provided for @baziBranchOx.
  ///
  /// In de, this message translates to:
  /// **'Büffel'**
  String get baziBranchOx;

  /// No description provided for @baziBranchTiger.
  ///
  /// In de, this message translates to:
  /// **'Tiger'**
  String get baziBranchTiger;

  /// No description provided for @baziBranchRabbit.
  ///
  /// In de, this message translates to:
  /// **'Hase'**
  String get baziBranchRabbit;

  /// No description provided for @baziBranchDragon.
  ///
  /// In de, this message translates to:
  /// **'Drache'**
  String get baziBranchDragon;

  /// No description provided for @baziBranchSnake.
  ///
  /// In de, this message translates to:
  /// **'Schlange'**
  String get baziBranchSnake;

  /// No description provided for @baziBranchHorse.
  ///
  /// In de, this message translates to:
  /// **'Pferd'**
  String get baziBranchHorse;

  /// No description provided for @baziBranchGoat.
  ///
  /// In de, this message translates to:
  /// **'Ziege'**
  String get baziBranchGoat;

  /// No description provided for @baziBranchMonkey.
  ///
  /// In de, this message translates to:
  /// **'Affe'**
  String get baziBranchMonkey;

  /// No description provided for @baziBranchRooster.
  ///
  /// In de, this message translates to:
  /// **'Hahn'**
  String get baziBranchRooster;

  /// No description provided for @baziBranchDog.
  ///
  /// In de, this message translates to:
  /// **'Hund'**
  String get baziBranchDog;

  /// No description provided for @baziBranchPig.
  ///
  /// In de, this message translates to:
  /// **'Schwein'**
  String get baziBranchPig;

  /// No description provided for @numerologySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Deine Lebenszahlen'**
  String get numerologySubtitle;

  /// No description provided for @numerologyKarmicDebt13.
  ///
  /// In de, this message translates to:
  /// **'Faulheit → Disziplin lernen'**
  String get numerologyKarmicDebt13;

  /// No description provided for @numerologyKarmicDebt14.
  ///
  /// In de, this message translates to:
  /// **'Überindulgenz → Balance finden'**
  String get numerologyKarmicDebt14;

  /// No description provided for @numerologyKarmicDebt16.
  ///
  /// In de, this message translates to:
  /// **'Ego & Fall → Demut entwickeln'**
  String get numerologyKarmicDebt16;

  /// No description provided for @numerologyKarmicDebt19.
  ///
  /// In de, this message translates to:
  /// **'Machtmissbrauch → Geben lernen'**
  String get numerologyKarmicDebt19;

  /// No description provided for @numerologyKarmicDebtDefault.
  ///
  /// In de, this message translates to:
  /// **'Karmische Schuld'**
  String get numerologyKarmicDebtDefault;

  /// No description provided for @numerologyLifepath1.
  ///
  /// In de, this message translates to:
  /// **'Führung & Pioniergeist'**
  String get numerologyLifepath1;

  /// No description provided for @numerologyLifepath2.
  ///
  /// In de, this message translates to:
  /// **'Harmonie & Partnerschaft'**
  String get numerologyLifepath2;

  /// No description provided for @numerologyLifepath3.
  ///
  /// In de, this message translates to:
  /// **'Kreativität & Ausdruck'**
  String get numerologyLifepath3;

  /// No description provided for @numerologyLifepath4.
  ///
  /// In de, this message translates to:
  /// **'Stabilität & Struktur'**
  String get numerologyLifepath4;

  /// No description provided for @numerologyLifepath5.
  ///
  /// In de, this message translates to:
  /// **'Freiheit & Abenteuer'**
  String get numerologyLifepath5;

  /// No description provided for @numerologyLifepath6.
  ///
  /// In de, this message translates to:
  /// **'Fürsorge & Verantwortung'**
  String get numerologyLifepath6;

  /// No description provided for @numerologyLifepath7.
  ///
  /// In de, this message translates to:
  /// **'Weisheit & Spiritualität'**
  String get numerologyLifepath7;

  /// No description provided for @numerologyLifepath8.
  ///
  /// In de, this message translates to:
  /// **'Macht & Manifestation'**
  String get numerologyLifepath8;

  /// No description provided for @numerologyLifepath9.
  ///
  /// In de, this message translates to:
  /// **'Vollendung & Mitgefühl'**
  String get numerologyLifepath9;

  /// No description provided for @numerologyLifepath11.
  ///
  /// In de, this message translates to:
  /// **'Spiritueller Botschafter ✨'**
  String get numerologyLifepath11;

  /// No description provided for @numerologyLifepath22.
  ///
  /// In de, this message translates to:
  /// **'Meister-Manifestierer ✨'**
  String get numerologyLifepath22;

  /// No description provided for @numerologyLifepath33.
  ///
  /// In de, this message translates to:
  /// **'Meister-Heiler ✨'**
  String get numerologyLifepath33;

  /// No description provided for @tabToday.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get tabToday;

  /// No description provided for @tabMoon.
  ///
  /// In de, this message translates to:
  /// **'Mond'**
  String get tabMoon;

  /// No description provided for @tabPartner.
  ///
  /// In de, this message translates to:
  /// **'Partner'**
  String get tabPartner;

  /// No description provided for @tabProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// No description provided for @todayHoroscope.
  ///
  /// In de, this message translates to:
  /// **'Dein Tageshoroskop'**
  String get todayHoroscope;

  /// No description provided for @todayEnergy.
  ///
  /// In de, this message translates to:
  /// **'Tagesenergie'**
  String get todayEnergy;

  /// No description provided for @todayMoonPhase.
  ///
  /// In de, this message translates to:
  /// **'Mondphase'**
  String get todayMoonPhase;

  /// No description provided for @moonCalendar.
  ///
  /// In de, this message translates to:
  /// **'Mondkalender'**
  String get moonCalendar;

  /// No description provided for @moonCurrentPhase.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Phase'**
  String get moonCurrentPhase;

  /// No description provided for @moonNextFullMoon.
  ///
  /// In de, this message translates to:
  /// **'Nächster Vollmond'**
  String get moonNextFullMoon;

  /// No description provided for @moonNextNewMoon.
  ///
  /// In de, this message translates to:
  /// **'Nächster Neumond'**
  String get moonNextNewMoon;

  /// No description provided for @partnerCheckTitle.
  ///
  /// In de, this message translates to:
  /// **'Partner-Check'**
  String get partnerCheckTitle;

  /// No description provided for @partnerCheckSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Wie gut harmoniert ihr?'**
  String get partnerCheckSubtitle;

  /// No description provided for @partnerAddNew.
  ///
  /// In de, this message translates to:
  /// **'Person hinzufügen'**
  String get partnerAddNew;

  /// No description provided for @partnerBirthDate.
  ///
  /// In de, this message translates to:
  /// **'Geburtsdatum'**
  String get partnerBirthDate;

  /// No description provided for @partnerRelationship.
  ///
  /// In de, this message translates to:
  /// **'Beziehung'**
  String get partnerRelationship;

  /// No description provided for @partnerRelationshipPartner.
  ///
  /// In de, this message translates to:
  /// **'Partner/in'**
  String get partnerRelationshipPartner;

  /// No description provided for @partnerRelationshipFriend.
  ///
  /// In de, this message translates to:
  /// **'Freund/in'**
  String get partnerRelationshipFriend;

  /// No description provided for @partnerRelationshipFamily.
  ///
  /// In de, this message translates to:
  /// **'Familie'**
  String get partnerRelationshipFamily;

  /// No description provided for @partnerRelationshipColleague.
  ///
  /// In de, this message translates to:
  /// **'Kolleg/in'**
  String get partnerRelationshipColleague;

  /// No description provided for @premiumTitle.
  ///
  /// In de, this message translates to:
  /// **'Nuuray Premium'**
  String get premiumTitle;

  /// No description provided for @premiumSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Tiefere Einblicke, mehr Klarheit.'**
  String get premiumSubtitle;

  /// No description provided for @premiumFeature1.
  ///
  /// In de, this message translates to:
  /// **'Ausführliche Tages-Synthese'**
  String get premiumFeature1;

  /// No description provided for @premiumFeature2.
  ///
  /// In de, this message translates to:
  /// **'Wochen- & Monatsüberblick'**
  String get premiumFeature2;

  /// No description provided for @premiumFeature3.
  ///
  /// In de, this message translates to:
  /// **'Erweiterter Partner-Check'**
  String get premiumFeature3;

  /// No description provided for @premiumFeature4.
  ///
  /// In de, this message translates to:
  /// **'PDF-Reports'**
  String get premiumFeature4;

  /// No description provided for @premiumSubscribe.
  ///
  /// In de, this message translates to:
  /// **'Premium freischalten'**
  String get premiumSubscribe;

  /// No description provided for @premiumRestore.
  ///
  /// In de, this message translates to:
  /// **'Käufe wiederherstellen'**
  String get premiumRestore;

  /// No description provided for @weekOverview.
  ///
  /// In de, this message translates to:
  /// **'Wochenüberblick'**
  String get weekOverview;

  /// No description provided for @monthOverview.
  ///
  /// In de, this message translates to:
  /// **'Monatsüberblick'**
  String get monthOverview;

  /// No description provided for @settingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get settingsLanguage;

  /// No description provided for @settingsNotifications.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen'**
  String get settingsNotifications;

  /// No description provided for @settingsDailyReminder.
  ///
  /// In de, this message translates to:
  /// **'Tägliche Erinnerung'**
  String get settingsDailyReminder;

  /// No description provided for @settingsPrivacy.
  ///
  /// In de, this message translates to:
  /// **'Datenschutz'**
  String get settingsPrivacy;

  /// No description provided for @settingsTerms.
  ///
  /// In de, this message translates to:
  /// **'Nutzungsbedingungen'**
  String get settingsTerms;

  /// No description provided for @settingsAbout.
  ///
  /// In de, this message translates to:
  /// **'Über Nuuray'**
  String get settingsAbout;

  /// No description provided for @settingsLogout.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get settingsLogout;

  /// No description provided for @generalLoading.
  ///
  /// In de, this message translates to:
  /// **'Wird geladen...'**
  String get generalLoading;

  /// No description provided for @generalError.
  ///
  /// In de, this message translates to:
  /// **'Fehler'**
  String get generalError;

  /// No description provided for @generalRetry.
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get generalRetry;

  /// No description provided for @generalSave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get generalSave;

  /// No description provided for @generalCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get generalCancel;

  /// No description provided for @generalDone.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get generalDone;

  /// No description provided for @generalNext.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get generalNext;

  /// No description provided for @generalBack.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get generalBack;

  /// No description provided for @generalFinish.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get generalFinish;

  /// No description provided for @generalComingSoon.
  ///
  /// In de, this message translates to:
  /// **'Coming Soon!'**
  String get generalComingSoon;

  /// No description provided for @onboardingNameDisplayNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Rufname / Username *'**
  String get onboardingNameDisplayNameLabel;

  /// No description provided for @onboardingNameDisplayNameHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. Natalie'**
  String get onboardingNameDisplayNameHint;

  /// No description provided for @onboardingNameDisplayNameHelper.
  ///
  /// In de, this message translates to:
  /// **'Wie sollen wir dich nennen?'**
  String get onboardingNameDisplayNameHelper;

  /// No description provided for @onboardingNameDisplayNameRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib deinen Rufnamen ein'**
  String get onboardingNameDisplayNameRequired;

  /// No description provided for @onboardingNameFullFirstNamesLabel.
  ///
  /// In de, this message translates to:
  /// **'Vornamen lt. Geburtsurkunde (optional)'**
  String get onboardingNameFullFirstNamesLabel;

  /// No description provided for @onboardingNameFullFirstNamesHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. Natalie Frauke'**
  String get onboardingNameFullFirstNamesHint;

  /// No description provided for @onboardingNameFullFirstNamesHelper.
  ///
  /// In de, this message translates to:
  /// **'Alle Vornamen aus der Geburtsurkunde'**
  String get onboardingNameFullFirstNamesHelper;

  /// No description provided for @onboardingNameBirthNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Geburtsname (optional)'**
  String get onboardingNameBirthNameLabel;

  /// No description provided for @onboardingNameBirthNameHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. Pawlowski'**
  String get onboardingNameBirthNameHint;

  /// No description provided for @onboardingNameBirthNameHelper.
  ///
  /// In de, this message translates to:
  /// **'Nachname bei Geburt (Maiden Name)'**
  String get onboardingNameBirthNameHelper;

  /// No description provided for @onboardingNameLastNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Nachname aktuell (optional)'**
  String get onboardingNameLastNameLabel;

  /// No description provided for @onboardingNameLastNameHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. Günes'**
  String get onboardingNameLastNameHint;

  /// No description provided for @onboardingNameLastNameHelper.
  ///
  /// In de, this message translates to:
  /// **'Aktueller Nachname (falls geändert)'**
  String get onboardingNameLastNameHelper;

  /// No description provided for @onboardingNameNumerologyHint.
  ///
  /// In de, this message translates to:
  /// **'Für präzise Numerologie empfehlen wir, alle Felder auszufüllen. Besonders wichtig: Vornamen + Geburtsname zeigen deine Urenergie.'**
  String get onboardingNameNumerologyHint;

  /// No description provided for @onboardingDateLabel.
  ///
  /// In de, this message translates to:
  /// **'Geburtsdatum *'**
  String get onboardingDateLabel;

  /// No description provided for @onboardingDateSelect.
  ///
  /// In de, this message translates to:
  /// **'Datum wählen'**
  String get onboardingDateSelect;

  /// No description provided for @onboardingDateRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte wähle dein Geburtsdatum'**
  String get onboardingDateRequired;

  /// No description provided for @onboardingTimeLabel.
  ///
  /// In de, this message translates to:
  /// **'Geburtszeit (optional)'**
  String get onboardingTimeLabel;

  /// No description provided for @onboardingTimeSelect.
  ///
  /// In de, this message translates to:
  /// **'Zeit wählen'**
  String get onboardingTimeSelect;

  /// No description provided for @onboardingTimeValue.
  ///
  /// In de, this message translates to:
  /// **'{hour}:{minute} Uhr'**
  String onboardingTimeValue(String hour, String minute);

  /// No description provided for @onboardingTimeUnknown.
  ///
  /// In de, this message translates to:
  /// **'Geburtszeit ist mir nicht bekannt'**
  String get onboardingTimeUnknown;

  /// No description provided for @onboardingPlaceLabel.
  ///
  /// In de, this message translates to:
  /// **'Geburtsort (optional)'**
  String get onboardingPlaceLabel;

  /// No description provided for @onboardingPlaceHelper.
  ///
  /// In de, this message translates to:
  /// **'Für präzise Aszendent-Berechnung'**
  String get onboardingPlaceHelper;

  /// No description provided for @onboardingPlaceSearchLabel.
  ///
  /// In de, this message translates to:
  /// **'Stadt oder Ort'**
  String get onboardingPlaceSearchLabel;

  /// No description provided for @onboardingPlaceSearchHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. München, Deutschland'**
  String get onboardingPlaceSearchHint;

  /// No description provided for @onboardingPlaceSearchHelper.
  ///
  /// In de, this message translates to:
  /// **'Tippe mindestens 3 Buchstaben'**
  String get onboardingPlaceSearchHelper;

  /// No description provided for @onboardingPlaceNotFound.
  ///
  /// In de, this message translates to:
  /// **'Kein Ort gefunden. Versuche \"Stadt, Land\" (z.B. \"München, Deutschland\")'**
  String get onboardingPlaceNotFound;

  /// No description provided for @onboardingPlaceNetworkError.
  ///
  /// In de, this message translates to:
  /// **'Netzwerkfehler'**
  String get onboardingPlaceNetworkError;

  /// No description provided for @onboardingPlaceSkip.
  ///
  /// In de, this message translates to:
  /// **'Geburtsort überspringen'**
  String get onboardingPlaceSkip;

  /// No description provided for @signatureWesternTitle.
  ///
  /// In de, this message translates to:
  /// **'Western Astrology'**
  String get signatureWesternTitle;

  /// No description provided for @signatureWesternSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Deine Planetenpositionen'**
  String get signatureWesternSubtitle;

  /// No description provided for @signatureSun.
  ///
  /// In de, this message translates to:
  /// **'Sonne'**
  String get signatureSun;

  /// No description provided for @signatureMoon.
  ///
  /// In de, this message translates to:
  /// **'Mond'**
  String get signatureMoon;

  /// No description provided for @signatureAscendant.
  ///
  /// In de, this message translates to:
  /// **'Aszendent'**
  String get signatureAscendant;

  /// No description provided for @horoscopeDailyTitle.
  ///
  /// In de, this message translates to:
  /// **'Dein Tageshoroskop'**
  String get horoscopeDailyTitle;

  /// No description provided for @horoscopePersonalSection.
  ///
  /// In de, this message translates to:
  /// **'Persönlich für dich'**
  String get horoscopePersonalSection;

  /// No description provided for @horoscopeBaziCardTitle.
  ///
  /// In de, this message translates to:
  /// **'Dein Bazi heute'**
  String get horoscopeBaziCardTitle;

  /// No description provided for @horoscopeBaziCardDescription.
  ///
  /// In de, this message translates to:
  /// **'Deine einzigartige Bazi-Energie unterstützt dich heute auf besondere Weise.'**
  String get horoscopeBaziCardDescription;

  /// No description provided for @horoscopeNumerologyCardTitle.
  ///
  /// In de, this message translates to:
  /// **'Deine Numerologie'**
  String get horoscopeNumerologyCardTitle;

  /// No description provided for @horoscopeNumerologyCardDescription.
  ///
  /// In de, this message translates to:
  /// **'Deine Life Path {lifePath} bringt heute manifestierende Kraft. Perfekt für geschäftliche Entscheidungen und Ziele.'**
  String horoscopeNumerologyCardDescription(int lifePath);

  /// No description provided for @horoscopePlaceholderTitle.
  ///
  /// In de, this message translates to:
  /// **'Geburtsdaten fehlen'**
  String get horoscopePlaceholderTitle;

  /// No description provided for @horoscopePlaceholderDescription.
  ///
  /// In de, this message translates to:
  /// **'Bitte vervollständige deine Geburtsdaten, um dein persönliches Horoskop zu sehen.'**
  String get horoscopePlaceholderDescription;
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
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
