% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utilities.R
\name{utils_num_str}
\alias{utils_num_str}
\alias{all_upper_case}
\alias{all_lower_case}
\alias{all_title_case}
\alias{extract_number}
\alias{extract_string}
\alias{find_text_in_num}
\alias{has_text_in_num}
\alias{remove_space}
\alias{remove_strings}
\alias{replace_number}
\alias{replace_string}
\alias{round_cols}
\alias{tidy_strings}
\title{Utilities for handling with numbers and strings}
\usage{
all_upper_case(.data, ...)

all_lower_case(.data, ...)

all_title_case(.data, ...)

extract_number(
  .data,
  var,
  new_var = new_var,
  drop = FALSE,
  pull = FALSE,
  .before = NULL,
  .after = NULL
)

extract_string(
  .data,
  var,
  new_var = new_var,
  drop = FALSE,
  pull = FALSE,
  .before = NULL,
  .after = NULL
)

find_text_in_num(.data, ...)

has_text_in_num(.data)

remove_space(.data, ...)

remove_strings(.data, ...)

replace_number(
  .data,
  var,
  new_var = new_var,
  pattern = NULL,
  replacement = "",
  drop = FALSE,
  pull = FALSE,
  .before = NULL,
  .after = NULL
)

replace_string(
  .data,
  var,
  new_var = new_var,
  pattern = NULL,
  replacement = "",
  ignore_case = FALSE,
  drop = FALSE,
  pull = FALSE,
  .before = NULL,
  .after = NULL
)

round_cols(.data, ..., digits = 2)

tidy_strings(.data, ..., sep = "_")
}
\arguments{
\item{.data}{A data frame}

\item{...}{The argument depends on the function used.
\itemize{
\item For \code{round_cols()} \code{...} are the variables to round. If no
variable is informed, all the numeric variables from \code{data} are used.
\item For \code{all_lower_case()}, \code{all_upper_case()},
\code{all_title_case()}, \code{remove_strings()}, and \code{tidy_strings()}
\code{...} are the variables to apply the function. If no variable is
informed, the function will be applied to all non-numeric variables in
\code{.data}.
}}

\item{var}{The variable to extract or replace numbers or strings.}

\item{new_var}{The name of the new variable containing the numbers or
strings extracted or replaced. Defaults to \code{new_var}.}

\item{drop}{Logical argument. If \code{TRUE} keeps the new variable
\code{new_var} and drops the existing ones. Defaults to \code{FALSE}.}

\item{pull}{Logical argument. If \code{TRUE}, returns the last column (on the
assumption that's the column you've created most recently), as a vector.}

\item{.before, .after}{For \code{replace_sting()}, \code{replace_number()},
\code{extract_string()}, ,and  \code{extract_number()} one-based column
index or column name where to add the new columns.}

\item{pattern}{A string to be matched. Regular Expression Syntax is also
allowed.}

\item{replacement}{A string for replacement.}

\item{ignore_case}{If \code{FALSE} (default), the pattern matching is case
sensitive and if \code{TRUE}, case is ignored during matching.}

\item{digits}{The number of significant figures.}

\item{sep}{A character string to separate the terms. Defaults to "_".}
}
\description{
\itemize{
\item \code{all_lower_case()}: Translate all non-numeric strings of a data frame
to lower case (
\code{"Env"} to \code{"env"}).
\item \code{all_upper_case()}: Translate all non-numeric strings of a data frame
to upper case (e.g., \code{"Env"} to \code{"ENV"}).
\item \code{all_title_case()}: Translate all non-numeric strings of a data frame
to title case (e.g., \code{"ENV"} to \code{"Env"}).
\item \code{extract_number()}: Extract the number(s) of a string.
\item \code{extract_string()}: Extract all strings, ignoring case.
\item \code{find_text_in_num()}: Find text characters in a numeric sequence and
return the row index.
\item \code{has_text_in_num()}: Inspect columns looking for text in numeric
sequence and return a warning if text is found.
\item \code{remove_space()}: Remove all blank spaces of a string.
\item \code{remove_strings()}: Remove all strings of a variable.
\item \code{replace_number()}: Replace numbers with a replacement.
\item \code{replace_string()}: Replace all strings with a replacement, ignoring
case.
\item \code{round_cols()}: Round a selected column or a whole data frame to
significant figures.
\item \code{tidy_strings()}: Tidy up characters strings, non-numeric columns, or
any selected columns in a data frame by putting all word in upper case,
replacing any space, tabulation, punctuation characters by \code{'_'}, and
putting \code{'_'} between lower and upper case. Suppose that \code{str =
c("Env1", "env 1", "env.1")} (which by definition should represent a unique
level in plant breeding trials, e.g., environment 1) is subjected to
\code{tidy_strings(str)}: the result will be then \code{c("ENV_1", "ENV_1",
"ENV_1")}. See Examples section for more examples.
}
}
\examples{
\donttest{
library(metan)

################ Rounding numbers ###############
# All numeric columns
round_cols(data_ge2, digits = 1)

# Round specific columns
round_cols(data_ge2, EP, digits = 1)

########### Extract or replace numbers ##########
# Extract numbers
extract_number(data_ge, GEN)
extract_number(data_ge,
               var = GEN,
               drop = TRUE,
               new_var = g_number)

# Replace numbers

replace_number(data_ge, GEN)
replace_number(data_ge,
               var = GEN,
               pattern = "1",
               replacement = "_one",
               pull = TRUE)

########## Extract, replace or remove strings ##########
# Extract strings
extract_string(data_ge, GEN)
extract_string(data_ge,
               var = GEN,
               drop = TRUE,
               new_var = g_name)

# Replace strings
replace_string(data_ge, GEN)
replace_string(data_ge,
               var = GEN,
               new_var = GENOTYPE,
               pattern = "G",
               replacement = "GENOTYPE_")

# Remove strings
remove_strings(data_ge)
remove_strings(data_ge, ENV)


############ Find text in numeric sequences ###########
mixed_text <- data_ge
mixed_text[2, 4] <- "2..503"
mixed_text[3, 4] <- "3.2o75"
find_text_in_num(mixed_text, GY)

############# upper, lower and title cases ############
gen_text <- c("GEN 1", "Gen 1", "gen 1")
all_lower_case(gen_text)
all_upper_case(gen_text)
all_title_case(gen_text)

# A whole data frame
all_lower_case(data_ge)


############### Tidy up messy text string ##############
messy_env <- c("ENV 1", "Env   1", "Env1", "env1", "Env.1", "Env_1")
tidy_strings(messy_env)

messy_gen <- c("GEN1", "gen 2", "Gen.3", "gen-4", "Gen_5", "GEN_6")
tidy_strings(messy_gen)

messy_int <- c("EnvGen", "Env_Gen", "env gen", "Env Gen", "ENV.GEN", "ENV_GEN")
tidy_strings(messy_int)

# Or a whole data frame
library(tibble)
df <- tibble(Env = messy_env,
             gen = messy_gen,
             Env_GEN = interaction(Env, gen),
             y = rnorm(6, 300, 10))
df
tidy_strings(df)
}
}
\author{
Tiago Olivoto \email{tiagoolivoto@gmail.com}
}
