library(rvest)
library(tidyverse)
library(tm)

# page delay when scraping multiple pages on site
# when checking patch.com's robots.txt they did not have a delay preference listed
scrape.delay <- 3

#########################################
# greensboro.com local news scraper
#########################################

# shows 25 links at a time, with first number being 0
url.begin <- "https://greensboro.com/search/?t=article%2Clink%2Cyoutube%2Ccollection%2Cvideo&s=start_time&sd=desc&l=25&o="
url.end <- "&nsa=eedition&nfl=advertorial%2Ccontributedap&c=news%2Flocal%2A&app%5B0%5D=editorial"

# number of pages needed to get a year of local news history for greensboro
total.pages <- 5600
total.pages <- total.pages/25
current.page <- 0

# approximate run time
total.pages * scrape.delay / 60

# empty vector for scrape.list
scrape.list <- vector()

# for loop that iterates across multiple pages on patch greensboro
for (i in 1:total.pages) {

  # using the past function to scrape a list from each page of greensboro list
  main.url <- read_html(paste(url.begin, current.page, url.end, sep=""))

  # pull the href from each link of interest on the page
  scrape.page <- html_nodes(main.url, 'h3 a') %>%
    html_attr("href")

  # add the list of hrefs from page to scrape.list
  scrape.list <- c(scrape.list, scrape.page)

  # increase current.page by 25
  current.page <- current.page + 25

  # pause scraper for 3 seconds before visiting and scraping next page
  Sys.sleep(scrape.delay)
}

# remove redundant URLs
scrape.list <- unique(scrape.list)

# main page url
main.page <- 'https://greensboro.com'

# combines the data scraped from the link href URLs with the missing 'https:greensboro.com' to create complete URLs
for (i in seq_along(scrape.list[597:5575])) {
  scrape.list[i] <- paste0(main.page, scrape.list[i])
}

# empty vector to collect page text
page.text <- vector()

# empty vector to collect page date
page.date <- vector()

# empty vector to collect author name
author.name <- vector()

# The for loop visits each URL in scrape.list and then collects the text content from each page, creating a new list
for (i in seq_along(scrape.list)) {
  new.url <- read_html(scrape.list[i])

  #Collects text content from pages
  text.add <- html_nodes(new.url, '.lee-article-text p') %>%
    html_text()

  #Collapses all the separate <p> text content into one string of text
  text.add <- paste(text.add, collapse=" ")

  #Collects the date from pages
  date.add <- html_nodes(new.url, xpath='//*[contains(concat( " ", @class, " " ), concat( " ", "hidden-print", " " ))]//*[contains(concat( " ", @class, " " ), concat( " ", "asset-date", " " ))]') %>%
    html_attr("datetime")

  author.add <- html_nodes(new.url, xpath='//*[(@id = "asset-content")]//*[contains(concat( " ", @class, " " ), concat( " ", "asset-byline", " " ))]//a') %>%
    html_text()

  author.add <- gsub("\r?\n|\r", " ", author.add) %>%
    stripWhitespace()

  author.name <- c(author.name, author.add)
  page.text <- c(page.text, text.add)
  page.date <- c(page.date, date.add)

  # pause scraper for 3 seconds before visiting and scraping next page
  Sys.sleep(scrape.delay)
}

#########################################
# newsbreadk.com local news scraper
#########################################

# archive urls
archive.urls <- c('https://www.newsbreak.com/north-carolina/greensboro/archives/2020-02',
                  'https://www.newsbreak.com/north-carolina/greensboro/archives/2020-03',
                  'https://www.newsbreak.com/north-carolina/greensboro/archives/2020-04',
                  'https://www.newsbreak.com/north-carolina/greensboro/archives/2020-05',
                  'https://www.newsbreak.com/north-carolina/greensboro/archives/2020-06',
                  'https://www.newsbreak.com/north-carolina/greensboro/archives/2020-07',
                  'https://www.newsbreak.com/north-carolina/greensboro/archives/2020-08',
                  'https://www.newsbreak.com/north-carolina/greensboro/archives/2020-09',
                  'https://www.newsbreak.com/north-carolina/greensboro')

# part of URL that selects page number in archive
page.select <- "?page="

# empty vector for scrape.list
scrape.list <- vector()

# for loop that iterates across multiple pages on patch greensboro
for (i in seq_along(archive.urls)) {

  # using the past function to scrape a list from each page of greensboro list
  main.url <- read_html(paste(archive.urls[i], page.select, "1", sep=""))

  # pull the href from each link of interest on the page
  scrape.page <- html_nodes(main.url, '.SummaryCard_wrapper__3GtTZ') %>%
    html_attr("href")

  # add the list of hrefs from page to scrape.list
  scrape.list <- c(scrape.list, scrape.page)

  # pause scraper for 3 seconds before visiting and scraping next page
  Sys.sleep(scrape.delay)

  # sets page number counter for while loop
  page.num <- 2

  # loop that
  while (identical(scrape.page, character(0))==FALSE) {
    main.url <- read_html(paste(archive.urls[i], page.select, page.num, sep=""))
    scrape.page <- html_nodes(main.url, '.SummaryCard_wrapper__3GtTZ') %>%
      html_attr("href")
    scrape.list <- c(scrape.list, scrape.page)
    page.num <- page.num + 1
    Sys.sleep(scrape.delay)
  }
}

##################################################################
# add in functionality to remove lines of data with complete URLs
# because these lines direct to other sites rather
##################################################################

# main page url
main.page <- 'https://www.newsbreak.com'

# combines the data scraped from the link href URLs with the missing 'https:greensboro.com' to create complete URLs
for (i in seq_along(scrape.list)) {
  scrape.list[i] <- paste0(main.page, scrape.list[i])
}

write.csv(scrape.list, file="newsbreak-urls.csv")

# Using tibble, the list of URLs is combined with the text scraped from each URL
# to create a dataframe for our combined dataset
scrape.data <- tibble('url'=scrape.list, 'date'=page.date, 'text'=page.text)

# Save dataframe as a CSV file
write.csv(scrape.data, 'gboro_patch.csv')
