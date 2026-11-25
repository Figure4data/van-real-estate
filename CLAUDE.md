# van-real-estate

R project (renv). The user analyses mainly in R / Shiny. Python is welcome where it is the
better tool, but only via a project `.venv` made from Homebrew Python
(`/opt/homebrew/bin/python3.12 -m venv .venv`). Never use Anaconda (`/opt/anaconda3/...`),
which may be first on PATH in editor terminals.

## Monthly Zealty refresh

When asked to refresh the data:

1. For each region `vancouver-city`, `vancouver-westside`, `vancouver-eastside`, call
   Zealty `get_market_stats` with `months: 6` for property types `HSE`, `APT`, `TWN`
   (plus `all` for `vancouver-city` only). Six months overlaps earlier snapshots so
   that revisions get picked up.
2. Write one file per region: `data/raw/<today YYYY-MM-DD>_<region>.json`. Use the
   same schema as the existing files (`retrieved`, `region`, `area`, `start_month`,
   `end_month`, and `series.<TYPE>.<metric>` arrays in month order). Map Zealty fields:
   salesData.sales → sales, priceData.price → median_price,
   pricePerSqFtData.pricePerSqFt → median_price_sqft, domData.dom → median_dom,
   discountRateData.discount → discount_pct, inventoryData.inventory → active_inventory,
   inventoryData.new → new_listings, monthsOfInventoryData.months → months_of_inventory,
   overAskingData.overAskingPct → over_asking_pct.
3. Never edit or delete existing raw snapshots.
4. Run `Rscript R/build_monthly.R` and confirm that every series reaches the new month.
5. Sanity check: for `HSE`, city sales ≈ westside + eastside sales (city exceeds
   them by 0–3, because a few detached homes are downtown).
6. Report what changed, including any revisions the build script listed.
