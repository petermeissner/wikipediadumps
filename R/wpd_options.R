#' option object
#'
options <- new.env()
options$directory = "."

#' getting and setting wpd_options
#'
#' @export
wpd_options <- function(...){
  opt <- list(...)
  # get all options or assign to options environment
  if( length(opt) == 0 ){
    return(as.list(options))
  }else{
    for( i in seq_along(opt) ){
      assign(
        x     = names(opt)[i],
        value = opt[[i]],
        envir = options
      )
    }
  }
}
