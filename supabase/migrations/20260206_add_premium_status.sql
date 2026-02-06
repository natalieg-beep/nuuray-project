-- Migration: Premium Status für User hinzufügen
-- Erstellt: 2026-02-06

-- 1. Füge Spalte subscription_tier zur profiles Tabelle hinzu (falls noch nicht vorhanden)
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS subscription_tier TEXT DEFAULT 'free'
CHECK (subscription_tier IN ('free', 'premium', 'lifetime'));

-- 2. Setze Natalie als Premium User
UPDATE profiles
SET subscription_tier = 'premium'
WHERE id = '2af05fc5-fbc0-457c-bfe3-9423d3924f31';

-- 3. Optional: Subscription Details Tabelle (für später, wenn In-App Purchases implementiert sind)
CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  subscription_tier TEXT NOT NULL CHECK (subscription_tier IN ('free', 'premium', 'lifetime')),
  platform TEXT CHECK (platform IN ('ios', 'android', 'web', 'manual')),
  product_id TEXT,
  transaction_id TEXT,
  purchase_date TIMESTAMPTZ,
  expiry_date TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 4. RLS für subscriptions Tabelle
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own subscriptions"
  ON subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- 5. Index für schnelle Subscription-Abfragen
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_active ON subscriptions(is_active) WHERE is_active = true;

-- 6. Insert für Natalie's Premium Subscription
INSERT INTO subscriptions (user_id, subscription_tier, platform, is_active)
VALUES ('2af05fc5-fbc0-457c-bfe3-9423d3924f31', 'premium', 'manual', true)
ON CONFLICT DO NOTHING;
