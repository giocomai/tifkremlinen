#### 1. Preliminary steps ####

## Install castarter (remotes required for installing from github)
# install.packages("remotes")
#remotes::install_github(repo = "giocomai/castarter")

## Load castarter
library("castarter")

## Set project and website name.
# They will remain in memory in the current R session,
# so need need to include them in each function call.
SetCastarter(project = "presidents_en", website = "russia")

## Creates the folder structure where files will be saved within the
## current working directory
CreateFolders()

#### 2. Download index/archive pages ####

# Check out the archive page, e.g. http://en.special.kremlin.ru/events/president/news
# See what is the last archive page, if they are defined by consecutive numbers

indexLinks <- CreateLinks(linkFirstChunk = "http://en.special.kremlin.ru/events/president/news/page/",
                          startPage = 1,
                          endPage = 1221)

## Downloads all html files of the archive pages
# This can be interrupted: by default, if the command is issued again it will download only missing pages (i.e. pages that have not been downloaded previously)
castarter::DownloadContents(links = indexLinks,
                            type = "index")


# Downloads again files with oddly small size (usually, errors), if any.
DownloadContents(links = indexLinks, type = "index", missingPages = FALSE)

#### 3. Extract links to individual pages ####

# Find criteria to filter only direct links to news items
# Open an archive page at random.
# browseURL(url = sample(x = indexLinks, size = 1))

links <- ExtractLinks(domain = "http://en.special.kremlin.ru",
                      partOfLink = "events/president/news",
                      partOfLinkToExclude = c("page",
                                              "photos",
                                              "videos",
                                              "special",
                                              "http"),
                      minLength = 50)

## check:
tibble::tibble(link = links) %>%
  dplyr::mutate(nchar = nchar(links)) %>%
  dplyr::arrange(nchar)

# length(links)/length(indexLinks)
# Explore links and check if more or less alright, if number realistic
# View(links)
# head(links)

#### 4. Download pages ####


DownloadContents(links = links, wait = 3)
DownloadContents(links = links, missingPages = FALSE, wait = 3)

#### 5. Extract metadata and text ####

# open an article at random to find out where metadata are located
# browseURL(url = sample(x = links, size = 1))

id <- ExtractId()

titles <- ExtractTitles(container = "h2",
                        containerInstance = 4,
                        id = id)


dates <- ExtractDates(dateFormat = "Bd,Y",
                      container = "p",
                      containerClass = "published",
                      language = "english",
                      containerInstance = 1,
                      id = id)
head(titles)
head(dates)
head(links[id])

# check how many dates were not captured
sum(is.na(dates))
links[is.na(dates)]

language <- "english"

metadata <- ExportMetadata(id = id,
                           dates = dates,
                           titles = titles,
                           language = language,
                           links = links)

## Extract text
text <- ExtractText(container = "div",
                    containerClass = "singlepost",
                    #  subElement = "p",
                    id = id,
                    exportParameters = FALSE)

i <- sample(x = 1:length(text), 1)
titles[i]
dates[i]
text[i]
links[id][i]


#### 6. Save and export ####
SaveWebsite(dataset = TRUE)

location_date <- ExtractText(container = "p",
                             containerClass = "published",
                             containerInstance = 1,
                             id = id)
location <-  location_date %>%
  stringr::str_remove("^.*[[:digit:]]{4}") %>%
  stringr::str_remove(", ") %>%
  stringr::str_squish()



HtmlFiles <- fs::path("castarter",
                      "presidents_en",
                      "russia",
                      "Html",
                      paste0(id, ".html"))
########################

text <- purrr::map_chr(.x = HtmlFiles, .f = function(x) {
  xml2::read_html(x) %>%
    rvest::html_nodes(xpath = paste0("//div[@class='singlepost']")) %>%
    rvest::html_nodes("p") %>%
    .[-1:-2] %>%
    rvest::html_text() %>%
    paste(collapse = "~~~newline~~~") %>%
    iconv(to = "UTF-8")  %>%
    stringr::str_replace_all(pattern = "\\n", replacement = " ") %>%
    stringr::str_replace_all(pattern = "  ", replacement = " ") %>%
    stringr::str_replace_all(pattern = stringr::fixed("~~~newline~~~"), replacement = "\n")

})

text_combo <- stringr::str_c(titles, location_date, text,
                             sep = "\n\n")

actual_id <- links %>% stringr::str_extract(pattern = "[[:digit:]]+$") %>% as.numeric()



dataset <- tibble::tibble(doc_id = stringr::str_c("president_ru-en-",
                                                  stringr::str_pad(string = actual_id,
                                                                   width = 6,
                                                                   side = "left",
                                                                   pad = "0")),
                          text = text_combo,
                          date = dates,
                          title = titles,
                          location = location,
                          link = links,
                          id = actual_id) %>%
  dplyr::filter(date<as.Date("2021-01-01")) %>%
  dplyr::mutate(term = dplyr::case_when(date<as.Date("2000-05-07") ~ "Putin 0",
                                        date<as.Date("2004-05-07") ~ "Putin 1",
                                        date<as.Date("2008-05-07") ~ "Putin 2",
                                        date<as.Date("2012-05-07") ~ "Medvedev 1",
                                        date<as.Date("2018-05-07") ~ "Putin 3",
                                        date<as.Date("2024-05-07") ~ "Putin 4")) %>%
  dplyr::arrange(date)

kremlin_en <- dataset

usethis::use_data(kremlin_en, overwrite = TRUE)

