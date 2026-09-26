import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AppLocale state provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  static const String _prefKey = 'selected_locale';

  LocaleNotifier() : super(const Locale('bn')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_prefKey);
    if (savedCode != null && (savedCode == 'bn' || savedCode == 'en')) {
      state = Locale(savedCode);
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (state == newLocale) return;
    state = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, newLocale.languageCode);
  }

  void toggleLocale() {
    if (state.languageCode == 'bn') {
      setLocale(const Locale('en'));
    } else {
      setLocale(const Locale('bn'));
    }
  }
}

/// AppLocalizations handles UI text translations for Bengali and English.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('bn'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isBn => locale.languageCode == 'bn';

  // Helper string retriever
  String text(String key) {
    final map = isBn ? _bnValues : _enValues;
    return map[key] ?? key;
  }

  // Common UI Strings
  String get appName => 'Amar Kushtia';
  String get appTagline => isBn
      ? 'কুষ্টিয়ার তথ্য, সেবা ও ঐতিহ্য — এক ঠিকানায়'
      : 'Information, Services & Heritage of Kushtia';

  // Navigation
  String get navHome => isBn ? 'হোম' : 'Home';
  String get navDirectory => isBn ? 'ডিরেক্টরি' : 'Directory';
  String get navMap => isBn ? 'মানচিত্র' : 'Map';
  String get navEmergency => isBn ? 'জরুরি' : 'Emergency';
  String get navMore => isBn ? 'আরও' : 'More';

  // Search
  String get searchPlaceholder =>
      isBn ? 'কী খুঁজছেন? (হাসপাতাল, থানা, ট্রেন...)' : 'What are you looking for?';
  String get searchTitle => isBn ? 'অনুসন্ধান' : 'Search';
  String get searchHistory => isBn ? 'সাম্প্রতিক অনুসন্ধান' : 'Recent Searches';
  String get searchNoResults =>
      isBn ? 'কোনো তথ্য পাওয়া যায়নি।' : 'No information found.';

  // Categories
  String get catEmergency => isBn ? 'জরুরি সেবা' : 'Emergency';
  String get catHealthcare => isBn ? 'স্বাস্থ্যসেবা' : 'Healthcare';
  String get catPolice => isBn ? 'পুলিশ' : 'Police';
  String get catFire => isBn ? 'ফায়ার সার্ভিস' : 'Fire Service';
  String get catTransport => isBn ? 'রেলওয়ে ও ট্রেন সেবা' : 'Railway & Trains';
  String get catTourism => isBn ? 'দর্শনীয় স্থান' : 'Tourism';
  String get catHeritage => isBn ? 'ঐতিহ্য ও সংস্কৃতি' : 'Heritage';
  String get catGovernment => isBn ? 'সরকারি দপ্তর' : 'Government';
  String get catEducation => isBn ? 'শিক্ষা প্রতিষ্ঠান' : 'Education';
  String get catFood => isBn ? 'বিখ্যাত খাবার (জিআই)' : 'GI Food';
  String get catCraft => isBn ? 'হস্তশিল্প (জিআই)' : 'GI Crafts';
  String get catAll => isBn ? 'সকল বিভাগ' : 'All Categories';

  // Upazilas
  String get upazilasTitle => isBn ? 'কুষ্টিয়ার উপজেলাসমূহ' : 'Upazilas of Kushtia';
  String get allUpazilas => isBn ? 'সকল উপজেলা' : 'All Upazilas';
  String get kushtiaSadar => isBn ? 'কুষ্টিয়া সদর' : 'Kushtia Sadar';
  String get kumarkhali => isBn ? 'কুমারখালী' : 'Kumarkhali';
  String get khoksa => isBn ? 'খোকসা' : 'Khoksa';
  String get bheramara => isBn ? 'ভেড়ামারা' : 'Bheramara';
  String get daulatpur => isBn ? 'দৌলতপুর' : 'Daulatpur';
  String get mirpur => isBn ? 'মিরপুর' : 'Mirpur';

  // Actions
  String get callNow => isBn ? 'কল করুন' : 'Call Now';
  String get getDirections => isBn ? 'দিকনির্দেশনা' : 'Directions';
  String get viewDetails => isBn ? 'বিস্তারিত দেখুন' : 'View Details';
  String get share => isBn ? 'শেয়ার' : 'Share';
  String get retry => isBn ? 'আবার চেষ্টা করুন' : 'Retry';
  String get filter => isBn ? 'ফিল্টার' : 'Filter';
  String get clear => isBn ? 'মুছে ফেলুন' : 'Clear';
  String get viewOnMap => isBn ? 'ম্যাপে দেখুন' : 'View on Map';

  // Verification Status
  String get verified => isBn ? 'যাচাইকৃত' : 'Verified';
  String get partiallyVerified => isBn ? 'আংশিক যাচাইকৃত' : 'Partially Verified';
  String get needsVerification => isBn ? 'যাচাইকরণ প্রয়োজন' : 'Needs Verification';

  // Messages & States
  String get offlineMessage =>
      isBn ? 'অফলাইন ডেটা দেখানো হচ্ছে' : 'Showing offline data';
  String get loading => isBn ? 'লোড হচ্ছে...' : 'Loading...';
  String get networkError =>
      isBn ? 'ইন্টারনেট সংযোগ পাওয়া যাচ্ছে না।' : 'Internet connection unavailable.';
  String get emptyCategory => isBn
      ? 'এই বিভাগে বর্তমানে কোনো তথ্য পাওয়া যায়নি।'
      : 'No information is currently available in this category.';

  // Admin CMS
  String get adminTitle => isBn ? 'অ্যাডমিন প্যানেল' : 'Admin Panel';
  String get adminLogin => isBn ? 'অ্যাডমিন লগইন' : 'Admin Login';
  String get email => isBn ? 'ইমেইল' : 'Email';
  String get password => isBn ? 'পাসওয়ার্ড' : 'Password';
  String get login => isBn ? 'প্রবেশ করুন' : 'Sign In';
  String get logout => isBn ? 'লগআউট' : 'Sign Out';
  String get addRecord => isBn ? 'নতুন রেকর্ড যোগ করুন' : 'Add New Record';
  String get editRecord => isBn ? 'রেকর্ড সম্পাদনা' : 'Edit Record';
  String get publish => isBn ? 'পাবলিশ করুন' : 'Publish';
  String get unpublish => isBn ? 'আনপাবলিশ' : 'Unpublish';
  String get saveDraft => isBn ? 'ড্রাফট হিসেবে রাখুন' : 'Save Draft';
  String get delete => isBn ? 'মুছে ফেলুন' : 'Delete';
  String get totalRecords => isBn ? 'মোট রেকর্ড' : 'Total Records';
  String get publishedRecords => isBn ? 'প্রকাশিত' : 'Published';
  String get draftRecords => isBn ? 'খসড়া' : 'Drafts';

  // Dictionaries
  static const Map<String, String> _bnValues = {
    'emergency_title': 'জরুরি যোগাযোগ',
    'emergency_desc': 'জরুরি পরিস্থিতিতে দ্রুত যোগাযোগের নম্বরসমূহ',
    'healthcare_title': 'স্বাস্থ্য ও চিকিৎসা',
    'hospital_250_bed': 'কুষ্টিয়া ২৫০ শয্যা জেনারেল হাসপাতাল',
    'train_timetable': 'ট্রেন সময়সূচি',
    'sms_tracking': 'এসএমএস ট্রেন ট্র্যাকিং',
    'ambulance_calc': 'অ্যাম্বুলেন্স ভাড়া ক্যালকুলেটর',
    'bed_cabin_fees': 'বেড ও কেবিন ফি',
    'surgery_schedule': 'সার্জারি সময়সূচি ও ফি',
    'iu_halls': 'ইসলামী বিশ্ববিদ্যালয় আবাসিক হল',
    'national_hotlines': 'জাতীয় হটলাইন',
    'announcements': 'জরুরি বিজ্ঞপ্তি',
    'about_app': 'অ্যাপ সম্পর্কে',
    'version': 'সংস্করণ',
  };

  static const Map<String, String> _enValues = {
    'emergency_title': 'Emergency Contacts',
    'emergency_desc': 'Critical numbers for immediate emergency response',
    'healthcare_title': 'Healthcare & Medical',
    'hospital_250_bed': 'Kushtia 250-bed General Hospital',
    'train_timetable': 'Train Timetable',
    'sms_tracking': 'SMS Train Tracking',
    'ambulance_calc': 'Ambulance Fare Calculator',
    'bed_cabin_fees': 'Bed & Cabin Fees',
    'surgery_schedule': 'Surgery Schedule & Fees',
    'iu_halls': 'Islamic University Halls',
    'national_hotlines': 'National Hotlines',
    'announcements': 'Public Announcements',
    'about_app': 'About App',
    'version': 'Version',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['bn', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
