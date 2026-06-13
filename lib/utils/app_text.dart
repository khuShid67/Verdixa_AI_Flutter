class AppText {
  static const Map<String, Map<String, String>> _values = {
    'en': {
      'home_description': 'Upload a leaf image and get instant AI detection',
      'tap_to_scan': 'Tap to Scan',
      'use_camera_gallery': 'Use camera or gallery',
      'analyze_disease': 'Analyze Disease',

      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',

      'my_scans': 'My Scans',
      'no_scans': 'No scans yet',
      'confidence': 'Confidence',

      'analysis_result': 'Analysis Result',
      'status': 'Status',
      'confidence_label': 'Confidence',
    },

    'hi': {
      'home_description': 'लीफ इमेज अपलोड करें और तुरंत AI डिटेक्शन पाएं',
      'tap_to_scan': 'स्कैन करें',
      'use_camera_gallery': 'कैमरा या गैलरी का उपयोग करें',
      'analyze_disease': 'विश्लेषण करें',

      'settings': 'सेटिंग्स',
      'theme': 'थीम',
      'language': 'भाषा',

      'my_scans': 'मेरे स्कैन',
      'no_scans': 'कोई स्कैन नहीं',
      'confidence': 'विश्वास स्तर',

      'analysis_result': 'विश्लेषण परिणाम',
      'status': 'स्थिति',
      'confidence_label': 'विश्वास',
    },

    'gu': {
      'home_description': 'પાનની છબી અપલોડ કરો અને AI શોધ મેળવો',
      'tap_to_scan': 'સ્કેન કરો',
      'use_camera_gallery': 'કેમેરા અથવા ગેલેરી',
      'analyze_disease': 'વિશ્લેષણ કરો',

      'settings': 'સેટિંગ્સ',
      'theme': 'થીમ',
      'language': 'ભાષા',

      'my_scans': 'મારા સ્કેન',
      'no_scans': 'કોઈ સ્કેન નથી',
      'confidence': 'વિશ્વાસ',

      'analysis_result': 'પરિણામ',
      'status': 'સ્થિતિ',
      'confidence_label': 'વિશ્વાસ સ્તર',
    },
  };

  static String of(BuildContext context, String key) {
    final lang = Localizations.localeOf(context).languageCode;
    return _values[lang]?[key] ??
        _values['en']?[key] ??
        key;
  }
}