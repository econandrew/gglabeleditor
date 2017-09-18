
#' @export
#' @import ggplot2
gglabeleditor_demo <- function() {
  cars <- mtcars
  cars$model <- row.names(cars)
  p <- ggplot(cars, aes(x = wt, y = disp)) +
    geom_point()
  extra_aes = aes(label = model, key = model)
  out <- gglabeleditor(p, 800, 400, extra_aes, edits_file = "labels.RData", label.padding = unit(0.1, "lines"), vjust=0, hjust =0)

  #p + geom_label_editable(extra_aes, edits = out$edits, label.padding = unit(0.1, "lines"), vjust=0, hjust =0 )
  #p + do.call(geom_text, c(list(mapping = aes(x = x, y = y, label = label), data = out$final_data, inherit.aes=F)), as.list(out$final_params)))
  p + geom_text(data = out$final, mapping = aes(x = x, y = y, label = label))
}
