#' A dataset including all contents published on the English-language version of [kremlin.ru
#'
#' A dataset with 24 338 textual items.
#'
#' @format A data frame with 24338 rows and 8 columns:
#' \describe{
#'   \item{doc_id}{the id is a composed string, that should make the identifier unique even when used together with other similarly shaped datasets. Elements are separated by a an [hyphen-minus](https://en.wikipedia.org/wiki/Hyphen-minus). A an example `doc_id` would be `president_ru-en-012345`.}
#'   \item{text}{this includes the full text of the document, *including* the title and the textual string with date and location (when present). }
#'   \item{date}{date of publication in the date format.}
#'   \item{title}{the title of the document}
#'   \item{location}{the location from where the document was issued as reported at the beginning of each post, e.g. "Novo-Ogaryovo, Moscow Region"; if not given, an empty string.}
#'   \item{link}{a URL, source of the document}
#'   \item{id}{numeric id; includes only the numeric part of `doc_id`, may be useful if only a numeric identifier is needed.}
#'   \item{term}{a character string referring to the presidential term. The period after Yeltsin's resignation, but before Putin's first inauguration in May 2000 is indicated as "Putin 0", the following as "Putin 1", "Putin 2", "Medvedev 1", "Putin 3", and "Putin 4"}
#' }
#' @source \url{http://en.kremlin.ru/}
"kremlin_en"
