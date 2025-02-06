# prep -------------------------------------------------------------------------
library(clipr)
library(rvest)
library(tidyverse)

# name for data frames is:
# Lead or Supporting
# Female or Male
# Comedy or Drama or Limited

# dropped 1965, since awards weren't gendered
# years where it wasn't broken out by genre
no_genre <- c(1954:1958, 1960:1965)

clean_year <- function(x) {
  x %>% 
    str_sub(1, 4) %>% 
    as.numeric() # characters will parse as NA, which we want
}

clean_name <- function(x) {
  x %>% 
    str_remove_all("[\\[(†‡§#].*") %>% 
    trimws() %>% 
    tolower()
}

# lead actress -----------------------------------------------------------------
## comedy ----------------------------------------------------------------------
dat_lfc <- "https://en.wikipedia.org/wiki/Primetime_Emmy_Award_for_Outstanding_Lead_Actress_in_a_Comedy_Series" %>% 
  read_html() %>% 
  html_table() %>% 
  `[`(2:9) %>% # hard-coded, may not replicate in future
  list_rbind() %>% 
  select(1:4) %>% 
  `names<-`(c("year", "name", "role", "program")) %>% 
  mutate(
    year = clean_year(year),
    across(name:program, clean_name)
  ) %>%
  filter(
    !is.na(year) & 
      !is.na(name) & 
      year != 1965 &
      !year %in% no_genre # include these in drama, not comedy
  ) %>% 
  group_by(year) %>% 
  mutate(winner = c(1, rep(0, n() - 1)))

any(no_genre %in% dat_lfc$year)

## drama -----------------------------------------------------------------------
dat_lfd <- "https://en.wikipedia.org/wiki/Primetime_Emmy_Award_for_Outstanding_Lead_Actress_in_a_Drama_Series" %>% 
  read_html() %>% 
  html_table() %>% 
  `[`(3:10) %>% # hard-coded, may not replicate in future
  list_rbind() %>% 
  select(1:4) %>% 
  `names<-`(c("year", "name", "role", "program")) %>% 
  mutate(
    year = clean_year(year),
    across(name:program, clean_name)
  ) %>%
  filter(!is.na(year) & !is.na(name) & year != 1965) %>% 
  group_by(year) %>% 
  mutate(winner = c(1, rep(0, n() - 1)))

setdiff(1954:2024, dat_lfd$year) # correct

## limited ---------------------------------------------------------------------
dat_lfl <- "https://en.wikipedia.org/wiki/Primetime_Emmy_Award_for_Outstanding_Lead_Actress_in_a_Limited_or_Anthology_Series_or_Movie" %>% 
  read_html() %>% 
  html_table() %>% 
  `[`(3:10) %>% # hard-coded, may not replicate in future
  list_rbind() %>% 
  select(1:4) %>% 
  `names<-`(c("year", "name", "role", "program")) %>% 
  mutate(
    year = clean_year(year),
    across(name:program, clean_name)
  ) %>%
  filter(
    !is.na(year) & 
      !is.na(name) & 
      year != 1965 &
      !str_detect(name, fixed("actress"))
  ) %>% 
  group_by(year) %>% 
  mutate(winner = c(1, rep(0, n() - 1)))

# years where there were two categories for limited
dat_lfl$winner[dat_lfl$year == 1973 & dat_lfl$name == "susan hampshire"] <- 1
dat_lfl$winner[dat_lfl$year == 1974 & dat_lfl$name == "mildred natwick"] <- 1
dat_lfl$winner[dat_lfl$year == 1975 & dat_lfl$name == "jessica walter"] <- 1
dat_lfl$winner[dat_lfl$year == 1976 & dat_lfl$name == "rosemary harris"] <- 1
dat_lfl$winner[dat_lfl$year == 1977 & dat_lfl$name == "patty duke"] <- 1
dat_lfl$winner[dat_lfl$year == 1978 & dat_lfl$name == "meryl streep"] <- 1

# supporting actress -----------------------------------------------------------
## comedy ----------------------------------------------------------------------
dat_sfc <- "https://en.wikipedia.org/wiki/Primetime_Emmy_Award_for_Outstanding_Supporting_Actress_in_a_Comedy_Series" %>% 
  read_html() %>% 
  html_table() %>% 
  `[`(2:9) %>% # hard-coded, may not replicate in future
  list_rbind() %>% 
  select(1:4) %>% 
  `names<-`(c("year", "name", "role", "program")) %>% 
  mutate(
    year = clean_year(year),
    across(name:program, clean_name)
  ) %>%
  filter(
    !is.na(year) & 
      !is.na(name) & 
      year != 1965 & # non-gendered, no genre, no lead or support
      !year %in% no_genre & # include these in drama, not comedy
      !str_detect(name, fixed("actress"))
  ) %>% 
  group_by(year) %>% 
  mutate(winner = c(1, rep(0, n() - 1)))

# tie in 1972
dat_sfc$winner[dat_sfc$year == 1972 & dat_sfc$name == "sally struthers"] <- 1

## drama -----------------------------------------------------------------------
dat_sfd <- "https://en.wikipedia.org/wiki/Primetime_Emmy_Award_for_Outstanding_Supporting_Actress_in_a_Drama_Series" %>% 
  read_html() %>% 
  html_table() %>% 
  `[`(3:9) %>% # hard-coded, may not replicate in future
  list_rbind() %>% 
  select(1:4) %>% 
  `names<-`(c("year", "name", "role", "program")) %>% 
  mutate(
    year = clean_year(year),
    across(name:program, clean_name)
  ) %>%
  filter(
    !is.na(year) & 
      !is.na(name) & 
      year != 1965 &
      !str_detect(name, fixed("actress"))
  ) %>% 
  group_by(year) %>% 
  mutate(winner = c(1, rep(0, n() - 1)))

## limited ---------------------------------------------------------------------
dat_sfl <- "https://en.wikipedia.org/wiki/Primetime_Emmy_Award_for_Outstanding_Supporting_Actress_in_a_Limited_or_Anthology_Series_or_Movie" %>% 
  read_html() %>% 
  html_table() %>% 
  `[`(3:10) %>% # hard-coded, may not replicate in future
  list_rbind() %>% 
  select(1:4) %>% 
  `names<-`(c("year", "name", "role", "program")) %>% 
  mutate(
    year = clean_year(year),
    across(name:program, clean_name)
  ) %>%
  filter(
    !is.na(year) & 
      !is.na(name) & 
      !str_detect(name, fixed("actress"))
  ) %>% 
  group_by(year) %>% 
  mutate(winner = c(1, rep(0, n() - 1)))

# 1995 two-way tie Shirley Knight
dat_sfl$winner[dat_sfl$year == 1995 & dat_sfl$name == "shirley knight"] <- 1

# actress write ----------------------------------------------------------------
write_clip(dat_lfc)
write_clip(dat_lfd)
write_clip(dat_lfl)
write_clip(dat_sfc)
write_clip(dat_sfd)
write_clip(dat_sfl)

# lead actor -------------------------------------------------------------------
## comedy ----------------------------------------------------------------------
dat_lmc <- "https://en.wikipedia.org/wiki/Primetime_Emmy_Award_for_Outstanding_Lead_Actor_in_a_Comedy_Series" %>% 
  read_html() %>% 
  html_table() %>% 
  `[`(2:9) %>% # hard-coded, may not replicate in future
  list_rbind() %>% 
  select(1:4) %>% 
  `names<-`(c("year", "name", "role", "program")) %>% 
  mutate(
    year = clean_year(year),
    across(name:program, clean_name)
  ) %>%
  filter(
    !is.na(year) & 
      !is.na(name) & 
      year != 1965 &
      # include these in drama, not comedy
      # men different from women for a "comedian" category for 1957
      !year %in% no_genre[no_genre != 1957]
  ) %>% 
  group_by(year) %>% 
  mutate(winner = c(1, rep(0, n() - 1)))

## drama -----------------------------------------------------------------------
dat_lmd <- "https://en.wikipedia.org/wiki/Primetime_Emmy_Award_for_Outstanding_Lead_Actor_in_a_Drama_Series" %>% 
  read_html() %>% 
  html_table() %>% 
  `[`(2:9) %>% # hard-coded, may not replicate in future
  list_rbind() %>% 
  select(1:4) %>% 
  `names<-`(c("year", "name", "role", "program")) %>% 
  mutate(
    year = clean_year(year),
    across(name:program, clean_name)
  ) %>%
  filter(!is.na(year) & !is.na(name) & year != 1965) %>% 
  group_by(year) %>% 
  mutate(winner = c(1, rep(0, n() - 1)))

## limited ---------------------------------------------------------------------
dat_lml <- "https://en.wikipedia.org/wiki/Primetime_Emmy_Award_for_Outstanding_Lead_Actor_in_a_Limited_or_Anthology_Series_or_Movie" %>% 
  read_html() %>% 
  html_table() %>% 
  `[`(3:10) %>% # hard-coded, may not replicate in future
  list_rbind() %>% 
  select(1:4) %>% 
  `names<-`(c("year", "name", "role", "program")) %>% 
  mutate(
    year = clean_year(year),
    across(name:program, clean_name)
  ) %>%
  filter(
    !is.na(year) & 
      !is.na(name) & 
      year != 1965 &
      !str_detect(name, fixed("actor"))
  ) %>% 
  group_by(year) %>% 
  mutate(winner = c(1, rep(0, n() - 1)))

# years where there were two categories for limited
dat_lml$winner[dat_lml$year == 1973 & dat_lml$name == "anthony murphy"] <- 1
dat_lml$winner[dat_lml$year == 1974 & dat_lml$name == "william holden"] <- 1
dat_lml$winner[dat_lml$year == 1975 & dat_lml$name == "peter falk"] <- 1
dat_lml$winner[dat_lml$year == 1976 & dat_lml$name == "hal holbrook"] <- 1
dat_lml$winner[
  dat_lml$year == 1977 & 
    dat_lml$name == "christopher plummer"
] <- 1
dat_lml$winner[dat_lml$year == 1978 & dat_lml$name == "michael moriarty"] <- 1

# supporting actor -------------------------------------------------------------
## comedy ----------------------------------------------------------------------
dat_smc <- "https://en.wikipedia.org/wiki/Primetime_Emmy_Award_for_Outstanding_Supporting_Actor_in_a_Comedy_Series" %>% 
  read_html() %>% 
  html_table() %>% 
  `[`(2:9) %>% # hard-coded, may not replicate in future
  list_rbind() %>% 
  select(1:4) %>% 
  `names<-`(c("year", "name", "role", "program")) %>% 
  mutate(
    year = clean_year(year),
    across(name:program, clean_name)
  ) %>%
  filter(
    !is.na(year) & 
      !is.na(name) & 
      year != 1965 & # non-gendered, no genre, no lead or support
      !year %in% no_genre & # include these in drama, not comedy
      !str_detect(name, fixed("actor"))
  ) %>% 
  group_by(year) %>% 
  mutate(winner = c(1, rep(0, n() - 1)))
  
## drama -----------------------------------------------------------------------
dat_smd <- "https://en.wikipedia.org/wiki/Primetime_Emmy_Award_for_Outstanding_Supporting_Actor_in_a_Drama_Series" %>% 
  read_html() %>% 
  html_table() %>% 
  `[`(2:9) %>% # hard-coded, may not replicate in future
  list_rbind() %>% 
  select(1:4) %>% 
  `names<-`(c("year", "name", "role", "program")) %>% 
  mutate(
    year = clean_year(year),
    across(name:program, clean_name)
  ) %>%
  filter(
    !is.na(year) & 
      !is.na(name) & 
      year != 1965 &
      !str_detect(name, fixed("actor"))
  ) %>% 
  group_by(year) %>% 
  mutate(winner = c(1, rep(0, n() - 1)))
  
## limited ---------------------------------------------------------------------
dat_sml <- "https://en.wikipedia.org/wiki/Primetime_Emmy_Award_for_Outstanding_Supporting_Actor_in_a_Limited_or_Anthology_Series_or_Movie" %>% 
  read_html() %>% 
  html_table() %>% 
  `[`(2:7) %>% # hard-coded, may not replicate in future
  list_rbind() %>% 
  select(1:4) %>% 
  `names<-`(c("year", "name", "role", "program")) %>% 
  mutate(
    year = clean_year(year),
    across(name:program, clean_name)
  ) %>%
  filter(
    !is.na(year) & 
      !is.na(name) & 
      !str_detect(name, fixed("actor"))
  ) %>% 
  group_by(year) %>% 
  mutate(winner = c(1, rep(0, n() - 1)))
  
# actor write ------------------------------------------------------------------
write_clip(dat_lmc)
write_clip(dat_lmd)
write_clip(dat_lml)
write_clip(dat_smc)
write_clip(dat_smd)
write_clip(dat_sml)
