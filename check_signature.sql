SELECT 
  id,
  display_name,
  signature_text,
  LENGTH(signature_text) as text_length,
  created_at,
  updated_at
FROM profiles 
WHERE email = 'natalie.guenes.tr@gmail.com'
LIMIT 1;
