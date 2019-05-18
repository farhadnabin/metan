#' Weighted Average of Absolute Scores
#'
#' Compute the Weighted Average of Absolute Scores for AMMI analysis.
#'
#' This function compute the weighted average of absolute scores, estimated as
#' follows:
#'
#' \deqn{ WAAS_i = \sum_{k = 1}^{p} |IPCA_{ik} \times EP_k|/ \sum_{k =
#' 1}^{p}EP_k}
#'
#' where \eqn{WAAS_i} is the weighted average of absolute scores of the
#' \emph{i}th genotype; \eqn{PCA_{ik}} is the score of the \emph{i}th genotype
#' in the \emph{k}th IPCA; and \eqn{EP_k} is the explained variance of the
#' *k*th IPCA for \emph{k = 1,2,..,p}, considering \emph{p} the number of
#' significant PCAs, or a declared number of PCAs. For example if \code{prob =
#' 0.05}, all axis that are significant considering this probability level are
#' used. The number of axis can be also informed by declaring \code{naxis = x}.
#' This comand ignores the \code{prob} argument.
#'
#' @param .data The dataset containing the columns related to Environments,
#' Genotypes, replication/block and response variable(s).
#' @param env The name of the column that contains the levels of the
#' environments.
#' @param gen The name of the column that contains the levels of the genotypes.
#' @param rep The name of the column that contains the levels of the
#' replications/blocks.
#' @param resp The response variable(s). To analyze multiple variables in a
#' single procedure a vector of variables may be used. For example \code{resp =
#' c(var1, var2, var3)}.
#' @param mresp A numeric vector of the same length of \code{resp}. The
#' \code{mresp} will be the new maximum value after reescaling. By default, all
#' variables in \code{resp} are rescaled so that de maximum value is 100 and
#' the minimum value is 0.
#' @param wresp The weight for the response variable(s) for computing the
#' WAASBY index. Must be a numeric vector of the same length of \code{resp}.
#' Defatul is 50, i.e., equal weights for stability and mean performance.
#' @param prob The p-value for considering an interaction principal component axis significant.
#' @param naxis The number of IPCAs to be used for computing the WAAS index.
#' Default is \code{NULL} (Significant IPCAs are used). If values are informed,
#' the number of IPCAS will be used independently on its significance. Note
#' that if two or more variables are included in \code{resp}, then \code{naxis}
#' must be a vector.
#' @param verbose Logical argument. If \code{verbose = FALSE} the code is run
#' silently.
#' @return
#'
#' \item{individual}{A within-environments ANOVA considering a fixed-effect
#' model.}
#'
#' \item{model}{A data frame with the response variable, the scores of all
#' Principal Components, the estimates of Weighted Average of Absolute Scores,
#' and WAASY (the index that consider the weights for stability and
#' productivity in the genotype ranking.}
#'
#' \item{MeansGxE}{The means of genotypes in the environments, with observed,
#' predicted and residual values.}
#'
#' \item{PCA}{Principal Component Analysis.}
#'
#' \item{anova}{Joint analysis of variance for the main effects and Principal
#' Component analysis of the interaction effect.}
#'
#' \item{Details}{A list summarizing the results. The following information are
#' showed. \code{WgtResponse}, the weight for the response variable in
#' estimating WAASB, \code{WgtWAAS} the weight for stability, \code{Ngen} the
#' number of genotypes, \code{Nenv} the number of environments, \code{OVmean}
#' the overall mean, \code{Min} the minimum observed (returning the genotype
#' and environment), \code{Max} the maximum observed, \code{Max} the maximum
#' observed, \code{MinENV} the environment with the lower mean, \code{MaxENV}
#' the environment with the larger mean observed, \code{MinGEN} the genotype
#' with the lower mean, \code{MaxGEN} the genotype with the larger.}
#' @author Tiago Olivoto \email{tiagoolivoto@@gmail.com}
#' @seealso \code{\link{waas}}
#' @export
#' @examples
#'
#' library(metan)
#'
#' # Considering p-value <= 0.05 to compute the WAAS
#'
#' model <- waas(data_ge,
#'                   env = ENV,
#'                   gen = GEN,
#'                   rep = REP,
#'                   resp = GY)
#'
#'
#' # Declaring the number of axis to be used for computing WAAS
#' # and assigning a larger weight for the response variable when
#' # computing the WAASBY index.
#'
#' model2 <- waas(data_ge,
#'                     env = ENV,
#'                     gen = GEN,
#'                     rep = REP,
#'                     resp = GY,
#'                     naxis = 3,
#'                     wresp = 60)
#'
#' # Analyzing multiple variables (GY and HM) at the same time
#' # considering that smaller values of HM are better and higher
#' # values of GY are better, assigning a larger weight for the GY
#' # and a smaller weight for HM when computing WAASBY index.
#'
#' model3 <- waas(data_ge,
#'                   env = ENV,
#'                   gen = GEN,
#'                   rep = REP,
#'                   resp = c(GY, HM),
#'                   mresp = c(100, 0),
#'                   wresp = c(60, 40))
#'
#'
waas <- function(.data, env, gen, rep, resp, mresp = NULL, wresp = NULL, prob = 0.05,
    naxis = NULL, verbose = TRUE) {
    d <- match.call()
    nvar <- as.numeric(ifelse(length(d$resp) > 1, length(d$resp) - 1, length(d$resp)))
    if (!is.null(naxis)) {
        if (length(d$resp) > 1) {
            if (length(naxis) != length(d$resp) - 1) {
                stop("The argument 'naxix' must length of ", nvar, ", the same number of variables in object 'resp'.")
            }
        } else {
            if (length(naxis) != length(d$resp)) {
                stop("The argument 'naxix' must length of ", nvar, ", the same number of variables in object 'resp'.")
            }
        }
    }
    if (is.null(mresp)) {
        mresp <- replicate(nvar, 100)
        minresp <- 100 - mresp
    } else {
        if (length(mresp) != nvar) {
            stop("The length of the numeric vector 'mresp' must be equal the number of variables in argument 'resp'")
        }
        if (sum(mresp == 100) + sum(mresp == 0) != nvar) {
            stop("The values of the numeric vector 'mresp' must be 0 or 100.")
        }
        mresp <- mresp
        minresp <- 100 - mresp
    }
    if (is.null(wresp)) {
        PesoResp <- replicate(nvar, 50)
        PesoWAASB <- 100 - PesoResp
    } else {
        if (length(wresp) != nvar) {
            stop("The length of the numeric vector 'wresp' must be equal the number of variables in argument 'resp'")
        }
        if (min(wresp) < 0 | max(wresp) > 100) {
            stop("The range of the numeric vector 'wresp' must be equal between 0 and 100.")
        }
        PesoResp <- wresp
        PesoWAASB <- 100 - PesoResp
    }
    datain <- .data
    GEN <- factor(eval(substitute(gen), eval(datain)))
    ENV <- factor(eval(substitute(env), eval(datain)))
    REP <- factor(eval(substitute(rep), eval(datain)))
    listres <- list()
    vin <- 0
    for (var in 2:length(d$resp)) {
        if (length(d$resp) > 1) {
            Y <- eval(substitute(resp)[[var]], eval(datain))
        } else {
            Y <- eval(substitute(resp), eval(datain))
        }
        data <- data.frame(ENV, GEN, REP, Y)
        Nenv <- length(unique(ENV))
        Ngen <- length(unique(GEN))
        minimo <- min(Nenv, Ngen) - 1
        vin <- vin + 1
        if (minimo < 2) {
            cat("\nWarning. The analysis is not possible.")
            cat("\nThe number of environments and number of genotypes must be greater than 2\n")
        }
        individual <- data %>% anova_ind(ENV, GEN, REP, Y)
        model <- performs_ammi(data, ENV, GEN, REP, Y)
        anova <- model$ANOVA
        PC <- model$analysis
        MeansGxE <- model$means[, 1:3]
        Escores <- model$biplot
        EscGEN <- subset(Escores, type == "GEN")
        names(EscGEN)[2] <- "GEN"
        names(EscGEN)[3] <- "y"
        EscENV <- subset(Escores, type == "ENV")
        names(EscENV)[2] <- "ENV"
        MeansGxE <- suppressMessages(suppressWarnings(dplyr::mutate(MeansGxE, envPC1 = left_join(MeansGxE,
            EscENV %>% select(ENV, PC1))$PC1, genPC1 = left_join(MeansGxE, EscGEN %>%
            select(GEN, PC1))$PC1, nominal = left_join(MeansGxE, EscGEN %>% select(GEN,
            y))$y + genPC1 * envPC1)))
        if (is.null(naxis)) {
            SigPC1 <- nrow(PC[which(PC[, 5] < prob), ])
        } else {
            if (nvar == 1) {
                SigPC1 <- naxis
            } else {
                SigPC1 <- naxis[vin]
            }
        }
        if (SigPC1 > minimo) {
            stop("The number of axis to be used must be lesser than or equal to ",
                minimo, " [min(GEN-1;ENV-1)]")
        } else {
            Pesos <- slice(model$analysis[6], 1:SigPC1)
            WAAS <- Escores %>%
                select(contains("PC")) %>%
                abs() %>%
                t() %>%
                as.data.frame() %>%
                slice(1:SigPC1) %>%
                mutate(Percent = Pesos$Percent)
            WAASAbs <- mutate(Escores, WAAS = sapply(WAAS[, -ncol(WAAS)], weighted.mean, w = WAAS$Percent))
            if (nvar > 1) {
                WAASAbs %<>%
                    group_by(type) %>%
                    mutate(PctResp = (mresp[vin] - minresp[vin])/(max(Y) - min(Y)) * (Y - max(Y)) + mresp[vin],
                           PctWAAS = (minresp[vin] - mresp[vin])/(max(WAAS) - min(WAAS)) * (WAAS - max(WAAS)) + minresp[vin],
                           PesRes = PesoResp[vin],
                           PesWAAS = PesoWAASB[vin],
                           OrResp = rank(-Y),
                           OrWAAS = rank(WAAS),
                           OrPC1 = rank(abs(PC1)),
                           WAASY = ((PctResp * PesRes) + (PctWAAS * PesWAAS))/(PesRes + PesWAAS),
                           OrWAASY = rank(-WAASY))
            } else {
                WAASAbs %<>%
                    group_by(type) %>%
                    mutate(PctResp = (mresp - minresp)/(max(Y) - min(Y)) * (Y - max(Y)) + mresp,
                           PctWAAS = (minresp - mresp)/(max(WAAS) - min(WAAS)) * (WAAS - max(WAAS)) + minresp,
                           PesRes = PesoResp,
                           PesWAAS = PesoWAASB,
                           OrResp = rank(-Y),
                           OrWAAS = rank(WAAS),
                           OrPC1 = rank(abs(PC1)),
                           WAASY = ((PctResp * PesRes) + (PctWAAS * PesWAAS))/(PesRes + PesWAAS),
                           OrWAASY = rank(-WAASY))
            }
    min_group = Escores %>% group_by(type) %>% top_n(1, -Y) %>% select(type, Code, Y) %>% slice(1)
    max_group = Escores %>% group_by(type) %>% top_n(1, Y) %>% select(type, Code, Y) %>% slice(1)
    min = MeansGxE %>% top_n(1, -Y) %>% select(ENV, GEN, Y) %>% slice(1)
    max = MeansGxE %>% top_n(1, Y) %>% select(ENV, GEN, Y) %>% slice(1)
    Details <- list(Ngen = Ngen,
                    Nenv = Nenv,
                    OVmean = round(mean(MeansGxE$Y), 4),
                    Min = paste0(round(min[3], 4), " (Genotype ", min$GEN, " in ", min$ENV,")"),
                    Max = paste0(round(max$Y, 4), " (Genotype ", max$GEN, " in ", max$ENV,")"),
                    MinENV = paste0("Environment ", min_group[2,2], " (", round(min_group[2,3], 3),")"),
                    MaxENV = paste0("Environment ", max_group[2,2], " (", round(max_group[2,3], 3),")"),
                    MinGEN = paste0("Genotype ", min_group[1,2], " (", round(min_group[1,3], 3), ") "),
                    MaxGEN =  paste0("Genotype ", max_group[1,2], " (", round(max_group[1,3], 3), ") "),
                    SigPC = SigPC1)
    Details <- do.call(rbind.data.frame, Details)
    names(Details) <- "Values"
    Details <- dplyr::mutate(Details, Parameters = c("Ngen", "Nenv", "OVmean",
                                                     "Min", "Max", "MinENV", "MaxENV", "MinGEN", "MaxGEN", "SigPC"))%>%
        dplyr::select(Parameters, everything())

    temp <- structure(list(individual = individual[[1]], model = WAASAbs, MeansGxE = MeansGxE,
                           PCA = PC, anova = anova, Details = Details, residuals = model$residuals,
                           probint = model$probint), class = "waas")

            if (length(d$resp) > 1) {
                listres[[paste(d$resp[var])]] <- temp
                if (verbose == TRUE) {
                  cat("Evaluating variable", paste(d$resp[var]), round((var - 1)/(length(d$resp) -
                    1) * 100, 1), "%", "\n")
                }
            } else {
                listres[[paste(d$resp)]] <- temp
            }
        }
    }
    if (verbose == T) {
        if (length(which(unlist(lapply(listres, function(x) {
            x[["probint"]]
        })) > prob)) > 0) {
            cat("------------------------------------------------------------\n")
            cat("Variables with nonsignificant GxE interaction\n")
            cat(names(which(unlist(lapply(listres, function(x) {
                x[["probint"]]
            })) > prob)), "\n")
            cat("------------------------------------------------------------\n")
        }
        cat("Done!\n")
    }
    invisible(structure(listres, class = "waas"))

}
