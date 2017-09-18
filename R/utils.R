update_edits <- function(edits, changes) {
  #TODO there has to be a better way to do this & also preserves ordering
  if (nrow(edits) == 0) {
    edits <- changes
  } else {
    edits <- edits[!(edits[[1]] %in% changes[[1]]),]
    edits <- rbind(edits, changes)
  }
  edits
}

merge_edits <- function(labels, edits, key = "key") {
  # gotta be a better way to do this
  for (r in 1:nrow(edits)) {
    for (cname in intersect(setdiff(colnames(edits), key), colnames(labels))) {
      if (!is.na(edits[r, cname])) {
        labels[labels[,key] == edits[r, key], cname] <- edits[r, cname]
      }
    }
  }
  labels
}

serialize <- function(df) {
  ll <- apply(df,1,as.list)
  names(ll) <- NULL
  ll
}

deserialize <- function(input) {
  as.data.frame(input, stringsAsFactors = F)
}

extract_built_data <- function(p) {
  l <- length(p$layers)
  layer <- p$layers[[l]]

  if (layer$inherit.aes) {
    aesthetics <- plyr::defaults(layer$mapping, p$mapping)
  } else {
    aesthetics <- layer$mapping
  }

  varnames_xy <- as.character(aesthetics[c("x", "y")])

  pb <- ggplot2::ggplot_build(p)
  computed_data <- pb$data[[l]]
  computed_data$x <- NULL
  computed_data$y <- NULL
  unscaled_xy_data <- p$layers[[l]]$compute_aesthetics(p$layers[[l]]$layer_data(p$data), p)[,c("x", "y")]
  data <- cbind(computed_data, unscaled_xy_data)
  data
}

makefirstcol <- function (df, varname) {
  df[,c(varname, colnames(df)[colnames(df) != varname])]
}
