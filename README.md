
Download, Extract, and Transform Wikipedia Pagecount Dumps
==========================================================

**Status**

<a href="https://travis-ci.org/petermeissner/wikipediadumps"> <img src="https://api.travis-ci.org/petermeissner/wikipediadumps.svg?branch=master"> <a/> <a href="https://cran.r-project.org/package=wikipediadumps"> <img src="http://www.r-pkg.org/badges/version/wikipediadumps"> </a> <img src="http://cranlogs.r-pkg.org/badges/grand-total/wikipediadumps"> <img src="http://cranlogs.r-pkg.org/badges/wikipediadumps">

*lines of R code:* 267, *lines of test code:* 0

**Version**

0.1.1.90000 ( 2017-08-18 10:27:06 )

**Description**

This package is is a worker to download, extract and transform Wikipedia pagecount dumps.

**License**

GPL (&gt;= 2) <br>Peter Meissner \[aut, cre\]

**Citation**

``` r
citation("wikipediadumps")
```

**BibTex for citing**

``` r
toBibtex(citation("wikipediadumps"))
```

**Installation**

Latest development version from Github:

``` r
devtools::install_github("petermeissner/wikipediadumps")
```

Usage
=====

Get dumps
---------

``` r
# load package
library(wikipediadumps)

# set directory to use
wpd_options(directory="~/wikipediadumps")

get_dumps("200802")
```

``` r
# get dumps for one day
flist <-
  list.files(
    wpd_options()$directory,
    pattern = "-20071231.*\\.gz$",
    full.names = TRUE
  )

# extract data from gz files into save it in separated by languages
system.time({
  res <-
   do.call(
     rbind,
     filter_dumps_to_file(
       flist = flist[1],
       wiki =
         c("en","ceb", "sv", "de", "nl",
           "fr", "ru", "it", "es")
         # c("en","ceb", "sv", "de", "nl",
         #   "fr", "ru", "it", "es",
         #   "pl", "vi", "ja",
         #   "zh", "pt", "ar", "tr",
         #   "id", "fa", "simple",
         #   "ko", "ro", "no", "cs",
         #   "uk", "hu", "fi", "he", "da",
         #   "th", "hi", "ca", "el", "bg",
         #   "sr", "ms","hr","sl","sk","az",
         #   "eo","ta","lt","sh","et","la",
         #   "ka","nn","gl","eu","be","kk",
         #   "ur","hy","uz","zh-min-nan",
         #   "vo","ce","min"
         #  )
      )
   )
})
```
