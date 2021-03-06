#' Multiverse Analysis for MPT Models
#'
#' Performs a multiverse analysis for multinomial processing tree (MPT) models
#' across different levels of pooling (i.e., data aggregation) and across
#' maximum-likelihood/frequentist and Bayesian estimation approaches. For the
#' frequentist approaches, no pooling (with and without parametric or
#' nonparametric bootstrap) and complete pooling  are implemented using
#' \pkg{MPTinR}. For the Bayesian approaches, no pooling, complete pooling, and
#' three different variants of partial pooling are implemented using
#' \pkg{TreeBUGS}. Requires \code{data} on a by-participant level with each row
#' corresponding to data from one participant (i.e., different response
#' categories correspond to different columns) and the data can contain a single
#' between-subjects condition. Model equations need to be passed as a
#' \code{.eqn} model file and category labels (first column in \code{.eqn} file)
#' need to match the column names in \code{data}. Results are returned in one
#' \code{tibble} with one row per estimation method.
#'
#' @param method \code{character} vector specifying which analysis approaches
#'   should be performed (see Description below). Defaults to all available
#'   methods.
#' @param dataset scalar \code{character} vector. Name of the data set that will
#'   be copied to the results \code{tibble}.
#' @param data A \code{data.frame} containing the data. Column
#'   names need to match category names in \code{model} (i.e., different from
#'   \pkg{MPTinR} behavior, order of categories is not important, matching is
#'   done via name).
#' @param model A model definition, typically the path to an \code{.eqn} model
#'   file containing the model equations. Category names need to match column
#'   names in \code{data}.
#' @param id scalar \code{character} vector. Name of the column that contains
#'   the subject identifier. If not specified, it is assumed that each row
#'   represents observations from one participant.
#' @param condition scalar \code{character} vector. Name of the column
#'   specifying a between-subjects factor. If not specified, no between-subjects
#'   comparisons are performed.
#' @param core \code{character} vector defining the core parameters of interest,
#'   e.g., \code{core = c("Dn", "Do")}. All other parameters are treated as
#'   auxiliary parameters.
#' @example examples/examples.fit_mpt.R
#'
#' @details This functions is a fancy wrapper for packages \pkg{MPTinR} and
#'   \pkg{TreeBUGS} applying various frequentist and Bayesian estimation methods
#'   to the same data set with different levels of pooling/aggregation using a
#'   single MPT model and collecting the results in one \code{tibble} where each
#'   row corresponds to one estimation method. Note that parameter restrictions
#'   (e.g., equating different parameters or fixing them to a constant) need to
#'   be part of the model (i.e., the \code{.eqn} file) and cannot be passed as
#'   an argument.
#'
#'   The settings for the various methods are specified via function
#'   \code{\link{mpt_options}}. The default settings use all available cores for
#'   calculating the boostrap distribution as well as independent MCMC chains
#'   and should be appropriate for most situations.
#'
#'   The data can have a single between-subjects condition (specified via
#'   \code{condition}). This condition can have more than two levels. If
#'   specified, the pairwise differences between each level, the standard error
#'   of the differences, and confidence-intervals of the differences are
#'   calculated for each parameter. Please note that \code{condition} is
#'   silently converted to \code{character} in the output. Thus, a specific
#'   ordering of the \code{factor} levels in the output cannot be guaranteed. If
#'   the data has more than one between-subjects condition, these need to be
#'   combined into one condition for this function.
#'
#'   To include multiple within-subjects conditions, include separate trees and
#'   separate sets of parameters for each within-subjects condition in your
#'   .eqn file.
#'
#'   \subsection{Pooling}{
#'   The following pooling levels are provided (not all by all estimation approaches, see below).
#'   \itemize{
#'       \item{\emph{Complete pooling:} }{The traditional analysis approach in the MPT
#'       literature in which data is aggregated across participants within each
#'       between-subjects condition. This approach assumes that there are no
#'       individual-dfferences. Produces one set of model parameters per condition.}
#'       \item{\emph{No pooling:} }{The model is fitted to the individual-level data in
#'       an independent manner (i.e., no data aggregation). This approach
#'       assumes that there is no similarity across participants and usually
#'       requires considerable amounts of data on the individual-level. Produces
#'       one set of model parameters per participant. Group-level estimates are
#'       based on averaging the individual-level estimates.}
#'     \item{\emph{Partial pooling:} }{Data is fitted simultaneously to the
#'     individual-level data assuming that the individual-level parameters come
#'     from a group-level distribution. Individual-level parameters are often
#'     treated as random-effects which are nested in the group-level parameters,
#'     which is why this approach is also called hierarchical modeling. This
#'     approach assumes both individual-level differences and similarities.
#'     Produces one set of model parameters per participant plus one set of
#'     group-level parameters. Thus, although partial pooling models usually
#'     have more parameters than the no-pooling approaches, they are usually
#'     less flexible as the hierarchical-structure provides regularization of
#'     the individual-level parameters. }
#'     }
#'   }
#'
#'   \subsection{Implemented Estimation Methods}{
#'     Maximum-likelihood estimation with \pkg{MPTinR} via
#'     \code{\link[MPTinR]{fit.mpt}}:
#'     \itemize{
#'       \item{\code{"asymptotic_complete"}: }{Asymptotic ML theory, complete
#'       pooling}
#'       \item{\code{"asymptotic_no"}: }{ Asymptotic ML theory, no pooling}
#'       \item{\code{"pb_no"}: }{Parametric bootstrap, no pooling}
#'       \item{\code{"npb_no"}: }{Nonparametric bootstrap, no pooling}
#'     }
#'
#'     Bayesian estimation with \pkg{TreeBUGS}
#'     \itemize{
#'       \item{\code{"simple"}: }{Bayesian estimation, no pooling (C++,
#'         \link[TreeBUGS]{simpleMPT})}
#'       \item{\code{"simple_pooling"}: }{Bayesian estimation, complete pooling
#'         (C++, \link[TreeBUGS]{simpleMPT})}
#'       \item{\code{"trait"}: }{latent-trait model, partial pooling (JAGS,
#'         \link[TreeBUGS]{traitMPT})}
#'       \item{\code{"trait_uncorrelated"}: }{latent-trait model without
#'         correlation parameters, partial pooling (JAGS,
#'         \link[TreeBUGS]{traitMPT})}
#'       \item{\code{"beta"}: }{beta-MPT model, partial pooling (JAGS,
#'         \link[TreeBUGS]{betaMPT})}
#'       \item{\code{"betacpp"}: }{beta-MPT model, partial pooling (C++,
#'         \link[TreeBUGS]{betaMPTcpp})}
#'     }
#'   }
#'   \subsection{Frequentist/Maximum-Likelihood Methods}{
#'     For the \emph{complete pooling asymptotic approach}, the group-level parameter
#'     estimates and goodness-of-fit statistics are the maximum-likelihood and
#'     G-squared values returned by \code{MPTinR}. The parameter differences are
#'     based on these values. for between-subjects comparisons, the standard
#'     errors of the differences are simply the pooled standard error of the
#'     individual parameters; for within-subjects comparisons, the standard errors
#'     of the differences are based on the respective linear transform of the estimated
#'     variance-covariance matrix calculated from the Hessian matrix. The overall fit
#'     (column \code{gof}) is based on an additional fit to the completely
#'     aggregated data.
#'
#'     For the \emph{no pooling asymptotic approach}, the individual-level
#'     maximum-likelihood estimates are reported in column \code{est_indiv} and
#'     \code{gof_indiv} and provide the basis for the other results. Whether or
#'     not an individual-level parameter estimate is judged as identifiable
#'     (column \code{identifiable}) is based on separate fits with different
#'     random starting values. If, in these separate, fits the same objective
#'     criterion is reached several times (i.e., \code{Log.Likelihood} within
#'     .01 of best fit), but the parameter estimate differs (i.e., different
#'     estimates within .01 of each other), then an estimate is flagged as
#'     non-identifiable. If they are the same (i.e., within .01 of each other)
#'     they are marked as identifiable. The group-level parameters are simply
#'     the means of the identifiable individual-level parameters, the SE is the
#'     SE of the mean for these parameter (i.e., SD/sqrt(N), where N excludes
#'     non-identifiable parameters and thise estimated as NA), and the CI is
#'     based on mean and SE. The group-level and overall fit is the sum of the
#'     individual G-squares, sum of individual-level df, and corresponding
#'     chi-square df. The difference between the conditions and corresponding
#'     statistics are based on a t-test comparing the individual-level estimates
#'     (again, after excluding non-identifiable estimates). The CIs of the
#'     difference are based on the SEs (which are derived from a linear model
#'     equivalent to the t-test). Within-subjects comparisons are based on t-tests
#'     for paired observations.
#'
#'
#'     The individual-level estimates of the \code{bootstrap based no-pooling}
#'     approaches are identical to the asymptotic ones. However, the SE is the
#'     SD of the bootstrapped distribution of parameter estimates, the CIs are
#'     the corresponding quantiles of the bootstrapped distribution, and the
#'     p-value is obtained from the bootstrapped G-square distribution.
#'     Identifiability of individual-level parameter estimates is also based on
#'     the bootstrap distribution of estimates. Specifically, we calculate the
#'     range of the CI (i.e., maximum minus minimum CI value) and flag those
#'     parameters as non-identifiable for which the range is larger than
#'     \code{mpt_options()$max_ci_indiv}, which defaults to \code{0.99}. Thus,
#'     in the default settings we say a parameter is non-identifiable if the
#'     bootstrap based CI extends from 0 to 1. The group-level estimates are the
#'     mean of the identifiable individual-level estimates. The difference
#'     between conditions (as well as within conditions) is calculated in the same manner as for the asymptotic
#'     case using the identifiable individual-level parameter estimates.
#'   }
#'
#'   \subsection{Bayesian Methods}{
#'     The \emph{simple approaches} fit fixed-effects MPT models.
#'     \code{"simple"} uses no pooling and thus assumes independent uniform priors
#'     for the individual-level parameters. Group-level means are
#'     obtained as generated quantities by averaging the posterior samples
#'     across participants. \code{"simple_pooling"} aggregates observed
#'     frequencies across participants and assumes a uniform prior for the
#'     group-level parameters.
#'
#'     The \emph{latent-trait approaches} transform the individual-level
#'     parameters to a latent probit scale using the inverse cumulative standard
#'     normal distribution. For these probit values, a multivariate normal
#'     distribution is assumed at the group level. Whereas \code{"trait"}
#'     estimates the corresponding correlation matrix of the parameters
#'     (reported in the column \code{est_rho}), \code{"trait_uncorrelated"} does
#'     not estimate this correlation matrix (i.e., parameters can still be
#'     correlated across individuals, but this is not accounted for in the
#'     model).
#'
#'     For all Bayesian methods, the posterior distribution of the parameters is
#'     summarized by the posterior mean (in the column \code{est}), posterior
#'     standard deviation (\code{se}), and credbility intervals (\code{ci_*}).
#'     For parameter differences (\code{test_between} and \code{test_within}) and correlations
#'     (\code{est_rho}), Bayesian p-values are computed (column \code{p}) by
#'     counting the relative proportion of posterior samples that are smaller
#'     than zero. Goodness of fit is tested with the T1 statistic
#'     (observed vs. posterior-predicted average frequencies, \code{focus =
#'     "mean"}) and the T2 statistic (observed vs. posterior-predicted
#'     covariance of frequencies, \code{focus = "cov"}).
#'    }
#'
#' @return A \code{tibble} with one row per estimation \code{method} and the
#'   following columns:
#' \enumerate{
#'   \item \code{model}: Name of model file (copied from \code{model} argument),
#'   \code{character}
#'   \item \code{dataset}: Name of data set (copied from \code{dataset}
#'   argument), \code{character}
#'   \item \code{pooling}: \code{character} specifying the level of pooling with
#'   three potential values: \code{c("complete", "no", "partial")}
#'   \item \code{package}: \code{character} specifying the package used for
#'   estimation with two potential values: \code{c("MPTinR", "TreeBUGS")}
#'   \item \code{method}: \code{character} specifying the method used with the
#'   following potential values: \code{c("asymptotic", "PB/MLE", "NPB/MLE",
#'   "simple", "trait", "trait_uncorrelated", "beta", "betacpp")}
#'   \item \code{est_group}: Group-level parameter estimates per condition/group.
#'   \item \code{est_indiv}: Individual-level parameter estimates (if provided
#'   by method).
#'   \item \code{est_rho}: Estimated correlation of individual-level parameters
#'   on the probit scale (only in \code{method="trait"}).
#'   \item \code{test_between}: Parameter differences between the levels of the
#'   between-subjects condition (if specified).
#'   \item \code{test_within}: Within-subjects parameter differences.
#'   \item \code{gof}: Overall goodness of fit across all individuals.
#'   \item \code{gof_group}: Group-level goodness of fit.
#'   \item \code{gof_indiv}: Individual-level goodness of fit.
#'   \item \code{fungibility}:  Posterior correlation of the group-level means
#'   \code{pnorm(mu)} (only in \code{method="trait"}).
#'   \item \code{test_homogeneity}: Chi-square based test of participant
#'   homogeneity proposed by Smith and Batchelder (2008). This test is the same
#'   for each estimation method.
#'   \item \code{convergence}: Convergence information provided by the
#'   respective estimation method. For the asymptotic frequentist methods this
#'   is a \code{tibble} with rank of the Fisher matrix, the number of parameters
#'   (which should match the rank of the Fisgher matrix), and the convergence
#'   code provided by the optimization algorithm (which is
#'   \code{\link{nlminb}}). The boostrap methods contain an additional column,
#'   \code{parameter}, that contains the information which (if any) parameters
#'   are empirically non-identifiable based on the bootstrapped distribution of
#'   parameter estimates (see above for exact description). For the Bayesian
#'   methods this is a \code{tibble} containing information of the posterior
#'   dsitribution (i.e., mean, quantiles, SD, SE, \code{n.eff}, and R-hat) for
#'   each parameter.
#'   \item \code{estimation}: Time it took for each estimation method and group.
#'   \item \code{options}: Options used for estimation. Obtained by running
#'   \code{\link{mpt_options}()}
#' }
#'
#' With the exception of the first five columns (i.e., after \code{method}) all
#' columns are \code{list} columns typically holding one \code{tibble} per cell.
#' The simplest way to analyze the results is separately per column using
#' \code{\link[tidyr]{unnest}}. Examples for this are given below.
#'
#' @references
#'   Smith, J. B., & Batchelder, W. H. (2008). Assessing individual differences
#'   in categorical data. \emph{Psychonomic Bulletin & Review}, 15(4), 713-731.
#'   \url{https://doi.org/10.3758/PBR.15.4.713}

#'
#' @export

fit_mpt <- function(
  model
  , dataset
  , data
  , id = NULL
  , condition = NULL
  , core = NULL
  , method
) {

  available_methods <- c(
    # MPTinR ----
    "asymptotic_complete"
    , "asymptotic_no"
    , "pb_no"
    , "npb_no"
    # TreeBUGS ----
    , "simple"
    , "simple_pooling"
    , "trait"
    , "trait_uncorrelated"
    , "beta"
    , "betacpp"
  )

  # catch the function call that was used,
  # and other stuff that should be save along the results
  matched_call <- match.call()
  used_model <- utils::read.table(model, skip = 1, stringsAsFactors = FALSE)

  if(missing(method)) {
    method <- available_methods
  }

  method <- match.arg(
    arg = method
    , choices = available_methods
    , several.ok = TRUE
  )

  # set options ----
  silent_jags <- getOption("MPTmultiverse")$silent_jags
  runjags::runjags.options(silent.jags = silent_jags,
                           silent.runjags = silent_jags)

  # prepare data ----
  if (missing(data)) {
    data <- as.data.frame(readr::read_csv(dataset))
  }

  if(is.null(condition)) {
    data$ExpCond <- "no_condition"
    condition <- "ExpCond"
  }

  if(is.null(id)) {
    data$Subject <- 1:nrow(data)
    id <- "Subject"
  }

  # Ensure that all variables are character
  data$ExpCond <- as.character(data[[condition]])
  data$Subject <- as.character(data[[id]])

  if(any(duplicated(data$Subject))) {
    stop("Multiple rows per subject in data. Ensure that the subject identifier is properly specified and you correctly aggregated your data.")
  }


  # check MPT file
  mpt_model <- TreeBUGS::readEQN(model)

  if(!is.data.frame(mpt_model)) {
    "I can't comprehend your .eqn file."
  }


  # remove extraneous colums and check if all specified columns are present
  # in data
  freq_cols <- get_eqn_categories(model)
  valid_cols <- c(id, condition, freq_cols)
  check_cols <- valid_cols %in% colnames(data)

  if(!all(check_cols)) {
    stop("Variable \"", paste(valid_cols[!check_cols], collapse = ", "), "\" not found in data.frame.")
  }

  data <- data[, valid_cols]


  # Check NAs ----
  nas_found <- unlist(lapply(X = data, FUN = anyNA))

  if(any(nas_found)) {
    stop("Variable \"", paste(valid_cols[nas_found], collapse = ", "), "\" contains missing values.")
  }

  # Check whether freqencies are integer ----
  not_integer <- unlist(lapply(X = data[, freq_cols], FUN = function(x) {
      any(as.integer(x)!=x)
    }
  ))

  if(any(not_integer)) {
    stop("Variable \"", paste(freq_cols[not_integer], collapse = ", "), "\" contains non-integer values.")
  }

  # Sanity check for TreeBUGS options
  if(any(method %in% c("simple", "simple_pooling", "trait", "trait_uncorrelated", "beta", "betacpp"))) {
    opt <- mpt_options()
    n.samples <- (opt$treebugs$n.iter - opt$treebugs$n.burnin) * opt$n.CPU
    if((opt$treebugs$n.iter - opt$treebugs$n.burnin)<=0) {
      stop("Check your mpt_options(): You specified less iterations (n.iter) than burn-in samples (n.burnin).")
    }
    if(n.samples <= 0 | n.samples < opt$treebugs$Neff_min) {
      warning("With your current mpt_options(), it is not possible to obtain the specified number of effective samples.")
    }
  }


  # Ensure that id and condition are character, also drops unused levels
  data[[id]] <- as.character(data[[id]])
  data[[condition]] <- as.character(data[[condition]])


  res <- list()

  # MPTinR part ----
  if (any(method %in% c("asymptotic_complete", "asymptotic_no", "pb_no", "npb_no"))) {
    res[["mptinr"]] <- mpt_mptinr(
      dataset = dataset
      , data = data
      , model = model
      , method = intersect(method, c("asymptotic_complete", "asymptotic_no", "pb_no", "npb_no"))
      , id = id
      , condition = condition
      , core = core
    )
  }

  # TreeBUGS part ----
  res[["treebugs"]] <- dplyr::bind_rows(
    purrr::map(
      intersect(method, c("simple", "simple_pooling", "trait", "trait_uncorrelated", "beta", "betacpp"))
      , mpt_treebugs_safe
      , dataset = dataset
      , data = data
      , model = model
      , id = id
      , condition = condition
      , core = core
    )
  )

  y <- dplyr::bind_rows(res)
  class(y) <- c("multiverseMPT", class(y))
  attr(y, "call") <- matched_call
  attr(y, "model_file") <- model
  attr(y, "data_file") <- dataset
  attr(y, "model") <- used_model
  attr(y, "data") <- data
  attr(y, "id") <- id
  attr(y, "condition") <- condition
  attr(y, "core") <- core
  y
}
