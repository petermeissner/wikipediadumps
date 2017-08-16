

#' get links for dump downloads
#'
#' @param directory path to store dump_links.txt file
#' @param force force re-downloading and re-extracting dump links
#'
#' @export
#'
get_dump_links <- function(force = FALSE, directory = NULL ){

  # check if links should be read/write to disk cache file or not
  if( is.null(directory) ){
    directory <- wpd_options()$directory
  }

  if( !is.null(directory) ){
    dump_links_path <- paste0(directory,"/dump_links.txt")
  }else{
    dump_links_path <- NULL
  }


  if( force == FALSE && file.exists(dump_links_path) ){
    wpd_cache$dump_links <- readLines(dump_links_path)
  }

  if( force == TRUE || is.null(wpd_cache$dump_links) ){
    # some baseline variables
    base_url    <- "https://dumps.wikimedia.org/other/pagecounts-raw"
    year_range  <- 2007:substring(as.character(Sys.Date()), 1,4)
    month_range <- 1:12

    # as data.frame
    df <- expand.grid(year = year_range, month = month_range)
    df$yearmonth <-
      paste0(
        df$year,
        stringr::str_pad(
          string = df$month,
          width  = 2,
          side   = "left",
          pad    = "0"
        )
      )
    df <-
      df[df$yearmonth >= "200712" & df$yearmonth <= "201608",] %>%
      dplyr::arrange_(
        "yearmonth"
      )


    # get index urls
    RES <- list()
    for(url in unique(paste0(base_url, "/", df$year)) ){
      RES[[ length(RES)+1 ]] <-
        tryCatch(
          expr  = xml2::read_html(url),
          error = function(e){xml2::read_html("<html></html>")}
        ) %>%
        xml2::xml_find_all("//a/@href") %>%
        lapply(
          function(x){
            x <-
              xml2::xml_contents(x) %>%
              lapply(as.character) %>%
              unlist()
            x[grep("\\d+", x)]
          }
        ) %>%
        unlist() %>%
        paste0(url, "/", .)
    }

    index_urls <- unlist(RES)

    # get file urls
    RES <- list()
    for(i in seq_along(unique(index_urls)) ){
      cat("\r",i)

      url <- unique(index_urls)[i]

      RES[[ length(RES)+1 ]] <-
        tryCatch(
          expr  = xml2::read_html(url),
          error = function(e){xml2::read_html("<html></html>")}
        ) %>%
        xml2::xml_find_all("//a/@href") %>%
        lapply(
          function(x){
            x <-
              xml2::xml_contents(x) %>%
              lapply(as.character) %>%
              unlist()
            x[grep("\\d+", x)]
          }
        ) %>%
        unlist() %>%
        paste0(url, "/", .)

      Sys.sleep(runif(1)*0.5)
    }

    # filter links
    dump_links <-
      unlist(RES) %>%
      unique() %>%
      grep(pattern = "pagecounts.*pagecounts.*\\.gz$", x = ., value = TRUE)

    # store in cache
    wpd_cache$dump_links <- dump_links
  }

  # return
  if( !is.null(directory) ){
    writeLines(
      text = wpd_cache$dump_links,
      con  = dump_links_path
    )
  }

  return(wpd_cache$dump_links)
}

