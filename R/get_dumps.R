
#' function that downloads dump files for specific dates
#'
#'
#' @param ts timestamp e.g. "20071201" or shorter that will be used to match dump links
#' @param dir directory to store downloads in
#'
#' @export
#'
#'
get_dumps <- function(ts, dir="."){
  # decide which links have to be downloaded
  links <- get_dump_links()
  index <-
    stringr::str_extract(basename(links), "\\d{8}") %>%
    grep(paste0("^", ts), .)

  to_be_downloaded <- links[index]

  # download dumps
  RES <- character(length(to_be_downloaded))
  for( i in seq_along(to_be_downloaded) ){
    destfile <-
      gsub("//", "/", paste0(dir, "/", basename(to_be_downloaded[i])))

    if( !file.exists(destfile) ){
      RES[[i]] <-
        tryCatch(
          expr =
            {
              download.file(
                url      = to_be_downloaded[i],
                destfile = destfile
              )
              paste0("ok::", destfile)
            },
          error = function(e){
            paste0("error::", e$message)
          },
          warning = function(e){
            paste0("warning::", e$message)
          }
        )
      Sys.sleep(2)
    }else{
      RES[[i]] <- "skip::file exists already"
      cat("file exists already - no download\n")
    }

    cat("\r", i, " / ", length(to_be_downloaded) )
  }

  return(to_be_downloaded)
}
