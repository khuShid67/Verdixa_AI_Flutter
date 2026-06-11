class AppText {
  static const Map<String, Map<String, String>> _values = {
    // ================= ENGLISH =================
    'en': {
      // Settings
      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',
      'light': 'Light Mode',
      'dark': 'Dark Mode',
      'system': 'System Default',

      // Home
      'choose_image': 'Choose Image',
      'analyze': 'Analyze',
      'select_image': 'Select a leaf image',
      'no_server': 'Failed to connect to server',
      'analyzing': 'Analyzing...',

      // Result
      'analysis_result': 'Analysis Result',
      'status': 'Status',
      'confidence': 'Confidence',
      'similar_diseases': 'Similar Diseases',
      'disease_details': 'Disease Details',
      'unknown_disease': 'Unknown Disease',

      // Disease Sections
      'description': 'Description',
      'symptoms': 'Symptoms',
      'organic_treatment': 'Organic Treatment',
      'chemical_treatment': 'Chemical Treatment',
      'prevention': 'Prevention',
      'severity': 'Severity',
      'condition': 'Condition',
    },

    // ================= HINDI =================
    'hi': {
      // Settings
      'settings': 'सेटिंग्स',
      'theme': 'थीम',
      'language': 'भाषा',
      'light': 'लाइट मोड',
      'dark': 'डार्क मोड',
      'system': 'सिस्टम डिफ़ॉल्ट',

      // Home
      'choose_image': 'छवि चुनें',
      'analyze': 'विश्लेषण करें',
      'select_image': 'पत्ती की छवि चुनें',
      'no_server': 'सर्वर से कनेक्ट नहीं हो पाया',
      'analyzing': 'विश्लेषण हो रहा है...',

      // Result
      'analysis_result': 'विश्लेषण परिणाम',
      'status': 'स्थिति',
      'confidence': 'विश्वास स्तर',
      'similar_diseases': 'समान रोग',
      'disease_details': 'रोग विवरण',
      'unknown_disease': 'अज्ञात रोग',

      // Disease Sections
      'description': 'विवरण',
      'symptoms': 'लक्षण',
      'organic_treatment': 'जैविक उपचार',
      'chemical_treatment': 'रासायनिक उपचार',
      'prevention': 'रोकथाम',
      'severity': 'गंभीरता',
      'condition': 'स्थिति',
    },

    // ================= GUJARATI =================
    'gu': {
      // Settings
      'settings': 'સેટિંગ્સ',
      'theme': 'થીમ',
      'language': 'ભાષા',
      'light': 'લાઇટ મોડ',
      'dark': 'ડાર્ક મોડ',
      'system': 'સિસ્ટમ ડિફૉલ્ટ',

      // Home
      'choose_image': 'છબી પસંદ કરો',
      'analyze': 'વિશ્લેષણ કરો',
      'select_image': 'પાનની છબી પસંદ કરો',
      'no_server': 'સર્વર સાથે કનેક્ટ થઈ શક્યું નથી',
      'analyzing': 'વિશ્લેષણ થઈ રહ્યું છે...',

      // Result
      'analysis_result': 'વિશ્લેષણ પરિણામ',
      'status': 'સ્થિતિ',
      'confidence': 'વિશ્વાસ સ્તર',
      'similar_diseases': 'સમાન રોગો',
      'disease_details': 'રોગની વિગતો',
      'unknown_disease': 'અજ્ઞાત રોગ',

      // Disease Sections
      'description': 'વર્ણન',
      'symptoms': 'લક્ષણો',
      'organic_treatment': 'જૈવિક સારવાર',
      'chemical_treatment': 'રાસાયણિક સારવાર',
      'prevention': 'બચાવ',
      'severity': 'તીવ્રતા',
      'condition': 'સ્થિતિ',
    },
  };

  static String get(String key, String lang) {
    return _values[lang]?[key] ??
        _values['en']?[key] ??
        key;
  }
}