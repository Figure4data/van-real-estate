# van-real-estate

Vancouver real estate monthly market trends, from Zealty.ca MLS® market stats.
Analysis and visualization in R (Shiny app planned).

## Data

`data/vancouver_monthly.csv` is the analysis table: one row per month × region × property type.

| column | meaning |
|---|---|
| `month` | `YYYY-MM`, completed months only |
| `region` | `vancouver-city`, `vancouver-westside`, `vancouver-eastside` |
| `area` | sub-area within region (`everywhere` = whole region) |
| `property_type` | `HSE` detached house, `APT` condo, `TWN` townhouse, `all` (city only) |
| `sales` | number of sales |
| `median_price` | median sold price (CAD) |
| `median_price_sqft` | median sold price per sq ft |
| `median_dom` | median days on market |
| `discount_pct` | median % sold below asking (negative = over asking) |
| `active_inventory` | active listings |
| `new_listings` | new listings that month |
| `months_of_inventory` | inventory ÷ sales |
| `over_asking_pct` | % of sales above asking |
| `retrieved` | date of the snapshot the value came from |

Note: Westside + Eastside does not cover the whole city; Downtown is a separate region.

### How the history accumulates

- `data/raw/<retrieved-date>_<region>.json` holds one pull per region. These files
  are never edited or deleted, so history keeps growing past Zealty's 60-month window.
- `R/build_monthly.R` merges every snapshot. Where months overlap, the newest
  snapshot wins, and the script reports any months Zealty revised.

## Monthly refresh

Zealty is reached through the Zealty MCP connector in Claude (signed in), not a
script. Early each month, ask Claude: *"Run the monthly Zealty refresh"* (steps are in
`CLAUDE.md`), then:

```sh
Rscript R/build_monthly.R
```

## R environment

Packages are managed with [renv](https://rstudio.github.io/renv/). After cloning, run
`renv::restore()`. After installing new packages, run `renv::snapshot()`.

**MLS® disclosure:** anything published from this data must include Zealty's
MLS® data disclosure note.
