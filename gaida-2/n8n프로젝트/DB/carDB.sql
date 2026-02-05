

--260129_2nd QUERY
-- =========================================================
-- Car Rights Risk + Valuation MVP schema (clean rebuild)
-- =========================================================
BEGIN;
-- -------------------------
-- 0) DROP (dependency order)
-- -------------------------
DROP TABLE IF EXISTS field_evidence CASCADE;
DROP TABLE IF EXISTS document_chunks CASCADE;
DROP TABLE IF EXISTS final_valuation CASCADE;
DROP TABLE IF EXISTS risk_analysis CASCADE;
DROP TABLE IF EXISTS jobs CASCADE;
DROP TABLE IF EXISTS document_text CASCADE;
DROP TABLE IF EXISTS car_documents CASCADE;
DROP TABLE IF EXISTS price_baseline CASCADE;
-- -------------------------
-- 1) car_documents
-- -------------------------
CREATE TABLE car_documents (
  doc_id            BIGSERIAL PRIMARY KEY,
  car_number        VARCHAR(30),                 -- NOT NULL 제거(너가 ALTER 했던 의도 반영)
  model_year        INT,
  first_reg_date    DATE,
  source_file_url   TEXT,
  raw_json_output   JSONB NOT NULL DEFAULT '{}'::jsonb,   -- Upstage 원시 결과(원본 보관)
  parsing_status    VARCHAR(20) NOT NULL DEFAULT 'pending', -- pending/success/fail
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT car_documents_parsing_status_chk
    CHECK (parsing_status IN ('pending','success','fail'))
);
CREATE INDEX idx_car_documents_car_number
  ON car_documents (car_number);
CREATE INDEX idx_car_documents_parsing_status
  ON car_documents (parsing_status);
-- -------------------------
-- 2) document_text (OCR/Full text 원문)
-- -------------------------
CREATE TABLE document_text (
  doc_id       BIGINT PRIMARY KEY REFERENCES car_documents(doc_id) ON DELETE CASCADE,
  raw_text     TEXT NOT NULL DEFAULT '',
  meta         JSONB NOT NULL DEFAULT '{}'::jsonb,  -- page/confidence/blocks 등
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- -------------------------
-- 3) jobs (workflow run 추적)
-- -------------------------
CREATE TABLE jobs (
  job_id        BIGSERIAL PRIMARY KEY,
  doc_id        BIGINT NOT NULL REFERENCES car_documents(doc_id) ON DELETE CASCADE,
  status        VARCHAR(20) NOT NULL DEFAULT 'running', -- running/success/fail
  started_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  finished_at   TIMESTAMPTZ,
  error_stage   VARCHAR(50),
  error         JSONB NOT NULL DEFAULT '{}'::jsonb
);
CREATE INDEX idx_jobs_doc_id ON jobs (doc_id);
CREATE INDEX idx_jobs_status ON jobs (status);
CREATE INDEX idx_jobs_started_at ON jobs (started_at DESC);
-- -------------------------
-- 4) risk_analysis (권리 리스크 결과)
-- -------------------------
CREATE TABLE risk_analysis (
  analysis_id          BIGSERIAL PRIMARY KEY,
  doc_id               BIGINT NOT NULL REFERENCES car_documents(doc_id) ON DELETE CASCADE,
  job_id               BIGINT NOT NULL REFERENCES jobs(job_id) ON DELETE CASCADE,
  extracted            JSONB NOT NULL DEFAULT '{}'::jsonb,   -- LLM 추출 결과 통째로
  owner_change_count   INT,
  mortgage_count       INT,
  usage_history        JSONB NOT NULL DEFAULT '[]'::jsonb,
  risk_score           INT,
  risk_comment         TEXT,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_risk_analysis_doc_id ON risk_analysis (doc_id);
CREATE INDEX idx_risk_analysis_job_id ON risk_analysis (job_id);
-- -------------------------
-- 5) final_valuation (시세/안전매수가/리포트)
-- -------------------------
CREATE TABLE final_valuation (
  valuation_id             BIGSERIAL PRIMARY KEY,
  doc_id                   BIGINT NOT NULL REFERENCES car_documents(doc_id) ON DELETE CASCADE,
  job_id                   BIGINT NOT NULL REFERENCES jobs(job_id) ON DELETE CASCADE,
  calculated_market_price  NUMERIC(14,2),
  safe_purchase_price      NUMERIC(14,2),
  breakdown                JSONB NOT NULL DEFAULT '[]'::jsonb, -- 감가/가산 근거
  inputs                   JSONB NOT NULL DEFAULT '{}'::jsonb, -- 계산 입력 스냅샷(강추)
  report_summary           TEXT,
  report_body              TEXT,
  generated_at             TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_final_valuation_doc_id ON final_valuation (doc_id);
CREATE INDEX idx_final_valuation_job_id ON final_valuation (job_id);
CREATE INDEX idx_final_valuation_generated_at ON final_valuation (generated_at DESC);
-- -------------------------
-- 6) document_chunks (RAG/벡터스토어 동기화)
-- -------------------------
CREATE TABLE document_chunks (
  chunk_id        BIGSERIAL PRIMARY KEY,
  doc_id          BIGINT NOT NULL REFERENCES car_documents(doc_id) ON DELETE CASCADE,
  chunk_no        INT NOT NULL DEFAULT 0,
  page_no         INT,
  section         VARCHAR(20) NOT NULL DEFAULT 'unknown', -- 갑부/을부/unknown
  chunk_text      TEXT NOT NULL,
  pinecone_id     VARCHAR(200),
  meta            JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (doc_id, chunk_no)
);
CREATE INDEX idx_document_chunks_doc_section ON document_chunks (doc_id, section);
CREATE INDEX idx_document_chunks_doc_page ON document_chunks (doc_id, page_no);
CREATE INDEX idx_document_chunks_pinecone_id ON document_chunks (pinecone_id);
-- -------------------------
-- 7) field_evidence (필드별 근거)
-- -------------------------
CREATE TABLE field_evidence (
  evidence_id     BIGSERIAL PRIMARY KEY,
  doc_id          BIGINT NOT NULL REFERENCES car_documents(doc_id) ON DELETE CASCADE,
  job_id          BIGINT REFERENCES jobs(job_id) ON DELETE SET NULL,
  field_name      VARCHAR(100) NOT NULL,
  quote           TEXT NOT NULL,
  chunk_id        BIGINT REFERENCES document_chunks(chunk_id) ON DELETE SET NULL,
  pinecone_id     VARCHAR(200),
  page_no         INT,
  start_idx       INT,
  end_idx         INT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_field_evidence_doc_field ON field_evidence (doc_id, field_name);
CREATE INDEX idx_field_evidence_job ON field_evidence (job_id);
-- -------------------------
-- 8) price_baseline (정규화된 기준가 마스터: 너가 마지막에 만든 스키마 채택)
-- -------------------------
CREATE TABLE price_baseline (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  maker VARCHAR(100),
  model_name VARCHAR(255),
  model_name_sub1 VARCHAR(255),
  model_name_sub2 VARCHAR(255),
  form_code VARCHAR(100),
  base_price INTEGER,
  origin VARCHAR(50),
  category VARCHAR(50),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_price_baseline_model_name ON price_baseline (model_name);
CREATE INDEX idx_price_baseline_form_code  ON price_baseline (form_code);
CREATE INDEX idx_price_baseline_maker      ON price_baseline (maker);
COMMIT;
ALTER TABLE price_baseline
ADD COLUMN model_name_search text
GENERATED ALWAYS AS (
  lower(
    regexp_replace(
      coalesce(model_name, ''),
      '[^가-힣a-zA-Z0-9]',
      '',
      'g'
    )
  )
) STORED;
CREATE INDEX idx_price_baseline_model_name_search
ON price_baseline (model_name_search);



TRUNCATE TABLE price_baseline RESTART IDENTITY;

COPY price_baseline(maker, model_name, model_name_sub1, model_name_sub2, form_code, base_price, origin, category)
FROM '/tmp/data.csv' 
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');


SELECT * FROM price_baseline;


