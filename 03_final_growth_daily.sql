DROP TABLE growth_daily;

--Add a new shopify table with bot vs. human column
CREATE TABLE growth_daily AS
    --Segment the meta and shopify data into two CTEs
    WITH meta_daily AS (
        SELECT
            TO_DATE(reporting_starts, 'YYYY-MM-DD') AS report_date,
            SUM(amount_spent_usd::NUMERIC) AS spend,
            SUM(link_clicks::INTEGER) AS meta_link_clicks,
            SUM(landing_page_views::INTEGER) AS meta_landing_page_views
        FROM staging_meta_daily
        GROUP BY TO_DATE(reporting_starts, 'YYYY-MM-DD')
    ),
    shopify_pivot AS (
        SELECT
            TO_DATE(day, 'YYYY-MM-DD') AS report_date,
            SUM(CASE WHEN session_type = 'human' THEN sessions::INTEGER ELSE 0 END) AS human_sessions,
            SUM(CASE WHEN session_type = 'bot' THEN sessions::INTEGER ELSE 0 END) AS bot_sessions,
            SUM(CASE WHEN session_type = 'human' THEN cart_additions::INTEGER ELSE 0 END) AS human_cart_adds,
            SUM(CASE WHEN session_type = 'human' THEN reached_checkout::INTEGER ELSE 0 END) AS human_reached_checkout,
            SUM(CASE WHEN session_type = 'human' THEN completed_checkout::INTEGER ELSE 0 END) AS human_completed_checkout
        FROM staging_shopify_sessions_by_type
        WHERE session_type IN ('human', 'bot')
        GROUP BY TO_DATE(day, 'YYYY-MM-DD')
    )
--Format columns
SELECT
    COALESCE(m.report_date, s.report_date) AS report_date,
    m.spend,
    m.meta_link_clicks,
    m.meta_landing_page_views,
    s.human_sessions,
    s.bot_sessions,
    ROUND(s.bot_sessions::NUMERIC / NULLIF(s.human_sessions + s.bot_sessions, 0), 4) AS bot_session_share,
    s.human_cart_adds,
    s.human_reached_checkout,
    s.human_completed_checkout,
    ROUND(m.meta_landing_page_views::NUMERIC / NULLIF(s.human_sessions::NUMERIC, 0), 2) AS meta_vs_shopify_ratio,
    ROUND(s.human_cart_adds::NUMERIC / NULLIF(s.human_sessions::NUMERIC, 0), 4) AS cart_add_rate,
    ROUND(s.human_reached_checkout::NUMERIC / NULLIF(s.human_cart_adds::NUMERIC, 0), 4) AS checkout_reach_rate,
    ROUND(s.human_completed_checkout::NUMERIC / NULLIF(s.human_reached_checkout::NUMERIC, 0), 4) AS checkout_completion_rate
FROM meta_daily m
FULL OUTER JOIN shopify_pivot s ON m.report_date = s.report_date;
