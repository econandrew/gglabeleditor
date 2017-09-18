#' @import shiny
plotOverlayOutput <- function (outputId, plotId, change)
{
  tagList(
    # Include CSS/JS dependencies. Use "singleton" to make sure that even
    # if multiple lineChartOutputs are used in the same page, we'll still
    # only include these chunks once.
    singleton(tags$head(
      tags$script(src="assets/plot-overlay-binding.js"),
      tags$script(src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"),
      tags$link(rel="stylesheet", type="text/css", href="assets/gglabeleditor.css")
    )),
    div(id = outputId, class = "editable-plot-overlay", `plot-id` = plotId, `data-change` = change,
        tag("svg", list())
    )
  )
}

#' @import miniUI
ui <- function() {
  miniPage(
    gadgetTitleBar("gglabeleditor: Edit label positions interactively"),
    miniContentPanel(
      div(style="height: 50px",
        actionButton("button_hide", "", icon = icon("minus")),
        actionButton("button_show", "", icon = icon("plus")),
        HTML("&nbsp;"),
        actionButton("button_hjust_left", "", icon = icon("align-left")),
        actionButton("button_hjust_center", "", icon = icon("align-center")),
        actionButton("button_hjust_right", "", icon = icon("align-right")),
        HTML("&nbsp;"),
        actionButton("button_vjust_bottom", "", icon = icon("align-left")),
        actionButton("button_vjust_center", "", icon = icon("align-center")),
        actionButton("button_vjust_top", "", icon = icon("align-right")),
        HTML("&nbsp;"),
        colourpicker::colourInput("color", NULL, palette = "limited")
      ),
      plotOutput("plot1", click = "plot_click", height="auto"),
      plotOverlayOutput("overlay1", "plot1", change = "label_change")
    )
  )
}
