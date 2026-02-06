-- =============================================================================
-- NUURAY — Seed-Daten
-- Sternzeichen-Referenz und initiale Mondphasen
-- =============================================================================

-- Referenztabelle: Sternzeichen (für Lookups und Validierung)
CREATE TABLE IF NOT EXISTS public.zodiac_signs (
  key           TEXT PRIMARY KEY,
  name_de       TEXT NOT NULL,
  name_en       TEXT NOT NULL,
  symbol        TEXT NOT NULL,
  element       TEXT NOT NULL CHECK (element IN ('feuer', 'erde', 'luft', 'wasser')),
  modality      TEXT NOT NULL CHECK (modality IN ('kardinal', 'fix', 'veraenderlich')),
  date_start    TEXT NOT NULL,          -- 'MM-DD'
  date_end      TEXT NOT NULL,          -- 'MM-DD'
  sort_order    INTEGER NOT NULL
);

INSERT INTO public.zodiac_signs (key, name_de, name_en, symbol, element, modality, date_start, date_end, sort_order) VALUES
  ('aries',       'Widder',       'Aries',       '♈', 'feuer',  'kardinal',       '03-21', '04-19', 1),
  ('taurus',      'Stier',        'Taurus',      '♉', 'erde',   'fix',            '04-20', '05-20', 2),
  ('gemini',      'Zwillinge',    'Gemini',      '♊', 'luft',   'veraenderlich',  '05-21', '06-20', 3),
  ('cancer',      'Krebs',        'Cancer',      '♋', 'wasser', 'kardinal',       '06-21', '07-22', 4),
  ('leo',         'Löwe',         'Leo',         '♌', 'feuer',  'fix',            '07-23', '08-22', 5),
  ('virgo',       'Jungfrau',     'Virgo',       '♍', 'erde',   'veraenderlich',  '08-23', '09-22', 6),
  ('libra',       'Waage',        'Libra',       '♎', 'luft',   'kardinal',       '09-23', '10-22', 7),
  ('scorpio',     'Skorpion',     'Scorpio',     '♏', 'wasser', 'fix',            '10-23', '11-21', 8),
  ('sagittarius', 'Schütze',      'Sagittarius', '♐', 'feuer',  'veraenderlich',  '11-22', '12-21', 9),
  ('capricorn',   'Steinbock',    'Capricorn',   '♑', 'erde',   'kardinal',       '12-22', '01-19', 10),
  ('aquarius',    'Wassermann',   'Aquarius',    '♒', 'luft',   'fix',            '01-20', '02-18', 11),
  ('pisces',      'Fische',       'Pisces',      '♓', 'wasser', 'veraenderlich',  '02-19', '03-20', 12);

ALTER TABLE public.zodiac_signs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Alle können Sternzeichen lesen"
  ON public.zodiac_signs FOR SELECT
  USING (TRUE);


-- Referenztabelle: Bazi Heavenly Stems
CREATE TABLE IF NOT EXISTS public.bazi_stems (
  key           TEXT PRIMARY KEY,
  name_de       TEXT NOT NULL,
  name_en       TEXT NOT NULL,
  name_cn       TEXT NOT NULL,
  element       TEXT NOT NULL,
  polarity      TEXT NOT NULL CHECK (polarity IN ('yang', 'yin'))
);

INSERT INTO public.bazi_stems (key, name_de, name_en, name_cn, element, polarity) VALUES
  ('jia',  'Yang-Holz',   'Yang Wood',   '甲', 'holz',   'yang'),
  ('yi',   'Yin-Holz',    'Yin Wood',    '乙', 'holz',   'yin'),
  ('bing', 'Yang-Feuer',  'Yang Fire',   '丙', 'feuer',  'yang'),
  ('ding', 'Yin-Feuer',   'Yin Fire',    '丁', 'feuer',  'yin'),
  ('wu',   'Yang-Erde',   'Yang Earth',  '戊', 'erde',   'yang'),
  ('ji',   'Yin-Erde',    'Yin Earth',   '己', 'erde',   'yin'),
  ('geng', 'Yang-Metall', 'Yang Metal',  '庚', 'metall', 'yang'),
  ('xin',  'Yin-Metall',  'Yin Metal',   '辛', 'metall', 'yin'),
  ('ren',  'Yang-Wasser', 'Yang Water',  '壬', 'wasser', 'yang'),
  ('gui',  'Yin-Wasser',  'Yin Water',   '癸', 'wasser', 'yin');

ALTER TABLE public.bazi_stems ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Alle können Stems lesen"
  ON public.bazi_stems FOR SELECT
  USING (TRUE);


-- Referenztabelle: Bazi Earthly Branches (Tierkreiszeichen)
CREATE TABLE IF NOT EXISTS public.bazi_branches (
  key           TEXT PRIMARY KEY,
  name_de       TEXT NOT NULL,
  name_en       TEXT NOT NULL,
  name_cn       TEXT NOT NULL,
  animal_de     TEXT NOT NULL,
  animal_en     TEXT NOT NULL,
  element       TEXT NOT NULL
);

INSERT INTO public.bazi_branches (key, name_de, name_en, name_cn, animal_de, animal_en, element) VALUES
  ('zi',   'Zi',   'Zi',   '子', 'Ratte',    'Rat',     'wasser'),
  ('chou', 'Chou', 'Chou', '丑', 'Büffel',   'Ox',      'erde'),
  ('yin',  'Yin',  'Yin',  '寅', 'Tiger',    'Tiger',   'holz'),
  ('mao',  'Mao',  'Mao',  '卯', 'Hase',     'Rabbit',  'holz'),
  ('chen', 'Chen', 'Chen', '辰', 'Drache',   'Dragon',  'erde'),
  ('si',   'Si',   'Si',   '巳', 'Schlange', 'Snake',   'feuer'),
  ('wu2',  'Wu',   'Wu',   '午', 'Pferd',    'Horse',   'feuer'),
  ('wei',  'Wei',  'Wei',  '未', 'Ziege',    'Goat',    'erde'),
  ('shen', 'Shen', 'Shen', '申', 'Affe',     'Monkey',  'metall'),
  ('you',  'You',  'You',  '酉', 'Hahn',     'Rooster', 'metall'),
  ('xu',   'Xu',   'Xu',   '戌', 'Hund',     'Dog',     'erde'),
  ('hai',  'Hai',  'Hai',  '亥', 'Schwein',  'Pig',     'wasser');

ALTER TABLE public.bazi_branches ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Alle können Branches lesen"
  ON public.bazi_branches FOR SELECT
  USING (TRUE);
