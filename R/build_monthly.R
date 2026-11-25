# Build data/vancouver_monthly.csv from every Zealty snapshot in data/raw/.
#
# Each snapshot file is one pull of one region (all property types), named
# <retrieved-date>_<region>.json. Snapshots are never edited or deleted, so the
# history keeps growing. Where snapshots overlap, the most recently retrieved
# value wins (Zealty can revise recent months as late sales get reported).
#
# Run from the project root:  Rscript R/build_monthly.R

library(jsonlite)

metrics <- c(
  "sales", "median_price", "median_price_sqft", "median_dom", "discount_pct",
  "active_inventory", "new_listings", "months_of_inventory", "over_asking_pct"
)

read_snapshot <- function(path) {
  cap <- fromJSON(path, simplifyVector = TRUE)
  rows <- lapply(names(cap$series), function(ptype) {
    s <- cap$series[[ptype]]
    n <- length(s$sales)
    missing <- setdiff(metrics, names(s))
    if (length(missing)) stop(basename(path), " ", ptype, ": missing ", toString(missing))
    bad <- metrics[lengths(s[metrics]) != n]
    if (length(bad)) stop(basename(path), " ", ptype, ": length mismatch in ", toString(bad))
    months <- format(seq(as.Date(paste0(cap$start_month, "-01")), by = "month", length.out = n), "%Y-%m")
    if (months[n] != cap$end_month) {
      stop(basename(path), " ", ptype, ": ", n, " values end at ", months[n], ", expected ", cap$end_month)
    }
    data.frame(
      month = months, region = cap$region, area = cap$area, property_type = ptype,
      as.data.frame(s[metrics]), retrieved = cap$retrieved, source_file = basename(path)
    )
  })
  do.call(rbind, rows)
}

files <- list.files("data/raw", pattern = "\\.json$", full.names = TRUE)
if (!length(files)) stop("No snapshots in data/raw/ (run from the project root)")
all_rows <- do.call(rbind, lapply(files, read_snapshot))

# Newest snapshot first, then keep the first row per region/area/type/month.
all_rows <- all_rows[order(all_rows$retrieved, all_rows$source_file, decreasing = TRUE), ]
key <- paste(all_rows$region, all_rows$area, all_rows$property_type, all_rows$month)
latest <- all_rows[!duplicated(key), ]

# Report revisions: older values that differ from the value now kept.
older <- all_rows[duplicated(key), ]
if (nrow(older)) {
  kept <- latest[match(paste(older$region, older$area, older$property_type, older$month),
                       paste(latest$region, latest$area, latest$property_type, latest$month)), ]
  changed <- rowSums(older[metrics] != kept[metrics], na.rm = TRUE) > 0
  if (any(changed)) {
    message(sum(changed), " month(s) revised by newer snapshots, e.g.:")
    print(head(older[changed, c("region", "property_type", "month", "retrieved")]), row.names = FALSE)
  }
}

latest <- latest[order(latest$region, latest$area, latest$property_type, latest$month), ]
latest$source_file <- NULL
write.csv(latest, "data/vancouver_monthly.csv", row.names = FALSE)

message("Wrote ", nrow(latest), " rows to data/vancouver_monthly.csv")
print(aggregate(month ~ region + property_type, latest,
                function(m) paste(min(m), "to", max(m), sprintf("(%d)", length(m)))),
      row.names = FALSE)
