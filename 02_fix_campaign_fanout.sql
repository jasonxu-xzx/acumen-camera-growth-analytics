DROP TABLE growth_daily;
--Revise growth_daily with the new column
CREATE TABLE growth_daily AS
    --Segment the meta and shopify data into two CTEs
    WITH meta_daily AS (
        SELECT
            --Converts the date column of both table from text string to DATE type
            TO_DATE(reporting_starts, 'YYYY-MM-DD') AS report_date,
            SUM(amount_spent_usd::NUMERIC) AS spend,
            SUM(link_clicks::INTEGER) AS meta_link_clicks,
            SUM(landing_page_views::INTEGER) AS meta_landing_page_views
        FROM staging_meta_daily
        GROUP BY TO_DATE(reporting_starts, 'YYYY-MM-DD')
    )
SELECT
    --Returns the non-null value from either meta or shopify column
    COALESCE(m.report_date, TO_DATE(s.day, 'MM/DD/YYYY')) AS report_date,
    --Casts columns into relevant data types
    m.spend,
    m.meta_link_clicks,
    m.meta_landing_page_views,
    s.sessions::INTEGER AS shopify_sessions,
    s.sessions_with_searches::INTEGER AS sessions_with_search,
    s.sessions_with_cart_additions::INTEGER AS sessions_with_cart_add,
    s.sessions_reached_checkout::INTEGER AS sessions_reached_checkout,
    s.sessions_completed_checkout::INTEGER AS sessions_completed_checkout,
    --Creates columns for each key metric
    ROUND(m.meta_landing_page_views / NULLIF(s.sessions::NUMERIC, 0), 2) AS meta_vs_shopify_ratio,
    ROUND(s.sessions_with_cart_additions::NUMERIC / NULLIF(s.sessions::NUMERIC, 0), 4) AS cart_add_rate,
    ROUND(s.sessions_reached_checkout::NUMERIC / NULLIF(s.sessions_with_cart_additions::NUMERIC, 0), 4) AS checkout_reach_rate,
    ROUND(s.sessions_completed_checkout::NUMERIC / NULLIF(s.sessions_reached_checkout::NUMERIC, 0), 4) AS checkout_completion_rate
FROM meta_daily m
--Joins the two table using the date columns
FULL JOIN staging_shopify_funnel_daily s
    ON m.report_date = TO_DATE(s.day, 'MM/DD/YYYY');
