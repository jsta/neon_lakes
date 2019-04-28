
The NEON documentation lists lakes among their targeted ecosystems. However, NEON has provides so much data it can be difficult to get a grasp of their lake data apart from other ecosystems. Here, I show the scope of NEON lake data and how to get scripted access to it.

## Dependencies

Before we begin, let's set up our `R` environment where the [package dependencies](https://github.com/jsta/earthengine/blob/master/environment.yml) are:

 - geoNEON
 - neonUtilities

## Walkthrough

According to the NEON documentation there are 7 NEON lake sites. We can start by mapping the location of these sites (excluding `TOOK` in Alaska):

```r
core_reloc <- data.frame(siteID = c("CRAM", "SUGG", "BARC", "TOOK", "PRPO",
                                    "LIRO", "PRLA"),
                         status = c(rep("core", 5), "relocatable", "relocatable"),
                         stringsAsFactors = FALSE)

```

NEON provides a [spreadsheet](https://data.neonscience.org/documents/10179/11206/NEON_data_product_status/f82f959f-b53c-44cc-ad2b-70303ac6ddc3) of data availability by type, site, and date. 



* Aquatic Instrument System
  * Buoy measurements
    * Atmosphere
    * Biogeochemistry
    * 
  * 

NEON lake data comes in X possible types:

 - Secchi
 - Water quality
 - Buoy
 - Biological

Consult the [NEON Data Product Catalog](https://data.neonscience.org/data-product-catalog) to find a specific product ID code. 



# Map NEON lake sites


 
# What data is available?

# Plot some data
