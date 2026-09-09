# acumen-camera-growth-analytics
A growth analytics project analyzing Meta ad spend and Shopify funnel performance for a small e-commerce business built in PostgreSQL and Tableau.
Dashboard: https://public.tableau.com/views/Feb-AugGrowthAnalysis/Dashboard1?:language=en-US&:sid=&:redirect=auth&publish=yes&showOnboarding=true&:display_count=n&:origin=viz_share_link

**Project Overview**
- This project analyzes how Meta ad activity relates to on-site traffic and conversion, and identifies where in the purchase funnel the business loses the most potential customers. It combines two independently-exported data sources — Meta Ads Manager and Shopify Analytics — into a single daily fact table, then builds funnel and traffic-quality metrics on top of it.
- No order-level attribution links Meta campaigns to individual purchases, so this analysis identifies patterns that coincide over the study period rather than proven causal effects.

**Data note**
- This repo contains schema and transformation SQL only as no raw data exports or files containing the business's actual spend/revenue figures are included to keep the underlying business data private.

**Pipeline**
- The SQL files in this repo are numbered in the order they were built, each representing a real milestone in the project rather than a cleaned-up final draft:
- _01_schema_and_staging.sql_: Database and staging table setup. Raw CSV exports are loaded as TEXT columns rather than typed on import, so a malformed value in one row doesn't break the entire load — casting happens downstream instead.
- _02_fix_campaign_fanout.sql_: First working version of the core growth_daily table. The Meta export is one row per campaign per day, while the Shopify export is one row per day; joining them directly caused every Shopify day to be duplicated once per Meta campaign active that day (including two inactive campaigns with near-zero spend). This version fixes it by aggregating Meta data to daily grain in a CTE before joining.
- _03_final_growth_daily.sql_: Final version of growth_daily, rebuilt on top of a human/bot session split rather than total sessions. Partway through the project, raw session counts appeared to show a large drop in traffic that turned out to be partly explained by bot-driven sessions, confirmed using Shopify's own human/bot session classification. Getting this version working also meant fixing smaller bugs along the way:
  1. a case-sensitivity mismatch (the data used lowercase 'human'/'bot'
  2. an earlier query checked for 'Human'/'Bot' and silently matched nothing)
  3. a differing date format between two Shopify exports (YYYY-MM-DD vs. M/D/YYYY).

**Key findings**
- Raw session counts were not a reliable traffic metric on their own as a large apparent drop in traffic was partly bot contamination
- Human-session conversion rate improved substantially over the study period which coincides with a shift toward more targeted campaign strategy.
- The largest funnel drop-off happens between a site visit and a cart addition

**Tools**
PostgreSQL: data cleaning, transformation, and modeling
Tableau: analysis and dashboard visualization
