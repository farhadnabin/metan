#' Genotype-environment analysis by mixed-effect models
#'
#' Genotype analysis in multi-environment trials using mixed-effect or
#' random-effect models.
#'
#'
#' The nature of the effects in the model is chosen with the argument
#' \code{random}. By default, the experimental design considered in each
#' environment is a randomized complete block design. If \code{block} is
#' informed, a resolvable alpha-lattice design (Patterson and Williams, 1976) is
#' implemented. The following six models can be fitted depending on the values
#' of \code{random} and \code{block} arguments.
#'   *  \strong{Model 1:} \code{block = NULL} and \code{random = "gen"} (The
#'   default option). This model considers a Randomized Complete Block Design in
#'   each environment assuming genotype and genotype-environment interaction as
#'   random effects. Environments and blocks nested within environments are
#'   assumed to fixed factors.
#'
#'   *  \strong{Model 2:} \code{block = NULL} and \code{random = "env"}. This
#'   model considers a Randomized Complete Block Design in each environment
#'   treating environment, genotype-environment interaction, and blocks nested
#'   within environments as random factors. Genotypes are assumed to be fixed
#'   factors.
#'
#'   *  \strong{Model 3:} \code{block = NULL} and \code{random = "all"}. This
#'   model considers a Randomized Complete Block Design in each environment
#'   assuming a random-effect model, i.e., all effects (genotypes, environments,
#'   genotype-vs-environment interaction and blocks nested within environments)
#'   are assumed to be random factors.
#'
#'   *  \strong{Model 4:} \code{block} is not \code{NULL} and \code{random =
#'   "gen"}. This model considers an alpha-lattice design in each environment
#'   assuming genotype, genotype-environment interaction, and incomplete blocks
#'   nested within complete replicates as random to make use of inter-block
#'   information (Mohring et al., 2015). Complete replicates nested within
#'   environments and environments are assumed to be fixed factors.
#'
#'   *  \strong{Model 5:} \code{block} is not \code{NULL} and \code{random =
#'   "env"}. This model considers an alpha-lattice design in each environment
#'   assuming genotype as fixed. All other sources of variation (environment,
#'   genotype-environment interaction, complete replicates nested within
#'   environments, and incomplete blocks nested within replicates) are assumed
#'   to be random factors.
#'
#'   *  \strong{Model 6:} \code{block} is not \code{NULL} and \code{random =
#'   "all"}. This model considers an alpha-lattice design in each environment
#'   assuming all effects, except the intercept, as random factors.
#'
#' @param .data The dataset containing the columns related to Environments,
#'   Genotypes, replication/block and response variable(s).
#' @param env The name of the column that contains the levels of the
#'   environments.
#' @param gen The name of the column that contains the levels of the genotypes.
#' @param rep The name of the column that contains the levels of the
#'   replications/blocks.
#' @param resp The response variable(s). To analyze multiple variables in a
#'   single procedure a vector of variables may be used. For example \code{resp
#'   = c(var1, var2, var3)}.
#' @param block Defaults to \code{NULL}. In this case, a randomized complete
#'   block design is considered. If block is informed, then an alpha-lattice
#'   design is employed considering block as random to make use of inter-block
#'   information, whereas the complete replicate effect is always taken as
#'   fixed, as no inter-replicate information was to be recovered (Mohring et
#'   al., 2015).
#' @param random The effects of the model assumed to be random. Defaults to
#'   \code{random = "gen"}. See \strong{Details} to see the random effects
#'   assumed depending on the experimental design of the trials.
#' @param prob The probability for estimating confidence interval for BLUP's
#'   prediction.
#' @param verbose Logical argument. If \code{verbose = FALSE} the code will run
#'   silently.
#' @references
#' Olivoto, T., A.D.C. L{\'{u}}cio, J.A.G. da silva, V.S. Marchioro, V.Q. de
#' Souza, and E. Jost. 2019. Mean performance and stability in multi-environment
#' trials I: Combining features of AMMI and BLUP techniques. Agron. J.
#' 111:2949-2960.
#' \href{https://dl.sciencesocieties.org/publications/aj/abstracts/0/0/agronj2019.03.0220?access=0&view=pdf}{doi:10.2134/agronj2019.03.0220}
#'
#' Mohring, J., E. Williams, and H.-P. Piepho. 2015. Inter-block information: to
#' recover or not to recover it? TAG. Theor. Appl. Genet. 128:1541-54.
#' \href{http://www.ncbi.nlm.nih.gov/pubmed/25972114}{doi:10.1007/s00122-015-2530-0}
#'
#' Patterson, H.D., and E.R. Williams. 1976. A new class of resolvable
#' incomplete block designs. Biometrika 63:83-92.
#' \href{https://doi.org/10.1093/biomet/63.1.83}{doi:10.1093/biomet/63.1.83}
#'
#'
#' @return An object of class \code{waasb} with the following items for each
#'   variable:
#'
#'
#' * \strong{fixed} Test for fixed effects.
#'
#' * \strong{random} Variance components for random effects.
#'
#' * \strong{LRT} The Likelihood Ratio Test for the random effects.
#'
#'
#' * \strong{BLUPgen} The random effects and estimated BLUPS for genotypes (If
#' \code{random = "gen"} or \code{random = "all"})
#'
#' * \strong{BLUPenv} The random effects and estimated BLUPS for environments,
#' (If \code{random = "env"} or \code{random = "all"}).
#'
#' * \strong{BLUPint} The random effects and estimated BLUPS of all genotypes in
#' all environments.
#'
#'
#' * \strong{MeansGxE} The phenotypic means of genotypes in the environments.
#'
#' * \strong{Details} A list summarizing the results. The following information
#' are shown: \code{Nenv}, the number of environments in the analysis;
#' \code{Ngen} the number of genotypes in the analysis; \code{Mean} the grand
#' mean; \code{SE} the standard error of the mean; \code{SD} the standard
#' deviation. \code{CV} the coefficient of variation of the phenotypic means,
#' estimating WAASB, \code{Min} the minimum value observed (returning the
#' genotype and environment), \code{Max} the maximum value observed (returning
#' the genotype and environment); \code{MinENV} the environment with the lower
#' mean, \code{MaxENV} the environment with the larger mean observed,
#' \code{MinGEN} the genotype with the lower mean, \code{MaxGEN} the genotype
#' with the larger.
#'
#' * \strong{ESTIMATES} A tibble with the genetic parameters (if \code{random =
#' "gen"} or \code{random = "all"}) with the following columns: \code{Phenotypic
#' variance} the phenotypic variance; \code{Heritability} the broad-sense
#' heritability; \code{GEr2} the coefficient of determination of the interaction
#' effects; \code{Heribatility of means} the heritability on the mean basis;
#' \code{Accuracy} the selective accuracy; \code{rge} the genotype-environment
#' correlation; \code{CVg} the genotypic coefficient of variation; \code{CVr}
#' the residual coefficient of variation; \code{CV ratio} the ratio between
#' genotypic and residual coefficient of variation.
#'
#'  * \strong{residuals} The residuals of the model.
#' @md
#' @author Tiago Olivoto \email{tiagoolivoto@@gmail.com}
#' @seealso \code{\link{mtsi}} \code{\link{waas}}
#'   \code{\link{get_model_data}} \code{\link{plot_scores}}
#' @export
#' @examples
#' \donttest{
#' library(metan)
#' #===============================================================#
#' # Example 1: Analyzing all numeric variables assuming genotypes #
#' # as random effects                                             #
#' #===============================================================#
#'model <- gamem_met(data_ge,
#'                   env = ENV,
#'                   gen = GEN,
#'                   rep = REP,
#'                   resp = everything())
#' # Distribution of random effects (first variable)
#' plot(model, type = "re")
#'
#' # Genetic parameters
#' get_model_data(model, "genpar")
#'
#'
#'
#' #===============================================================#
#' # Example 2: Unbalanced trials                                  #
#' # assuming all factors as random effects                        #
#' #===============================================================#
#' un_data <- data_ge %>%
#'              remove_rows(1:3) %>%
#'              droplevels()
#'
#'model2 <- gamem_met(un_data,
#'                    env = ENV,
#'                    gen = GEN,
#'                    rep = REP,
#'                    random = "all",
#'                    resp = GY)
#'get_model_data(model2)
#' }
#'
gamem_met <- function(.data,
                  env,
                  gen,
                  rep,
                  resp,
                  block = NULL,
                  random = "gen",
                  prob = 0.05,
                  verbose = TRUE) {
  if (!random %in% c("env", "gen", "all")) {
    stop("The argument 'random' must be one of the 'gen', 'env', or 'all'.")
  }
  block_test <- missing(block)
  if(!missing(block)){
    factors  <- .data %>%
      select({{env}},
             {{gen}},
             {{rep}},
             {{block}}) %>%
      mutate_all(as.factor)
  } else{
    factors  <- .data %>%
      select({{env}},
             {{gen}},
             {{rep}}) %>%
      mutate_all(as.factor)
  }
  vars <- .data %>% select({{resp}}, -names(factors))
  has_text_in_num(vars)
  vars %<>% select_numeric_cols()
  if(!missing(block)){
    factors %<>% set_names("ENV", "GEN", "REP", "BLOCK")
  } else{
    factors %<>% set_names("ENV", "GEN", "REP")
  }
  model_formula <-
    case_when(
      random == "gen" & block_test ~ paste("Y ~ ENV/REP + (1 | GEN) + (1 | GEN:ENV)"),
      random == "env" & block_test ~ paste("Y ~ GEN + (1 | ENV/REP) + (1 | GEN:ENV)"),
      random == "all" & block_test ~ paste("Y ~ (1 | GEN) + (1 | ENV/REP) + (1 | GEN:ENV)"),
      random == "gen" & !block_test ~ paste("Y ~  (1 | GEN) + ENV / REP + (1|BLOCK:(REP:ENV))  + (1 | GEN:ENV)"),
      random == "env" & !block_test ~ paste("Y ~ 0 + GEN + (1| ENV/REP/BLOCK)  + (1 | GEN:ENV)"),
      random == "all" & !block_test ~ paste("Y ~  (1 | GEN) + (1|ENV/REP/BLOCK) + (1 | GEN:ENV)")
    )
  lrt_groups <-
    strsplit(
      case_when(
        random == "gen" & block_test ~ c("COMPLETE GEN GEN:ENV"),
        random == "env" & block_test ~ c("COMPLETE REP(ENV) ENV GEN:ENV"),
        random == "all" & block_test ~ c("COMPLETE GEN REP(ENV) ENV GEN:ENV"),
        random == "gen" & !block_test ~ c("COMPLETE GEN BLOCK(ENV:REP) GEN:ENV"),
        random == "env" & !block_test ~ c("COMPLETE BLOCK(ENV:REP) REP(ENV) ENV GEN:ENV"),
        random == "all" & !block_test ~ c("COMPLETE GEN BLOCK(ENV:REP) REP(ENV) ENV GEN:ENV")
      ), " ")[[1]]
  mod1 <- random == "gen" & block_test
  mod2 <- random == "gen" & !block_test
  mod3 <- random == "env" & block_test
  mod4 <- random == "env" & !block_test
  mod5 <- random == "all" & block_test
  mod6 <- random == "all" & !block_test
  nvar <- ncol(vars)
  listres <- list()
  vin <- 0
  if (verbose == TRUE) {
    pb <- progress_bar$new(
      format = "Evaluating the variable :what [:bar]:percent",
      clear = FALSE, total = nvar, width = 90)
  }
  for (var in 1:nvar) {
    data <- factors %>%
      mutate(Y = vars[[var]])
    if(!is_balanced_trial(data, ENV, GEN, Y) && random == "env"){
      stop("A mixed-effect model with genotype as fixed cannot be fitted with unbalanced data.", call. = FALSE)
    }
    Nenv <- nlevels(data$ENV)
    Ngen <- nlevels(data$GEN)
    Nrep <- nlevels(data$REP)
    minimo <- min(Nenv, Ngen) - 1
    vin <- vin + 1
    ovmean <- mean(data$Y)
    if (minimo < 2) {
      cat("\nWarning. The analysis is not possible.")
      cat("\nThe number of environments and number of genotypes must be greater than 2\n")
    }
    Complete <- suppressWarnings(suppressMessages(lmerTest::lmer(model_formula, data = data)))
    LRT <- suppressWarnings(suppressMessages(lmerTest::ranova(Complete, reduce.terms = FALSE) %>%
                                               mutate(model = lrt_groups) %>%
                                               column_to_first(model)))
    fixed <- anova(Complete)
    var_eff <-
      lme4::VarCorr(Complete) %>%
      as.data.frame() %>%
      select_cols(1, 4) %>%
      arrange(grp) %>%
      rename(Group = grp, Variance = vcov) %>%
      add_cols(Percent = (Variance / sum(Variance)) * 100)
    if(random %in% c("gen", "all")){
      GV <- as.numeric(var_eff[which(var_eff[1] == "GEN"), 2])
      IV <- as.numeric(var_eff[which(var_eff[1] == "GEN:ENV"), 2])
      RV <- as.numeric(var_eff[which(var_eff[1] == "Residual"), 2])
      FV <- sum(var_eff$Variance)
      h2g <- GV/FV
      h2mg <- GV/(GV + IV/Nenv + RV/(Nenv * Nrep))
      GEr2 <- IV/(GV + IV + RV)
      AccuGen <- sqrt(h2mg)
      rge <- IV/(IV + RV)
      CVg <- (sqrt(GV)/ovmean) * 100
      CVr <- (sqrt(RV)/ovmean) * 100
      CVratio <- CVg/CVr
      PROB <- ((1 - (1 - prob))/2) + (1 - prob)
      t <- qt(PROB, 100)
      Limits <- t * sqrt(((1 - AccuGen) * GV))
      genpar <- tibble(Parameters = c("Phenotypic variance", "Heritability", "GEIr2", "Heribatility of means",
                                      "Accuracy", "rge", "CVg", "CVr", "CV ratio"),
                       Values = c(FV, h2g, GEr2, h2mg, AccuGen, rge, CVg, CVr, CVratio))
    } else{
      genpar <- NULL
    }
    bups <- lme4::ranef(Complete)
    bINT <-
      data.frame(Names = rownames(bups$`GEN:ENV`)) %>%
      separate(Names, into = c("GEN", "ENV")) %>%
      add_cols(BLUPge = bups[[1]][[1]]) %>%
      to_factor(1:2)
     Details <- ge_details(data, ENV, GEN, Y) %>%
      add_rows(Parameters = "Ngen", Y = Ngen, .before = 1) %>%
      add_rows(Parameters = "Nenv", Y = Nenv, .before = 1) %>%
      rename(Values = Y)
    if(mod1){
      data_factors <- data %>% select_non_numeric_cols()
      BLUPgen <-
        means_by(data, GEN) %>%
        add_cols(BLUPg = bups$GEN$`(Intercept)`,
                 Predicted = BLUPg + ovmean,
                 Rank = rank(-Predicted),
                 LL = Predicted - Limits,
                 UL = Predicted + Limits) %>%
        arrange(-Predicted) %>%
        column_to_first(Rank)
      BLUPint <-
        left_join(data_factors, bINT, by = c("ENV", "GEN")) %>%
        left_join(BLUPgen, by = "GEN") %>%
        select(ENV, GEN, REP, BLUPg, BLUPge) %>%
        add_cols(`BLUPg+ge` = BLUPge + BLUPg,
                 Predicted = predict(Complete))
      BLUPenv <- NULL
    } else if(mod2){
      data_factors <- data %>% select_non_numeric_cols()
      BLUPgen <-
        means_by(data, GEN) %>%
        add_cols(BLUPg = bups$GEN$`(Intercept)`,
                 Predicted = BLUPg + ovmean,
                 Rank = rank(-Predicted),
                 LL = Predicted - Limits,
                 UL = Predicted + Limits) %>%
        arrange(-Predicted) %>%
        column_to_first(Rank)
      blupBRE <-
        data.frame(Names = rownames(bups$`BLOCK:(REP:ENV)`)) %>%
        separate(Names, into = c("BLOCK", "REP", "ENV")) %>%
        add_cols(BLUPbre = bups$`BLOCK:(REP:ENV)`[[1]]) %>%
        to_factor(1:3)
      BLUPint <-
        left_join(data_factors, bINT, by = c("ENV", "GEN")) %>%
        left_join(BLUPgen, by = "GEN") %>%
        left_join(blupBRE, by = c("ENV", "REP", "BLOCK")) %>%
        select(ENV, REP, BLOCK, GEN, BLUPg, BLUPge, BLUPbre) %>%
        add_cols(`BLUPg+ge+bre` = BLUPge + BLUPg + BLUPbre,
                 Predicted = `BLUPg+ge+bre` + left_join(data_factors, data %>% means_by(ENV, REP), by = c("ENV", "REP"))$Y)
      BLUPenv <- NULL
    } else if (mod3){
      data_factors <- data %>% select_non_numeric_cols()
      BLUPgen <- NULL
      BLUPenv <-
        means_by(data, ENV) %>%
        add_cols(BLUPe =  bups$ENV$`(Intercept)`,
                 Predicted = BLUPe + ovmean) %>%
        arrange(-Predicted) %>%
        add_cols(Rank = rank(-Predicted)) %>%
        column_to_first(Rank)
      blupRWE <-
        data.frame(Names = rownames(bups$`REP:ENV`)) %>%
        separate(Names, into = c("REP", "ENV")) %>%
        add_cols(BLUPre = bups$`REP:ENV`[[1]]) %>%
        to_factor(1:2)
      BLUPint <-
        left_join(data_factors, bINT, by = c("ENV", "GEN")) %>%
        left_join(BLUPenv, by = "ENV") %>%
        left_join(blupRWE, by = c("ENV", "REP")) %>%
        select(ENV, GEN, REP, BLUPe, BLUPge, BLUPre) %>%
        add_cols(`BLUPge+e+re` = BLUPge + BLUPe + BLUPre,
                 Predicted = `BLUPge+e+re` + left_join(data_factors, means_by(data, GEN), by = c("GEN"))$Y)
    } else if (mod4){
      data_factors <- data %>% select_non_numeric_cols()
      BLUPgen <- NULL
      BLUPenv <-
        means_by(data, ENV) %>%
        add_cols(BLUPe =  bups$ENV$`(Intercept)`,
                 Predicted = BLUPe + ovmean) %>%
        arrange(-Predicted) %>%
        add_cols(Rank = rank(-Predicted)) %>%
        column_to_first(Rank)
      blupRWE <-
        data.frame(Names = rownames(bups$`REP:ENV`)) %>%
        separate(Names, into = c("REP", "ENV")) %>%
        add_cols(BLUPre = bups$`REP:ENV`[[1]]) %>%
        to_factor(1:2)
      blupBRE <-
        data.frame(Names = rownames(bups$`BLOCK:(REP:ENV)`)) %>%
        separate(Names, into = c("BLOCK", "REP", "ENV")) %>%
        add_cols(BLUPbre = bups$`BLOCK:(REP:ENV)`[[1]]) %>%
        to_factor(1:3)
      genCOEF <- summary(Complete)[["coefficients"]] %>%
        as_tibble(rownames = NA) %>%
        rownames_to_column("GEN") %>%
        replace_string(GEN, pattern = "GEN", new_var = GEN) %>%
        rename(Y = Estimate) %>%
        to_factor(1)
      BLUPint <-
        left_join(data_factors, bINT, by = c("ENV", "GEN")) %>%
        left_join(BLUPenv, by = "ENV") %>%
        left_join(blupRWE, by = c("ENV", "REP")) %>%
        left_join(blupBRE, by = c("ENV", "REP", "BLOCK")) %>%
        select(ENV, REP, BLOCK, GEN, BLUPe, BLUPge, BLUPre, BLUPbre) %>%
        add_cols(`BLUPe+ge+re+bre` = BLUPge + BLUPe + BLUPre + BLUPbre,
                 Predicted = `BLUPe+ge+re+bre` + left_join(data_factors, genCOEF, by = "GEN")$Y)
    } else if (mod5){
      data_factors <- data %>% select_non_numeric_cols()
      BLUPgen <-
        means_by(data, GEN) %>%
        add_cols(BLUPg = bups$GEN$`(Intercept)`,
                 Predicted = BLUPg + ovmean,
                 Rank = rank(-Predicted),
                 LL = Predicted - Limits,
                 UL = Predicted + Limits) %>%
        arrange(-Predicted) %>%
        column_to_first(Rank)
      BLUPenv <-
        means_by(data, ENV) %>%
        add_cols(BLUPe =  bups$ENV$`(Intercept)`,
                 Predicted = BLUPe + ovmean,
                 Rank = rank(-Predicted)) %>%
        arrange(-Predicted) %>%
        column_to_first(Rank)
      blupRWE <- data.frame(Names = rownames(bups$`REP:ENV`)) %>%
        separate(Names, into = c("REP", "ENV")) %>%
        add_cols(BLUPre = bups$`REP:ENV`[[1]]) %>%
        arrange(ENV) %>%
        to_factor(1:2)
      BLUPint <-
        left_join(data_factors, bINT, by = c("ENV", "GEN")) %>%
        left_join(BLUPgen, by = "GEN") %>%
        left_join(BLUPenv, by = "ENV") %>%
        left_join(blupRWE, by = c("ENV", "REP")) %>%
        select(GEN, ENV, REP, BLUPe, BLUPg, BLUPge, BLUPre) %>%
        add_cols(`BLUPg+e+ge+re` = BLUPge + BLUPe + BLUPg + BLUPre,
                 Predicted = `BLUPg+e+ge+re` + ovmean)
    } else if (mod6){
      data_factors <- data %>% select_non_numeric_cols()
      BLUPgen <-
        means_by(data, GEN) %>%
        add_cols(BLUPg = bups$GEN$`(Intercept)`,
                 Predicted = BLUPg + ovmean,
                 Rank = rank(-Predicted),
                 LL = Predicted - Limits,
                 UL = Predicted + Limits) %>%
        arrange(-Predicted) %>%
        column_to_first(Rank)
      BLUPenv <-
        means_by(data, ENV) %>%
        add_cols(BLUPe =  bups$ENV$`(Intercept)`,
                 Predicted = BLUPe + ovmean,
                 Rank = rank(-Predicted)) %>%
        arrange(-Predicted) %>%
        column_to_first(Rank)
      blupRWE <- data.frame(Names = rownames(bups$`REP:ENV`)) %>%
        separate(Names, into = c("REP", "ENV")) %>%
        add_cols(BLUPre = bups$`REP:ENV`[[1]]) %>%
        arrange(ENV) %>%
        to_factor(1:2)
      blupBRE <-
        data.frame(Names = rownames(bups$`BLOCK:(REP:ENV)`)) %>%
        separate(Names, into = c("BLOCK", "REP", "ENV")) %>%
        add_cols(BLUPbre = bups$`BLOCK:(REP:ENV)`[[1]]) %>%
        to_factor(1:3)
      BLUPint <-
        left_join(data_factors, bINT, by = c("ENV", "GEN")) %>%
        left_join(BLUPgen, by = "GEN") %>%
        left_join(BLUPenv, by = "ENV") %>%
        left_join(blupRWE, by = c("ENV", "REP")) %>%
        left_join(blupBRE, by = c("ENV", "REP", "BLOCK")) %>%
        select(GEN, ENV, REP, BLOCK, BLUPg, BLUPe, BLUPge, BLUPre, BLUPbre) %>%
        add_cols(`BLUPg+e+ge+re+bre` = BLUPg + BLUPge + BLUPe + BLUPre + BLUPbre,
                 Predicted = `BLUPg+e+ge+re+bre` + ovmean)
    }
    residuals <- data.frame(fortify.merMod(Complete))
    residuals$reff <- BLUPint$BLUPge
    temp <- structure(list(fixed = fixed %>% rownames_to_column("SOURCE") %>% as_tibble(),
                           random = var_eff,
                           LRT = LRT,
                           BLUPgen = BLUPgen,
                           BLUPenv = BLUPenv,
                           BLUPint = BLUPint,
                           MeansGxE = means_by(data, ENV, GEN),
                           modellme = Complete,
                           Details = as_tibble(Details),
                           ESTIMATES = genpar,
                           residuals = as_tibble(residuals)), class = "waasb")
    if (verbose == TRUE) {
      pb$tick(tokens = list(what = names(vars[var])))
    }
    listres[[paste(names(vars[var]))]] <- temp
  }
  if (verbose == TRUE) {
    cat("Model: ", model_formula, "\n")
    cat("---------------------------------------------------------------------------\n")
    cat("P-values for Likelihood Ratio Test of the analyzed traits\n")
    cat("---------------------------------------------------------------------------\n")
    print.data.frame(sapply(listres, function(x){
      x$LRT[["Pr(>Chisq)"]]
    }) %>%
      as.data.frame() %>%
      add_cols(model = listres[[1]][["LRT"]][["model"]]) %>%
      column_to_first(model), row.names = FALSE, digits = 3)
    cat("---------------------------------------------------------------------------\n")
    if (length(which(unlist(lapply(listres, function(x) {
      x[["LRT"]] %>% dplyr::filter(model == "GEN:ENV") %>% pull(`Pr(>Chisq)`)
    })) > prob)) > 0) {
      cat("Variables with nonsignificant GxE interaction\n")
      cat(names(which(unlist(lapply(listres, function(x) {
        x[["LRT"]][which(x[["LRT"]][[1]] == "GEN:ENV"), 7]
      })) > prob)), "\n")
      cat("---------------------------------------------------------------------------\n")
    } else {
      cat("All variables with significant (p < 0.05) genotype-vs-environment interaction\n")
    }
  }
  invisible(set_class(listres, "waasb"))
}
