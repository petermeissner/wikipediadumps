#' filter dumps to file
#'
#' @param fname file to filter through
#' @param wiki wiki to filter for
#' @param directory base dir where to store filtering
#'
#' @export
#'
filter_dumps_to_file_par <- function(flist, wiki, directory=NULL){
  # handle directory to store data
  if( is.null(directory) ){
    directory <- wpd_options()$directory
  }
  stopifnot(!is.null(directory))

  # spin up cluster
  cl  <- parallel::makeCluster(3)
  on.exit({
    parallel::stopCluster(cl)
  })

  # do computations
  res <-
    parallel::parLapplyLB(
      cl        = cl,
      X         = flist,
      fun       = filter_worker,
      wiki      = wiki,
      directory = directory
    )

  # return
  return(res)
}

#' filter dumps to file
#'
#' @param fname file to filter through
#' @param wiki wiki to filter for
#' @param directory base dir where to store filtering
#'
#' @export
#'
filter_dumps_to_file <- function(flist, wiki, directory=NULL){
  # handle directory to store data
  if( is.null(directory) ){
    directory <- wpd_options()$directory
  }
  stopifnot(!is.null(directory))

  res <- list()
  # do computations
  for( i in seq_along(flist) ){
    cat(as.character(Sys.time()), " -- ")
    cat(system.time({
      res[[i]] <-
        filter_worker(
          fname     = flist[i],
          wiki      = wiki,
          directory = directory
        )
    })[3])
  }

  # return
  return(res)
}



#' worker function
#'
#' @param flist list of files to filter through
#' @param wiki wiki to filter for
#' @param directory base dir where to store filtering
#'
filter_worker <- function(fname, wiki, directory=NULL){

  cat(fname)

  pathout  <- paste0(directory, "/", wiki)
  fnameout <- gsub("\\.gz$", ".txt", paste0(pathout, "/", basename(fname)))
  timings  <- numeric(0)
  exec     <- logical(0)

  timings <-
    c(
      timings,
      system.time({

  # read file
  tmp <- readLines(fname)

  # preprocess file
  Encoding(tmp) <- "UTF-8"
  tmp <- urltools::url_decode(tmp)
  Encoding(tmp) <- "UTF-8"

  # output non UTF8 cases for diagnostics
  dir.create(paste0(directory, "/problems"), showWarnings = FALSE, recursive = TRUE)
  writeLines(
    text = tmp[grep("~~~", iconv(tmp, "UTF-8", "UTF-8", sub="~~~~"))],
    con  = paste0(directory, "/problems/", gsub("\\.gz$", ".txt", basename(fname)))
  )

  # some general fitlering
  tmp <- tmp[!stringr::str_detect(iconv(tmp, "UTF-8", "UTF-8", sub="~~~~"), "~~~~")]
  tmp <- tmp[!stringr::str_detect(tmp, " :?\\w+:")]
  tmp <- tmp[!stringr::str_detect(string = tmp, pattern = stringr::regex("/admin/",  ignore.case=TRUE))]
  tmp <- tmp[!stringr::str_detect(string = tmp, pattern = stringr::regex("\\.php",   ignore.case=TRUE))]
  tmp <- tmp[!stringr::str_detect(string = tmp, pattern = stringr::regex("Main_Page/",ignore.case=TRUE))]
  tmp <- tmp[!stringr::str_detect(string = tmp, pattern = stringr::regex("\\.css",ignore.case=TRUE))]
  tmp <- tmp[!stringr::str_detect(string = tmp, pattern = stringr::regex("\\.jpg ",ignore.case=TRUE))]
  tmp <- tmp[!stringr::str_detect(string = tmp, pattern = stringr::regex("\\.svg ",ignore.case=TRUE))]
  tmp <-
    tmp[
      !stringr::str_detect(
        string  = tmp,
        pattern =
          stringr::regex(
            "(^nostalgia)|(^sep11)|(^sources)|(^species)|(^tokipona)|(^commons)|( \\?)",
            ignore.case = TRUE
          )
        )
      ]


  # loop through wikis and filter stuff into separate folders and files
  for( i in seq_along(wiki) ){
    # prepare names

    dir.create(pathout[i], recursive=TRUE, showWarnings = FALSE)

    # execute
    if( !file.exists(fnameout[i]) ){
      tmp_out <- tmp[grep(paste0("^", wiki[i], " "), tmp)]
      writeLines(tmp_out, fnameout[i], useBytes = TRUE)
      exec <- c(exec, TRUE)
    }else{
      exec <- c(exec, FALSE)
    }
  }

  })[3])

  # return
  return(
    data.frame(
      fname = fnameout,
      time  = timings / length(fnameout),
      exec  = exec,
      stringsAsFactors = TRUE
    )
  )
}


#' function that extracts wikis from files
#' @export
extract_wikis <- function(pagecount_txt, directory=NULL){
  # handle directory to store file
  if( is.null(directory) ){
    directory <- wpd_options()$directory
  }
  stopifnot(!is.null(directory))

  # extract wikis
  wikis <- unique(gsub(" .*$", "", pagecount_txt))

  # prepare database
  con <- RSQLite::dbConnect(RSQLite::SQLite(), paste0(directory, "/meta.db"))
  on.exit(RSQLite::dbDisconnect(con))

  if( !RSQLite::dbExistsTable(conn = con, "wikis") ){
    res <- RSQLite::dbExecute(con, "create table wikis (wiki text unique)")
  }

  # execut insert into database
  query_string <-
    paste0(
      "INSERT OR IGNORE INTO wikis (wiki)
      VALUES ",
      paste0("('", wikis, "')", collapse = ", "),
      ";",
      collapse = ""
    )
  RSQLite::dbExecute(con, query_string)

  # return
  return(invisible(wikis))
}




















