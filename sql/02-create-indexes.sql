CREATE INDEX idx_search ON tieliikenne(valmistenumero2, kayttoonottopvm, omamassa);
CREATE INDEX idx_stats ON tieliikenne(ensirekisterointi_parsed);

CREATE TABLE IF NOT EXISTS ajoneuvodata_stats AS
  SELECT
  MIN(ensirekisterointi_parsed) AS min_date,
  MAX(ensirekisterointi_parsed) AS max_date
  FROM tieliikenne WHERE ensirekisterointipvm != "";
