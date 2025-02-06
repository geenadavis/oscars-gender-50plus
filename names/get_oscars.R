# prep -------------------------------------------------------------------------
library(clipr)
library(rvest)
library(tidyverse)

# hard-coding ties:
# 1968 for best leading actress, two-way
# 1931/32 for best leading actor, two-way

clean_year <- function(x) {
  x %>% 
    str_sub(1, 4) %>% 
    as.numeric() %>% 
    # early ceremonies didn't line up to year, take max
    # don't do this with covid because it was mainly 2020 and just part of 2021
    ifelse(. < 1934, . + 1, .)
}

# clean † ‡ §, these are not consistent; simplest way is to hard-code ties
# also use this for film name
clean_name <- function(x) {
  x %>% 
    str_remove_all("[\\[(†‡§].*") %>% 
    trimws() %>% 
    tolower()
}

# lead actress -----------------------------------------------------------------
dat_lf <- "https://en.wikipedia.org/wiki/Academy_Award_for_Best_Actress" %>% 
  read_html() %>% 
  html_table() %>% 
  `[`(3:13) %>% # hardcoded, might not replicate in future
  list_rbind() %>% 
  select(1:4) %>% 
  `names<-`(c("year", "name", "role", "film")) %>% 
  mutate(
    year = clean_year(year),
    across(name:film, clean_name)
  ) %>% 
  group_by(year) %>% 
  mutate(winner = c(1, rep(0, n() - 1)))

# edge case: 1968 tie for best leading actress, two-way
dat_lf$winner[dat_lf$year == 1968][2] <- 1

# check
dat_lf %>% 
  filter(year == 1968)

# support actress --------------------------------------------------------------
dat_sf <- "https://en.wikipedia.org/wiki/Academy_Award_for_Best_Supporting_Actress" %>% 
  read_html() %>% 
  html_table() %>% 
  `[`(3:12) %>% # hardcoded, might not replicate in future
  list_rbind() %>% 
  select(1:4) %>% 
  `names<-`(c("year", "name", "role", "film")) %>% 
  mutate(
    year = clean_year(year),
    across(name:film, clean_name)
  ) %>% 
  group_by(year) %>% 
  mutate(winner = c(1, rep(0, n() - 1)))

# lead actor -------------------------------------------------------------------
dat_lm <- "https://en.wikipedia.org/wiki/Academy_Award_for_Best_Actor" %>% 
  read_html() %>% 
  html_table() %>% 
  `[`(3:13) %>% # hardcoded, might not replicate in future
  list_rbind() %>% 
  select(1:4) %>% 
  `names<-`(c("year", "name", "role", "film")) %>% 
  mutate(
    year = clean_year(year),
    across(name:film, clean_name)
  ) %>% 
  group_by(year) %>% 
  mutate(winner = c(1, rep(0, n() - 1)))

# edge case: 1931/32 tie for best leading actor, two-way
dat_lm$winner[dat_lm$year == 1932][2] <- 1

# check
dat_lm %>% 
  filter(year == 1932)

# support actor ----------------------------------------------------------------
dat_sm <- "https://en.wikipedia.org/wiki/Academy_Award_for_Best_Supporting_Actor" %>% 
  read_html() %>% 
  html_table() %>% 
  `[`(3:12) %>% # hardcoded, might not replicate in future
  list_rbind() %>% 
  select(1:4) %>% 
  `names<-`(c("year", "name", "role", "film")) %>% 
  mutate(
    year = clean_year(year),
    across(name:film, clean_name)
  ) %>% 
  group_by(year) %>% 
  mutate(winner = c(1, rep(0, n() - 1)))

# copy-paste to sheet ----------------------------------------------------------
write_clip(dat_lf)
write_clip(dat_sf)
write_clip(dat_lm)
write_clip(dat_sm)
