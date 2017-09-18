#' @export
#' @import ggplot2
geom_label_editable <- function(mapping = NULL, data = NULL,
                                stat = "identity", position = "identity",
                                ...,
                                parse = FALSE,
                                nudge_x = 0,
                                nudge_y = 0,
                                label.padding = unit(0.25, "lines"),
                                label.r = unit(0.15, "lines"),
                                label.size = 0.25,
                                na.rm = FALSE,
                                show.legend = NA,
                                inherit.aes = TRUE,
                                edits = NULL) {
  if (!missing(nudge_x) || !missing(nudge_y)) {
    if (!missing(position)) {
      stop("Specify either `position` or `nudge_x`/`nudge_y`", call. = FALSE)
    }

    position <- position_nudge(nudge_x, nudge_y)
  }

  if (nrow(edits) > 0) {
    if (is.null(data)) {
      edited_data <- function(d) {
        merge_edits(d, edits, colnames(edits)[1])
      }
    } else {
      edited_data <- merge_edits(data, edits, colnames(edit))
    }
  } else {
    edited_data <- data
  }
  layer(
    data = edited_data,
    mapping = mapping,
    stat = stat,
    geom = GeomLabelEditable,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      parse = parse,
      label.padding = label.padding,
      label.r = label.r,
      label.size = label.size,
      na.rm = na.rm,
      edits = edits, # delete if not using any more
      ...
    )
  )
}


#' @export
#' @import ggplot2
GeomLabelEditable <- ggproto("GeomLabelEditable", Geom,
                             required_aes = c("x", "y", "label", "key"),

                             default_aes = aes(
                               colour = "black", fill = "white", size = 3.88, angle = 0,
                               hjust = 0.5, vjust = 0.5, alpha = NA, family = "", fontface = 1,
                               lineheight = 1.2
                             ),

                             #setup_data = function(data, params) {
                             #   print("SETUP DATA")
                             #   print(head(data))
                             #   data
                             # },

                             draw_panel = function(self, data, panel_params, coord, parse = FALSE,
                                                   na.rm = FALSE,
                                                   label.padding = unit(0.25, "lines"),
                                                   label.r = unit(0.15, "lines"),
                                                   label.size = 0.25, edits = NA) {
                               lab <- data$label
                               if (parse) {
                                 lab <- parse(text = as.character(lab))
                               }

                               #warning("EDITS")

                               data <- coord$transform(data, panel_params)

                               if (is.character(data$vjust)) {
                                 data$vjust <- compute_just(data$vjust, data$y)
                               }
                               if (is.character(data$hjust)) {
                                 data$hjust <- compute_just(data$hjust, data$x)
                               }

                               grobs <- lapply(1:nrow(data), function(i) {
                                 row <- data[i, , drop = FALSE]
                                 ggplot2:::labelGrob(lab[i],
                                                     x = unit(row$x, "native"),
                                                     y = unit(row$y, "native"),
                                                     just = c(row$hjust, row$vjust),
                                                     padding = label.padding,
                                                     r = label.r,
                                                     text.gp = grid::gpar(
                                                       col = row$colour,
                                                       fontsize = row$size * .pt,
                                                       fontfamily = row$family,
                                                       fontface = row$fontface,
                                                       lineheight = row$lineheight
                                                     ),
                                                     rect.gp = grid::gpar(
                                                       col = row$colour,
                                                       fill = alpha(row$fill, row$alpha),
                                                       lwd = label.size * .pt
                                                     )
                                 )
                               })
                               class(grobs) <- "gList"

                               ggplot2:::ggname("geom_label_editable", grid::grobTree(children = grobs))
                             },

                             draw_key = draw_key_label
)
