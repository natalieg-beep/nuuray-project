/// NUURAY Core — Shared-Bibliothek für alle drei Apps.
///
/// Enthält: Datenmodelle, Berechnungslogik (Astrologie, Mondphasen, Numerologie),
/// und gemeinsame Utilities.
library nuuray_core;

// Models
export 'src/models/user_profile.dart';
export 'src/models/birth_chart.dart';
export 'src/models/moon_phase.dart';
export 'src/models/daily_energy.dart';
export 'src/models/zodiac_sign.dart';
export 'src/models/numerology_profile.dart';

// Services (Berechnungen)
export 'src/services/zodiac_calculator.dart';
export 'src/services/moon_phase_calculator.dart';
export 'src/services/numerology_calculator.dart';
export 'src/services/bazi_calculator.dart';
export 'src/services/daily_energy_calculator.dart';
export 'src/services/cosmic_profile_service.dart';

// Utils
export 'src/utils/date_helpers.dart';
