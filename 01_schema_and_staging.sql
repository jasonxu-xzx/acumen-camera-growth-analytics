-- create the database
CREATE DATABASE acumen_camera

-- create separate table for meta and shopify exports to match the .csv files downloaded
CREATE TABLE staging_meta_daily (
    report_date          TEXT,
    campaign_name        TEXT,
    amount_spent_usd     TEXT,
    impressions          TEXT,
    link_clicks          TEXT,
    ctr                  TEXT,
    landing_page_views   TEXT
);

CREATE TABLE staging_shopify_funnel_daily (
    day                          TEXT,
    sessions                     TEXT,
    sessions_with_searches       TEXT,
    sessions_with_cart_additions TEXT,
    sessions_reached_checkout    TEXT,
    sessions_completed_checkout  TEXT
);
