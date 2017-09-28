#' Title
#'
#' @param lang
#' @param path
#'
#' @export
#'
#' @import stringr glue
#'
extract_days <- function(lang, path){
  tmp_wd <- getwd()
  on.exit(setwd(tmp_wd))
  setwd(path)


  days <- unique(str_extract(list.files(path = path), "\\d{8}"))

  for(day in days){
    system2(
      "bash",
      glue(
        "zcat $(ls pagecounts-{day}*) ",
        "| egrep '^{lang} ' --binary-files=text ",
        "| tr [:upper:] [:lower:]",
        "> {lang}_{day}.txt",
        stdout = TRUE
      )
    )
  }


}




