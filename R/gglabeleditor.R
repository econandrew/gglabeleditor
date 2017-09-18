#' @export
gglabeleditor <- function(plot, width, height, mapping, edits_file = NULL, DEBUG = FALSE,...) {
  call = match.call()
  if (DEBUG) {
    options(shiny.trace = TRUE)
    viewer = shiny::browserViewer()
  } else {
    options(shiny.trace = FALSE)
    viewer = shiny::dialogViewer("Edit labels", width+80, height+150)
  }
  shiny::addResourcePath("assets", system.file("www", package="gglabeleditor"))
  shiny::runGadget(shinyApp(ui(), server(plot, width, height, mapping, edits_file, gglabeleditor_call = call, ...)), viewer = viewer)
}

.onAttach <- function(libname, pkgname) {
  packageStartupMessage("Welcome to gglabeleditor. Run gglabeleditor_demo() to see a demonstration (without the parens to see source).")
}
