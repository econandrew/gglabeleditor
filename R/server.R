#' @import shiny
server <- function(plot, width, height, mapping, edits_file, gglabeleditor_call, ...) {
  uncompute_aesthetics <- function(data) {
    #TODO worry about inherit.aes
    data <- makefirstcol(data, "key")
    aesthetics <- plyr::defaults(mapping, plot$mapping)
    plyr::rename(data, c(key = aesthetics$key, x = aesthetics$x, y = aesthetics$y))
  }

  compute_aesthetics <- function(data) {
    #TODO worry about inherit.aes
    aesthetics <- plyr::defaults(mapping, plot$mapping)
    replacements <- c("x", "y", "key")
    names(replacements) <- c(aesthetics$key, aesthetics$x, aesthetics$y)
    plyr::rename(data, replacements)
  }

  if (!is.null(edits_file) && file.exists(edits_file)) {
    edits <- readRDS(edits_file)$edits
  } else {
    edits <- data.frame()
  }
  auto_labels <- data.frame()
  makeReactiveBinding("edits")
  makeReactiveBinding("built_labels")

  function(input, output) {
    output$plot1 <- renderPlot({
      if (!is.null(input$label_change)) {
        edits <<- update_edits(edits, uncompute_aesthetics(deserialize(input$label_change)))
      }
      labels_geom <- geom_label_editable(mapping,...,edits = edits)
      labelled_plot <- plot + labels_geom
      built_labels <<- extract_built_data(labelled_plot)
      labelled_plot
    }, width, height)

    output$overlay1 <- reactive({
      #input$button
      serialize(built_labels)
    })

    observeEvent(input$done, {
      aes_elements <- c(GeomText$required_aes, names(GeomText$default_aes))

      returnValue <- list(
        final = built_labels[,aes_elements],
        final_data = built_labels[,c("x","y","label")],
        final_params = built_labels[,!(colnames(built_labels) %in% c("x","y","label"))],
        edits = edits,
        call = gglabeleditor_call
      )
      if (!is.null(edits_file)) {
        saveRDS(returnValue, file=edits_file)
      }
      stopApp(returnValue)
    })
  }
}

