import 'dart:convert';
import 'package:flutter/services.dart';

class GameData {
  static Map<String, dynamic> _loadedDatabases = {};

  static Future<void> init() async {
    try {
      final enString = await rootBundle.loadString('assets/data/locales/english.json');
      final frString = await rootBundle.loadString('assets/data/locales/french.json');
      final rwString = await rootBundle.loadString('assets/data/locales/kinyarwanda.json');
      final esString = await rootBundle.loadString('assets/data/locales/spanish.json');

      _loadedDatabases['en'] = jsonDecode(enString);
      _loadedDatabases['fr'] = jsonDecode(frString);
      _loadedDatabases['rw'] = jsonDecode(rwString);
      _loadedDatabases['es'] = jsonDecode(esString);

      print("SUCCESS: JSON databases loaded. Keys found in EN: ${_loadedDatabases['en']?.keys.toList()}");
    } catch (e) {
      print("CRITICAL ERROR loading JSON databases: $e");
    }
  }

  static const Map<String, List<String>> _coupleTruthExtras = {
    'en': [
      'Dear {name}, what important need have you found hardest to explain to {partner}, and what would help you say it now?',
      'Dear {name}, what recurring conflict with {partner} do you think you both avoid instead of resolving?',
      'Dear {name}, when have you felt least understood by {partner}, and what did you wish they had asked?',
      'Dear {name}, what boundary would you like to make clearer with {partner} so you both feel safer and closer?',
      'Dear {name}, what apology do you still owe {partner}, even if you are uncomfortable giving it?',
      'Dear {name}, what fear about your future together do you rarely admit to {partner}?',
      'Dear {name}, what is one way you have changed in this relationship that you want {partner} to notice?',
      'Dear {name}, what difficult but fair question would you like {partner} to answer honestly tonight?',
    ],
    'fr': [
      'Cher {name}, quel besoin important as-tu eu le plus de mal à expliquer à {partner}, et qu’est-ce qui t’aiderait à le dire maintenant ?',
      'Cher {name}, quel conflit récurrent avec {partner} évitez-vous de résoudre tous les deux ?',
      'Cher {name}, quand t’es-tu senti le moins compris par {partner}, et quelle question aurais-tu aimé entendre ?',
      'Cher {name}, quelle limite aimerais-tu clarifier avec {partner} pour que vous vous sentiez plus en sécurité et plus proches ?',
      'Cher {name}, quelles excuses dois-tu encore à {partner}, même si cela te met mal à l’aise ?',
      'Cher {name}, quelle crainte concernant votre avenir ensemble avoues-tu rarement à {partner} ?',
      'Cher {name}, quel changement en toi dans cette relation aimerais-tu que {partner} remarque ?',
      'Cher {name}, quelle question difficile mais juste aimerais-tu poser à {partner} pour obtenir une réponse honnête ce soir ?',
    ],
    'es': [
      'Querido {name}, ¿qué necesidad importante te ha costado más explicarle a {partner}, y qué te ayudaría a expresarla ahora?',
      'Querido {name}, ¿qué conflicto recurrente con {partner} creen que ambos evitan resolver?',
      'Querido {name}, ¿cuándo te has sentido menos comprendido por {partner}, y qué te habría gustado que te preguntara?',
      'Querido {name}, ¿qué límite te gustaría aclarar con {partner} para que ambos se sientan más seguros y unidos?',
      'Querido {name}, ¿qué disculpa todavía le debes a {partner}, aunque te resulte incómodo ofrecerla?',
      'Querido {name}, ¿qué temor sobre su futuro juntos casi nunca le confiesas a {partner}?',
      'Querido {name}, ¿qué cambio en ti durante esta relación quisieras que {partner} notara?',
      'Querido {name}, ¿qué pregunta difícil pero justa te gustaría que {partner} respondiera con sinceridad esta noche?',
    ],
    'rw': [
      'Mukundwa {name}, ni ikihe kintu cy’ingenzi cyakugoye gusobanurira {partner}, kandi ni iki cyagufasha kukivuga ubu?',
      'Mukundwa {name}, ni ikihe kibazo gihoraho hagati yawe na {partner} mwembi mwirinda gukemura?',
      'Mukundwa {name}, ni ryari wumvise ko {partner} atakumva, kandi ni iki wari kwifuza ko akubaza?',
      'Mukundwa {name}, ni uwuhe mupaka wifuza gusobanurira neza {partner} kugira ngo mwembi mwumve mutekanye kandi murushijeho kwegerana?',
      'Mukundwa {name}, ni ikihe kintu ugomba gusabira {partner} imbabazi nubwo bikugora?',
      'Mukundwa {name}, ni ikihe gihangayikishije ku hazaza hanyu mutarabana ukunze guhisha {partner}?',
      'Mukundwa {name}, ni ikihe kintu wahinduye muri iyi mibanire wifuza ko {partner} abona?',
      'Mukundwa {name}, ni ikihe kibazo gikomeye ariko kiboneye wifuza ko {partner} agusubiza ukuri muri iri joro?',
    ],
  };

  /// Returns templates for the requested category. Wild & Extreme combines
  /// the existing Wild and Extreme decks. Couple Mode gets extra, deeper
  /// conversation prompts in every supported language.
  static List<String> getQuestions(String lang, String category, String type) {
    final langData = _loadedDatabases[lang];
    if (langData == null) {
      print("DEBUG: Language '$lang' not found in cache. Using fallbacks.");
      return _getFallbackQuestions(type);
    }

    final requested = category.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    final isWildExtreme = requested.contains('wild') || requested.contains('extreme');
    final isCouple = requested.contains('couple');
    final matchingCategories = <String>[];

    for (final dynamic rawKey in langData.keys) {
      final key = rawKey.toString();
      final normalizedKey = key.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
      final matches = isWildExtreme
          ? normalizedKey == 'wild' || normalizedKey == 'extreme'
          : isCouple
              ? normalizedKey.contains('couple')
              : normalizedKey == requested ||
                  normalizedKey.contains(requested) ||
                  requested.contains(normalizedKey);
      if (matches) matchingCategories.add(key);
    }

    if (matchingCategories.isEmpty) {
      print("DEBUG: Category '$category' not found in lang '$lang'. Available: ${langData.keys}");
      return _getFallbackQuestions(type);
    }

    final questions = <String>[];
    for (final categoryKey in matchingCategories) {
      final categoryData = langData[categoryKey];
      if (categoryData is! Map) continue;

      String? matchedTypeKey;
      for (final dynamic rawKey in categoryData.keys) {
        final key = rawKey.toString();
        if (key.toLowerCase().contains(type.toLowerCase()) ||
            type.toLowerCase().contains(key.toLowerCase())) {
          matchedTypeKey = key;
          break;
        }
      }

      final rawList = matchedTypeKey == null ? null : categoryData[matchedTypeKey];
      if (rawList is List) {
        questions.addAll(rawList.map((question) => question.toString()));
      }
    }

    if (isCouple && type.toLowerCase() == 'truth') {
      questions.addAll(_coupleTruthExtras[lang] ?? _coupleTruthExtras['en']!);
    }
    return questions.isEmpty ? _getFallbackQuestions(type) : questions;
  }

  /// Emergency templates still use the same runtime placeholder pipeline.
  static List<String> _getFallbackQuestions(String type) {
    if (type.toLowerCase().contains('truth')) {
      return [
        'Dear {name}, what is your biggest secret?',
        'Dear {name}, what do you secretly love most about {partner}?',
        'Dear {name}, what was your most embarrassing moment with {other_player}?',
      ];
    }

    return [
      'Dear {name}, give {partner} a friendly compliment.',
      'Dear {name}, share a fun secret with {other_player}.',
      'Dear {name}, imitate your favorite celebrity right now.',
    ];
  }
}
