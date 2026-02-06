import 'package:equatable/equatable.dart';

/// Repräsentiert ein Sternzeichen mit allen relevanten Metadaten.
///
/// Wird sowohl für westliche Sonnenzeichen als auch für Mondzeichen verwendet.
enum ZodiacElement { feuer, erde, luft, wasser }

enum ZodiacModality { kardinal, fix, veraenderlich }

class ZodiacSign extends Equatable {
  final String key;
  final String nameDe;
  final String nameEn;
  final String symbol;
  final ZodiacElement element;
  final ZodiacModality modality;
  final int startMonth;
  final int startDay;
  final int endMonth;
  final int endDay;
  final int sortOrder;

  const ZodiacSign({
    required this.key,
    required this.nameDe,
    required this.nameEn,
    required this.symbol,
    required this.element,
    required this.modality,
    required this.startMonth,
    required this.startDay,
    required this.endMonth,
    required this.endDay,
    required this.sortOrder,
  });

  /// Gibt den lokalisierten Namen zurück.
  String name(String locale) => locale == 'de' ? nameDe : nameEn;

  @override
  List<Object?> get props => [key];

  @override
  String toString() => 'ZodiacSign($key)';

  /// Alle 12 Sternzeichen.
  static const List<ZodiacSign> all = [
    ZodiacSign(key: 'aries', nameDe: 'Widder', nameEn: 'Aries', symbol: '♈', element: ZodiacElement.feuer, modality: ZodiacModality.kardinal, startMonth: 3, startDay: 21, endMonth: 4, endDay: 19, sortOrder: 1),
    ZodiacSign(key: 'taurus', nameDe: 'Stier', nameEn: 'Taurus', symbol: '♉', element: ZodiacElement.erde, modality: ZodiacModality.fix, startMonth: 4, startDay: 20, endMonth: 5, endDay: 20, sortOrder: 2),
    ZodiacSign(key: 'gemini', nameDe: 'Zwillinge', nameEn: 'Gemini', symbol: '♊', element: ZodiacElement.luft, modality: ZodiacModality.veraenderlich, startMonth: 5, startDay: 21, endMonth: 6, endDay: 20, sortOrder: 3),
    ZodiacSign(key: 'cancer', nameDe: 'Krebs', nameEn: 'Cancer', symbol: '♋', element: ZodiacElement.wasser, modality: ZodiacModality.kardinal, startMonth: 6, startDay: 21, endMonth: 7, endDay: 22, sortOrder: 4),
    ZodiacSign(key: 'leo', nameDe: 'Löwe', nameEn: 'Leo', symbol: '♌', element: ZodiacElement.feuer, modality: ZodiacModality.fix, startMonth: 7, startDay: 23, endMonth: 8, endDay: 22, sortOrder: 5),
    ZodiacSign(key: 'virgo', nameDe: 'Jungfrau', nameEn: 'Virgo', symbol: '♍', element: ZodiacElement.erde, modality: ZodiacModality.veraenderlich, startMonth: 8, startDay: 23, endMonth: 9, endDay: 22, sortOrder: 6),
    ZodiacSign(key: 'libra', nameDe: 'Waage', nameEn: 'Libra', symbol: '♎', element: ZodiacElement.luft, modality: ZodiacModality.kardinal, startMonth: 9, startDay: 23, endMonth: 10, endDay: 22, sortOrder: 7),
    ZodiacSign(key: 'scorpio', nameDe: 'Skorpion', nameEn: 'Scorpio', symbol: '♏', element: ZodiacElement.wasser, modality: ZodiacModality.fix, startMonth: 10, startDay: 23, endMonth: 11, endDay: 21, sortOrder: 8),
    ZodiacSign(key: 'sagittarius', nameDe: 'Schütze', nameEn: 'Sagittarius', symbol: '♐', element: ZodiacElement.feuer, modality: ZodiacModality.veraenderlich, startMonth: 11, startDay: 22, endMonth: 12, endDay: 21, sortOrder: 9),
    ZodiacSign(key: 'capricorn', nameDe: 'Steinbock', nameEn: 'Capricorn', symbol: '♑', element: ZodiacElement.erde, modality: ZodiacModality.kardinal, startMonth: 12, startDay: 22, endMonth: 1, endDay: 19, sortOrder: 10),
    ZodiacSign(key: 'aquarius', nameDe: 'Wassermann', nameEn: 'Aquarius', symbol: '♒', element: ZodiacElement.luft, modality: ZodiacModality.fix, startMonth: 1, startDay: 20, endMonth: 2, endDay: 18, sortOrder: 11),
    ZodiacSign(key: 'pisces', nameDe: 'Fische', nameEn: 'Pisces', symbol: '♓', element: ZodiacElement.wasser, modality: ZodiacModality.veraenderlich, startMonth: 2, startDay: 19, endMonth: 3, endDay: 20, sortOrder: 12),
  ];

  /// Findet das Sternzeichen für ein Geburtsdatum.
  static ZodiacSign fromDate(DateTime date) {
    final month = date.month;
    final day = date.day;

    for (final sign in all) {
      if (sign.startMonth == sign.endMonth) {
        if (month == sign.startMonth && day >= sign.startDay && day <= sign.endDay) {
          return sign;
        }
      } else if (sign.startMonth < sign.endMonth) {
        if ((month == sign.startMonth && day >= sign.startDay) ||
            (month == sign.endMonth && day <= sign.endDay)) {
          return sign;
        }
      } else {
        // Steinbock: Dezember → Januar
        if ((month == sign.startMonth && day >= sign.startDay) ||
            (month == sign.endMonth && day <= sign.endDay)) {
          return sign;
        }
      }
    }

    // Fallback (sollte nie passieren)
    return all.first;
  }

  /// Findet ein Sternzeichen anhand des Keys.
  static ZodiacSign fromKey(String key) {
    return all.firstWhere(
      (s) => s.key == key,
      orElse: () => throw ArgumentError('Unbekanntes Sternzeichen: $key'),
    );
  }
}
