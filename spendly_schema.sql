-- SECTION 1: EXTENSIONS
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";   -- UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";    -- Cryptographic functions


-- =============================================================================
-- SECTION 2: CUSTOM ENUM TYPES
-- =============================================================================

-- Transaction type: income vs expense
CREATE TYPE transaction_type AS ENUM ('income', 'expense');

CREATE TYPE gender_type AS ENUM ('male', 'female');

-- How a transaction was entered by the users
CREATE TYPE input_method AS ENUM ('manual', 'voice', 'receipt_scan');

-- Savings goal lifecycle state
CREATE TYPE goal_status AS ENUM ('active', 'completed', 'cancelled');

-- Insight classification for the insights feed
CREATE TYPE insight_type AS ENUM (
    'budget_warning',          -- Approaching or exceeded monthly budget
    'budget_exceeded',         -- Monthly budget fully exceeded
    'category_limit_warning',  -- Approaching a category spending limit
    'category_limit_exceeded', -- Category limit fully exceeded
    'spending_increase',       -- Spending rose compared to previous month
    'spending_decrease',       -- Spending fell compared to previous month
    'category_comparison',     -- Category-level month-over-month comparison
    'goal_progress',           -- Savings goal milestone
    'general'                  -- Catch-all for other AI-generated insights
);


-- =============================================================================
-- SECTION 3: HELPER FUNCTION — auto-update "updated_at"
-- =============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


-- =============================================================================
-- SECTION 4: TABLE — users
-- =============================================================================
-- One row per authenticated users. Extends auth.users with app-specific fields.
-- Created automatically (or by the app) after signup.

CREATE TABLE  public.users (
    id              UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name       TEXT,
    email           TEXT NOT NULL UNIQUE,
    gender          gender_type NOT NULL DEFAULT 'male',
    currency        CHAR(3)         NOT NULL DEFAULT 'EGP',  -- ISO 4217 currency code
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  public.users               IS 'App-level users profile extending auth.users.';
COMMENT ON COLUMN public.users.id            IS 'Matches auth.users.id — 1-to-1 relationship.';
COMMENT ON COLUMN public.users.currency      IS 'ISO 4217 code, e.g. EGP, USD, EUR.';

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- =============================================================================
-- SECTION 5: TABLE — categories
-- =============================================================================
-- users-defined expense categories (Food, Transport, etc.).
-- Income transactions do NOT reference categories.

CREATE TABLE IF NOT EXISTS public.categories (
    id          UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    users_id     UUID            NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    name        TEXT            NOT NULL,
    icon        TEXT            NOT NULL,   -- Icon identifier string (e.g. Flutter icon name)
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    -- A users cannot have two categories with the same name
    CONSTRAINT uq_categories_users_name UNIQUE (users_id, name),
    CONSTRAINT uq_categories_id_user UNIQUE (id, users_id)
);

COMMENT ON TABLE  public.categories             IS 'users-defined expense categories for tagging and analysis.';

CREATE INDEX IF NOT EXISTS idx_categories_users_id ON public.categories(users_id);

CREATE TRIGGER trg_categories_updated_at
    BEFORE UPDATE ON public.categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- =============================================================================
-- SECTION 6: TABLE — transactions
-- =============================================================================
-- Core financial ledger. Stores both income and expense transactions.
-- category_id is NULL for income transactions (enforced by check constraint).

CREATE TABLE  public.transactions (
    id               UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    users_id          UUID            NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    type             transaction_type NOT NULL,
    amount           NUMERIC(15, 2)  NOT NULL CHECK (amount > 0),
    title            TEXT            NOT NULL,
    description      TEXT,
    category_id      UUID,
    transaction_date DATE            NOT NULL DEFAULT CURRENT_DATE,
    input_method     input_method    NOT NULL DEFAULT 'manual',
    created_at       TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    -- Income transactions must NOT have a category;
    -- Expense transactions MUST have a category.
    CONSTRAINT chk_transactions_category
        CHECK (
            (type = 'income'  AND category_id IS NULL) OR
            (type = 'expense' AND category_id IS NOT NULL)
        ),
    CONSTRAINT fk_transactions_category_owner FOREIGN KEY (category_id, users_id) REFERENCES public.categories(id, users_id) ON DELETE RESTRICT
);

COMMENT ON TABLE  public.transactions                  IS 'All income and expense transactions for a users.';
COMMENT ON COLUMN public.transactions.type             IS 'income or expense — drives category requirement.';
COMMENT ON COLUMN public.transactions.category_id      IS 'NULL for income; required for expense (enforced by CHECK).';
COMMENT ON COLUMN public.transactions.input_method     IS 'How the transaction was entered: manual, voice, or receipt_scan.';
COMMENT ON COLUMN public.transactions.transaction_date IS 'Logical date of the transaction (not created_at).';

-- Queries filter heavily by users + date range
CREATE INDEX IF NOT EXISTS idx_transactions_users_id          ON public.transactions(users_id);
CREATE INDEX IF NOT EXISTS idx_transactions_users_date        ON public.transactions(users_id, transaction_date DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_users_type        ON public.transactions(users_id, type);
CREATE INDEX IF NOT EXISTS idx_transactions_category_id      ON public.transactions(category_id);
-- Composite for monthly aggregations (the most common query pattern)
CREATE INDEX IF NOT EXISTS idx_transactions_users_year_month  ON public.transactions(users_id, transaction_date);

CREATE TRIGGER trg_transactions_updated_at
    BEFORE UPDATE ON public.transactions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- =============================================================================
-- SECTION 7: TABLE — monthly_budgets
-- =============================================================================
-- One global monthly spending budget per users per calendar month.
-- This is the top-level budget cap, NOT per-category.

CREATE TABLE  public.monthly_budgets (
    id             UUID           PRIMARY KEY DEFAULT uuid_generate_v4(),
    users_id        UUID           NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    budget_month   DATE           NOT NULL,   -- Always store as the 1st of the month (e.g. 2025-07-01)
    amount         NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
    created_at     TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ    NOT NULL DEFAULT NOW(),

    -- Only one budget row per users per month
    CONSTRAINT uq_monthly_budgets_users_month UNIQUE (users_id, budget_month)
);

COMMENT ON TABLE  public.monthly_budgets             IS 'One global monthly budget per users. Used for budget vs spend analysis.';
COMMENT ON COLUMN public.monthly_budgets.budget_month IS 'Normalized to the first day of the month (YYYY-MM-01).';

CREATE INDEX IF NOT EXISTS idx_monthly_budgets_users_id    ON public.monthly_budgets(users_id);
CREATE INDEX IF NOT EXISTS idx_monthly_budgets_users_month ON public.monthly_budgets(users_id, budget_month DESC);

CREATE TRIGGER trg_monthly_budgets_updated_at
    BEFORE UPDATE ON public.monthly_budgets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- =============================================================================
-- SECTION 8: TABLE — category_limits
-- =============================================================================
-- Optional per-category spending warning limits.
-- These are for TRACKING / WARNINGS only — not hard caps.
-- A users may set a Food limit of 1000 EGP inside a 5000 EGP monthly budget.

CREATE TABLE  public.category_limits (
    id             UUID           PRIMARY KEY DEFAULT uuid_generate_v4(),
    users_id        UUID           NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    category_id    UUID           NOT NULL REFERENCES public.categories(id) ON DELETE CASCADE,
    limit_month    DATE           NOT NULL,   -- Normalized to 1st of month
    amount         NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
    created_at     TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ    NOT NULL DEFAULT NOW(),

    -- One limit per category per users per month
    CONSTRAINT uq_category_limits_users_cat_month UNIQUE (users_id, category_id, limit_month)
);

COMMENT ON TABLE  public.category_limits             IS 'Optional per-category monthly spending warning limits.';
COMMENT ON COLUMN public.category_limits.limit_month IS 'Normalized to the first day of the month (YYYY-MM-01).';
COMMENT ON COLUMN public.category_limits.amount      IS 'Soft warning threshold — not a hard transaction block.';

CREATE INDEX IF NOT EXISTS idx_category_limits_users_id    ON public.category_limits(users_id);
CREATE INDEX IF NOT EXISTS idx_category_limits_category   ON public.category_limits(category_id);
CREATE INDEX IF NOT EXISTS idx_category_limits_users_month ON public.category_limits(users_id, limit_month DESC);

CREATE TRIGGER trg_category_limits_updated_at
    BEFORE UPDATE ON public.category_limits
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- =============================================================================
-- SECTION 9: TABLE — goals
-- =============================================================================
-- Savings goals with progress tracking.

CREATE TABLE  public.goals (
    id              UUID           PRIMARY KEY DEFAULT uuid_generate_v4(),
    users_id         UUID           NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title           TEXT           NOT NULL,
    description     TEXT,
    icon            TEXT           NOT NULL,   -- Flutter icon name
    target_amount   NUMERIC(15, 2) NOT NULL CHECK (target_amount > 0),
    current_amount  NUMERIC(15, 2) NOT NULL DEFAULT 0 CHECK (current_amount >= 0),
    target_date     DATE,                      -- Optional deadline
    status          goal_status    NOT NULL DEFAULT 'active',
    created_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW(),

    -- current_amount cannot exceed target_amount (prevents overshoot)
    CONSTRAINT chk_goals_amount CHECK (current_amount <= target_amount)
);

COMMENT ON TABLE  public.goals                IS 'Savings goals with lifecycle tracking.';
COMMENT ON COLUMN public.goals.icon           IS 'Flutter icon identifier shown in Goal UI.';
COMMENT ON COLUMN public.goals.current_amount IS 'Manually updated by users contributions; cannot exceed target_amount.';
COMMENT ON COLUMN public.goals.target_date    IS 'Optional deadline; NULL means open-ended.';

CREATE INDEX IF NOT EXISTS idx_goals_users_id ON public.goals(users_id);
CREATE INDEX IF NOT EXISTS idx_goals_status  ON public.goals(users_id, status);

CREATE TRIGGER trg_goals_updated_at
    BEFORE UPDATE ON public.goals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- =============================================================================
-- SECTION 10: TABLE — insights
-- =============================================================================
-- AI / analysis-generated spending insights surfaced in the Insights tab.
-- Generated server-side (Edge Function + Gemini) and stored here for retrieval.

CREATE TABLE  public.insights (
    id           UUID           PRIMARY KEY DEFAULT uuid_generate_v4(),
    users_id      UUID           NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    type         insight_type   NOT NULL,
    title        TEXT           NOT NULL,
    body         TEXT           NOT NULL,
    category_id  UUID           REFERENCES public.categories(id) ON DELETE SET NULL, -- Optional category link
    insight_month DATE,                    -- The month this insight refers to (YYYY-MM-01)
    is_read      BOOLEAN        NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  public.insights              IS 'Spending insights generated by Gemini AI or server-side analysis.';
COMMENT ON COLUMN public.insights.type         IS 'Classifies the insight for UI rendering and filtering.';
COMMENT ON COLUMN public.insights.category_id  IS 'NULL for global insights; set for category-specific ones.';
COMMENT ON COLUMN public.insights.insight_month IS 'Calendar month the insight relates to (YYYY-MM-01).';
COMMENT ON COLUMN public.insights.is_read      IS 'False until the users opens/dismisses the insight card.';

CREATE INDEX IF NOT EXISTS idx_insights_users_id     ON public.insights(users_id);
CREATE INDEX IF NOT EXISTS idx_insights_users_unread ON public.insights(users_id, is_read) WHERE is_read = FALSE;
CREATE INDEX IF NOT EXISTS idx_insights_users_month  ON public.insights(users_id, insight_month DESC);
CREATE INDEX IF NOT EXISTS idx_insights_category    ON public.insights(category_id);

CREATE TRIGGER trg_insights_updated_at
    BEFORE UPDATE ON public.insights
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- =============================================================================
-- SECTION 11: ROW LEVEL SECURITY — Enable on all users tables
-- =============================================================================

ALTER TABLE public.users        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.monthly_budgets  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.category_limits  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.goals            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.insights         ENABLE ROW LEVEL SECURITY;


-- =============================================================================
-- SECTION 12: RLS POLICIES — users
-- =============================================================================

CREATE POLICY "users: select own"
    ON public.users FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "users: insert own"
    ON public.users FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "users: update own"
    ON public.users FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

CREATE POLICY "users: delete own"
    ON public.users FOR DELETE
    USING (auth.uid() = id);


-- =============================================================================
-- SECTION 13: RLS POLICIES — categories
-- =============================================================================

CREATE POLICY "categories: select own"
    ON public.categories FOR SELECT
    USING (auth.uid() = users_id);

CREATE POLICY "categories: insert own"
    ON public.categories FOR INSERT
    WITH CHECK (auth.uid() = users_id);

CREATE POLICY "categories: update own"
    ON public.categories FOR UPDATE
    USING (auth.uid() = users_id)
    WITH CHECK (auth.uid() = users_id);

CREATE POLICY "categories: delete own"
    ON public.categories FOR DELETE
    USING (auth.uid() = users_id);


-- =============================================================================
-- SECTION 14: RLS POLICIES — transactions
-- =============================================================================

CREATE POLICY "transactions: select own"
    ON public.transactions FOR SELECT
    USING (auth.uid() = users_id);

CREATE POLICY "transactions: insert own"
    ON public.transactions FOR INSERT
    WITH CHECK (auth.uid() = users_id);

CREATE POLICY "transactions: update own"
    ON public.transactions FOR UPDATE
    USING (auth.uid() = users_id)
    WITH CHECK (auth.uid() = users_id);

CREATE POLICY "transactions: delete own"
    ON public.transactions FOR DELETE
    USING (auth.uid() = users_id);


-- =============================================================================
-- SECTION 15: RLS POLICIES — monthly_budgets
-- =============================================================================

CREATE POLICY "monthly_budgets: select own"
    ON public.monthly_budgets FOR SELECT
    USING (auth.uid() = users_id);

CREATE POLICY "monthly_budgets: insert own"
    ON public.monthly_budgets FOR INSERT
    WITH CHECK (auth.uid() = users_id);

CREATE POLICY "monthly_budgets: update own"
    ON public.monthly_budgets FOR UPDATE
    USING (auth.uid() = users_id)
    WITH CHECK (auth.uid() = users_id);

CREATE POLICY "monthly_budgets: delete own"
    ON public.monthly_budgets FOR DELETE
    USING (auth.uid() = users_id);


-- =============================================================================
-- SECTION 16: RLS POLICIES — category_limits
-- =============================================================================

CREATE POLICY "category_limits: select own"
    ON public.category_limits FOR SELECT
    USING (auth.uid() = users_id);

CREATE POLICY "category_limits: insert own"
    ON public.category_limits FOR INSERT
    WITH CHECK (auth.uid() = users_id);

CREATE POLICY "category_limits: update own"
    ON public.category_limits FOR UPDATE
    USING (auth.uid() = users_id)
    WITH CHECK (auth.uid() = users_id);

CREATE POLICY "category_limits: delete own"
    ON public.category_limits FOR DELETE
    USING (auth.uid() = users_id);


-- =============================================================================
-- SECTION 17: RLS POLICIES — goals
-- =============================================================================

CREATE POLICY "goals: select own"
    ON public.goals FOR SELECT
    USING (auth.uid() = users_id);

CREATE POLICY "goals: insert own"
    ON public.goals FOR INSERT
    WITH CHECK (auth.uid() = users_id);

CREATE POLICY "goals: update own"
    ON public.goals FOR UPDATE
    USING (auth.uid() = users_id)
    WITH CHECK (auth.uid() = users_id);

CREATE POLICY "goals: delete own"
    ON public.goals FOR DELETE
    USING (auth.uid() = users_id);


-- =============================================================================
-- SECTION 18: RLS POLICIES — insights
-- =============================================================================

CREATE POLICY "insights: select own"
    ON public.insights FOR SELECT
    USING (auth.uid() = users_id);

CREATE POLICY "insights: insert own"
    ON public.insights FOR INSERT
    WITH CHECK (auth.uid() = users_id);

CREATE POLICY "insights: update own"
    ON public.insights FOR UPDATE
    USING (auth.uid() = users_id)
    WITH CHECK (auth.uid() = users_id);

CREATE POLICY "insights: delete own"
    ON public.insights FOR DELETE
    USING (auth.uid() = users_id);


-- =============================================================================
-- SECTION 19: OPTIONAL — Auto-create profile on signup
-- =============================================================================
-- Supabase Edge Function or this DB trigger creates the users row
-- automatically when a new users signs up via auth.users.

CREATE OR REPLACE FUNCTION public.handle_new_users()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.users (id, email, full_name, currency)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
        'EGP'
    );
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_on_auth_users_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_users();


-- =============================================================================
-- SECTION 20: USEFUL VIEWS (read-only, no RLS needed — relies on base table RLS)
-- =============================================================================

-- Monthly expense summary per category — powers the Insights and Track tabs
CREATE OR REPLACE VIEW public.v_monthly_category_spending AS
SELECT
    t.users_id,
    DATE_TRUNC('month', t.transaction_date)::DATE AS spending_month,
    t.category_id,
    c.name   AS category_name,
    c.icon   AS category_icon,
    SUM(t.amount)   AS total_spent,
    COUNT(t.id)     AS transaction_count
FROM public.transactions t
JOIN public.categories c ON c.id = t.category_id
WHERE t.type = 'expense'
GROUP BY t.users_id, spending_month, t.category_id, c.name, c.icon;

COMMENT ON VIEW public.v_monthly_category_spending IS
    'Pre-aggregated monthly spend per category. Used by Insights and Track tab.';

-- Monthly totals (income vs expense) — powers home screen and budget comparison
CREATE OR REPLACE VIEW public.v_monthly_totals AS
SELECT
    users_id,
    DATE_TRUNC('month', transaction_date)::DATE AS spending_month,
    SUM(CASE WHEN type = 'income'  THEN amount ELSE 0 END) AS total_income,
    SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) AS total_expenses,
    SUM(CASE WHEN type = 'income'  THEN amount ELSE 0 END) -
    SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) AS net_balance
FROM public.transactions
GROUP BY users_id, spending_month;

COMMENT ON VIEW public.v_monthly_totals IS
    'Monthly income vs expense totals per users. Used for budget analysis.';


-- =============================================================================
-- SECTION 21: TABLE — reports
-- =============================================================================
-- Pre-generated monthly financial snapshot for one user.
-- One report represents ONE calendar month for ONE user.
-- Reports are analytical snapshots: totals are stored at generation time
-- and remain immutable — they do NOT update if transactions are edited later.
-- Category-level breakdown is stored in the companion report_category_breakdown
-- table (see Section 22) to preserve full relational integrity.

CREATE TABLE  public.reports (
    id                  UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    users_id            UUID            NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,

    -- The calendar month this report covers (always normalized to YYYY-MM-01)
    report_month        DATE            NOT NULL,

    -- Pre-computed totals captured at generation time (immutable snapshot)
    total_income        NUMERIC(15, 2)  NOT NULL DEFAULT 0 CHECK (total_income  >= 0),
    total_expenses      NUMERIC(15, 2)  NOT NULL DEFAULT 0 CHECK (total_expenses >= 0),
    net_balance         NUMERIC(15, 2)  NOT NULL DEFAULT 0,

    -- Transaction counts for dashboard display
    income_count        INTEGER         NOT NULL DEFAULT 0 CHECK (income_count  >= 0),
    expense_count       INTEGER         NOT NULL DEFAULT 0 CHECK (expense_count >= 0),

    -- Optional AI-generated narrative (populated by Edge Function + Gemini)

    -- Tracks whether the Gemini summary has been generated yet

    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    -- net_balance must equal total_income minus total_expenses
    CONSTRAINT chk_reports_net_balance
        CHECK (net_balance = total_income - total_expenses),

    -- Only one report per user per month
    CONSTRAINT uq_reports_users_month
        UNIQUE (users_id, report_month)
);

COMMENT ON TABLE  public.reports                    IS 'Pre-generated monthly financial snapshots. Totals are immutable at generation time.';
COMMENT ON COLUMN public.reports.report_month       IS 'Normalized to the first day of the month (YYYY-MM-01). Matches budget_month convention.';
COMMENT ON COLUMN public.reports.total_income       IS 'Sum of all income transactions for the month at generation time.';
COMMENT ON COLUMN public.reports.total_expenses     IS 'Sum of all expense transactions for the month at generation time.';
COMMENT ON COLUMN public.reports.net_balance        IS 'total_income - total_expenses. Enforced by CHECK constraint.';
COMMENT ON COLUMN public.reports.income_count       IS 'Number of income transactions in the month.';
COMMENT ON COLUMN public.reports.expense_count      IS 'Number of expense transactions in the month.';

-- Primary access pattern: user fetching their own reports by month
CREATE INDEX IF NOT EXISTS idx_reports_users_id
    ON public.reports(users_id);

CREATE INDEX IF NOT EXISTS idx_reports_users_month
    ON public.reports(users_id, report_month DESC);


CREATE TRIGGER trg_reports_updated_at
    BEFORE UPDATE ON public.reports
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- =============================================================================
-- SECTION 22: TABLE — report_category_breakdown
-- =============================================================================
-- Relational category-level spending detail for each report.
-- One row per category that had expenses in the report's month.
-- Deliberately relational (not JSONB) to:
--   1. Preserve FK integrity with public.categories
--   2. Enable per-category analytics queries and indexing
--   3. Stay consistent with the fully relational schema philosophy
--   4. Allow RLS to propagate naturally via users_id
-- Uses the same composite FK pattern as transactions (category_id + users_id)
-- to guarantee a user cannot reference another user's category.

CREATE TABLE  public.report_category_breakdown (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id       UUID            NOT NULL REFERENCES public.reports(id) ON DELETE CASCADE,
    users_id        UUID            NOT NULL REFERENCES public.users(id)   ON DELETE CASCADE,
    category_id     UUID            NOT NULL,

    -- Snapshot of category metadata at generation time
    -- Stored here so the report remains accurate even if the category is renamed/deleted
    category_name   TEXT            NOT NULL,
    category_icon   TEXT            NOT NULL,

    -- Pre-computed totals for this category within the report month
    total_spent     NUMERIC(15, 2)  NOT NULL DEFAULT 0 CHECK (total_spent >= 0),
    transaction_count INTEGER       NOT NULL DEFAULT 0 CHECK (transaction_count >= 0),

    -- Percentage of total monthly expenses (0.00–100.00)
    expense_share   NUMERIC(5, 2)   NOT NULL DEFAULT 0
                        CHECK (expense_share >= 0 AND expense_share <= 100),

    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    -- One row per category per report
    CONSTRAINT uq_report_category_breakdown_report_cat
        UNIQUE (report_id, category_id),

    -- Composite FK ensures category belongs to the same user (mirrors transactions pattern)
    CONSTRAINT fk_report_category_breakdown_category_owner
        FOREIGN KEY (category_id, users_id)
        REFERENCES public.categories(id, users_id)
        ON DELETE RESTRICT
);

COMMENT ON TABLE  public.report_category_breakdown                  IS 'Per-category spending breakdown rows for each monthly report. Relational — not JSONB.';
COMMENT ON COLUMN public.report_category_breakdown.report_id        IS 'FK to reports. Cascade-deleted when the parent report is deleted.';
COMMENT ON COLUMN public.report_category_breakdown.users_id         IS 'Denormalized for RLS enforcement and composite FK validation.';
COMMENT ON COLUMN public.report_category_breakdown.category_id      IS 'FK to categories. RESTRICT prevents deletion of a category referenced by a report.';
COMMENT ON COLUMN public.report_category_breakdown.category_name    IS 'Snapshot of category name at report generation time — survives category renames.';
COMMENT ON COLUMN public.report_category_breakdown.category_icon    IS 'Snapshot of category icon at report generation time.';
COMMENT ON COLUMN public.report_category_breakdown.total_spent      IS 'Sum of expenses in this category for the report month.';
COMMENT ON COLUMN public.report_category_breakdown.transaction_count IS 'Number of expense transactions in this category for the month.';
COMMENT ON COLUMN public.report_category_breakdown.expense_share    IS 'Percentage of total monthly expenses attributed to this category (0–100).';

-- Primary lookup: all breakdown rows for a given report
CREATE INDEX IF NOT EXISTS idx_report_category_breakdown_report_id
    ON public.report_category_breakdown(report_id);

-- Supports per-user, per-category analytics across months
CREATE INDEX IF NOT EXISTS idx_report_category_breakdown_users_id
    ON public.report_category_breakdown(users_id);

CREATE INDEX IF NOT EXISTS idx_report_category_breakdown_users_cat
    ON public.report_category_breakdown(users_id, category_id);

CREATE TRIGGER trg_report_category_breakdown_updated_at
    BEFORE UPDATE ON public.report_category_breakdown
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- =============================================================================
-- SECTION 23: ROW LEVEL SECURITY — reports & report_category_breakdown
-- =============================================================================

ALTER TABLE public.reports                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.report_category_breakdown ENABLE ROW LEVEL SECURITY;


-- =============================================================================
-- SECTION 24: RLS POLICIES — reports
-- =============================================================================

CREATE POLICY "reports: select own"
    ON public.reports FOR SELECT
    USING (auth.uid() = users_id);

CREATE POLICY "reports: insert own"
    ON public.reports FOR INSERT
    WITH CHECK (auth.uid() = users_id);

CREATE POLICY "reports: update own"
    ON public.reports FOR UPDATE
    USING    (auth.uid() = users_id)
    WITH CHECK (auth.uid() = users_id);

CREATE POLICY "reports: delete own"
    ON public.reports FOR DELETE
    USING (auth.uid() = users_id);


-- =============================================================================
-- SECTION 25: RLS POLICIES — report_category_breakdown
-- =============================================================================

CREATE POLICY "report_category_breakdown: select own"
    ON public.report_category_breakdown FOR SELECT
    USING (auth.uid() = users_id);

CREATE POLICY "report_category_breakdown: insert own"
    ON public.report_category_breakdown FOR INSERT
    WITH CHECK (auth.uid() = users_id);

CREATE POLICY "report_category_breakdown: update own"
    ON public.report_category_breakdown FOR UPDATE
    USING    (auth.uid() = users_id)
    WITH CHECK (auth.uid() = users_id);

CREATE POLICY "report_category_breakdown: delete own"
    ON public.report_category_breakdown FOR DELETE
    USING (auth.uid() = users_id);


-- =============================================================================
-- SECTION 26: VIEW — v_report_full
-- =============================================================================
-- Joins reports with their category breakdown rows into a single denormalized
-- result set. Powers the Report Detail screen in the app without requiring
-- the client to issue two separate queries.
-- Inherits RLS from both base tables — no additional policies needed.

CREATE OR REPLACE VIEW public.v_report_full AS
SELECT
    r.id                                AS report_id,
    r.users_id,
    r.report_month,
    r.total_income,
    r.total_expenses,
    r.net_balance,
    r.income_count,
    r.expense_count,
    r.created_at                        AS report_created_at,

    -- Category breakdown columns (NULL when a report has no expense rows yet)
    rcb.id                              AS breakdown_id,
    rcb.category_id,
    rcb.category_name,
    rcb.category_icon,
    rcb.total_spent,
    rcb.transaction_count               AS category_transaction_count,
    rcb.expense_share
FROM public.reports r
LEFT JOIN public.report_category_breakdown rcb
       ON rcb.report_id = r.id
      AND rcb.users_id  = r.users_id;

COMMENT ON VIEW public.v_report_full IS
    'Denormalized report + category breakdown join. Powers the Report Detail screen. RLS inherited from base tables.';