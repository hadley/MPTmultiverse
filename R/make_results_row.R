
########### data structure

# results <- tibble(
#   model = character(),
#   dataset = character(),
#   pooling = character(),
#   package = character(),
#   method = character(),
#   est_group = list(tibble()),
#   est_indiv = list(tibble()),
#   test_between = list(tibble()),
#   #est_cov = est_cov,
#   gof = list(tibble()),
#   gof_group = list(tibble()),
#   gof_indiv = list(tibble())
# )

#' Create 
#' 
#' Internal function, creates container for results
#' 
#' @param model       Character.
#' @param dataset     Character.
#' @param pooling     Character.
#' @param package     Character.
#' @param method      Character.
#' @param data        A \code{data.frame}.
#' @param id          Character.

#' @importFrom magrittr %>%
#' @keywords internal

make_results_row <- function(
  model, 
  dataset,
  pooling,
  package,
  method,
  data,
  # parameters,
  id,
  condition,
  core = NULL  # character vector specifying which are core parameters
) {
  
  # prepare data to have the correct columns of id/condition
  data$id <- data[[id]]
  data$condition <- data[[condition]]
  
  conditions <- unique(data$condition)
  parameters <- as.character(MPTinR::check.mpt(model)$parameters)
  
  # check list of core parameters 
  if (!missing(core) && !is.null(core)){
    stopifnot(is.vector(core) && is.character(core))
    stopifnot(all(core %in% parameters))
  } 
  
  est_ind <- tibble::as_tibble(
    expand.grid(
      parameter = parameters
      , id = data$id
      , stringsAsFactors = FALSE
    )
  )
  
  est_ind <- dplyr::left_join(est_ind, data[, c("id", "condition")], by = "id")
  est_ind$core <- est_ind$parameter %in% core
  est_ind <- est_ind[,c("id", "condition", "parameter", "core")]
  est_ind <- tibble::add_column(est_ind, est = NA_real_, se = NA_real_)
  
  for (i in seq_along(getOption("MPTmultiverse")$ci_size)) {
    est_ind <- tibble::add_column(est_ind, xx = NA_real_)
    colnames(est_ind)[ncol(est_ind)] <- paste0("ci_", getOption("MPTmultiverse")$ci_size[i])
  }
  
  
  # create est_group empty df
  est_group <- tibble::as_tibble(
    expand.grid(
      parameter = parameters
      , condition = unique(data$condition)
      , stringsAsFactors = FALSE
    )
  )
  est_group$core <- est_group$parameter %in% core
  est_group <- est_group[, c("condition", "parameter", "core")]
  est_group$est = NA_real_
  est_group$se = NA_real_
  
  for (i in seq_along(getOption("MPTmultiverse")$ci_size)) {
    est_group <- tibble::add_column(est_group, xx = NA_real_)
    colnames(est_group)[ncol(est_group)] <- paste0("ci_", getOption("MPTmultiverse")$ci_size[i])
  }
  
  
  # group comparisons
  if (length(conditions) > 1) {
    
    pairs <- utils::combn(
      x = conditions
      , m = 2
      , simplify = FALSE
    )
    
    tmp_test_between <- vector("list", length(pairs))
    
    for (i in seq_along(pairs)) {
      
      tmp_test_between[[i]] <- tibble::as_tibble(
        expand.grid(
          parameter = parameters
          , condition1 = pairs[[i]][1]
          , condition2 = pairs[[i]][2]
          , stringsAsFactors = FALSE
        )) %>% 
        dplyr::mutate(core = parameter %in% core) %>%  
        dplyr::select(parameter, core, condition1, condition2) %>% 
        dplyr::mutate(est_diff = NA_real_, se = NA_real_, p = NA_real_)
      
      tibble_ci <- tibble::as_tibble(
        matrix(NA_real_, nrow(tmp_test_between[[i]]), 
               length(getOption("MPTmultiverse")$ci_size),
               dimnames = list(NULL, paste0("ci_", getOption("MPTmultiverse")$ci_size))))
      tmp_test_between[[i]] <- dplyr::bind_cols(tmp_test_between[[i]], tibble_ci)
    }
    test_between <- dplyr::bind_rows(tmp_test_between) 
  } else {
    test_between <- tibble::tibble()
  }
  ## est_covariate <- ##MISSING
  
  ## create gof empty df
  gof <- tibble::tibble(
    type = "",
    focus = "",
    stat_obs = NA_real_,
    stat_pred = NA_real_,
    stat_df = NA_real_,
    p = NA_real_
  )
  
  # Create gof_group and gof_indiv ----
  # Exploits value recycling of `data.frame`
  gof_group <- tibble::as_tibble(
    data.frame(
      condition = unique(data$condition)
      , gof
      , stringsAsFactors = FALSE
    )
  )
  
  gof_indiv <- tibble::as_tibble(
    data.frame(
      data[, c("id", "condition")]
      , gof
      , stringsAsFactors = FALSE
    )
  )
  
  # ----
  used_options <- tidy_options(mpt_options())
  
  ## data structure for results
  tibble::tibble(
    model = model,
    dataset = dataset,
    pooling = pooling,
    package = package,
    method = method,
    est_group = list(est_group),
    est_indiv = list(est_ind),
    test_between = list(test_between),
    #est_cov = est_cov,
    gof = list(gof),
    gof_group = list(gof_group),
    gof_indiv = list(gof_indiv),
    convergence = list(tibble::tibble()),
    estimation = list(tibble::tibble()),
    options = list(used_options)
  )
}