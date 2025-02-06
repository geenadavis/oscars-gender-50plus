# prep -------------------------------------------------------------------------
library(googlesheets4)
library(tidyverse)

gs4_auth()
2

dat_dob <- read_sheet("<...>", 2) %>% 
  mutate(dob = str_sub(dob, 1, 10))

dat_check1 <- read_sheet("<...>")

dat_check2 <- read_sheet("<...>")

# error rate -------------------------------------------------------------------
table(c(dat_check1$check, dat_check2$check)) %>% 
  print() %>% 
  prop.table()

# off by:
# x - tally
# y - contested tally
# 0 years: xx
# 1 year: x
# 2 years: xy
# 3 years: yx

# same actor, different dob ----------------------------------------------------
mults <- dat_dob %>% 
  select(name, dob) %>% 
  unique() %>% 
  count(name) %>% 
  filter(n > 1)
# 31 where different birth dates

dat_dob %>% 
  inner_join(select(mults, name)) %>% 
  select(name, dob) %>% 
  unique() %>% 
  clipr::write_clip()

# read in from gsheets after deciding which is correct
mults_keep <- read_sheet("<...>", 3) %>% 
  filter(keep == 1)

dat_dob %>% 
  select(name) %>% 
  unique() %>% 
  nrow()

dat_dob <- dat_dob %>% 
  select(name, dob) %>% 
  anti_join(mults, by = "name") %>% 
  bind_rows(select(mults_keep, -keep)) %>% 
  arrange() %>% 
  unique()

nrow(dat_dob)

# didn't parse -----------------------------------------------------------------
dat_dob <- dat_dob %>% 
  mutate(yob = as.numeric(str_sub(dob, 1, 4)))
# 3 failed to parse year of birth

dat_dob %>% 
  filter(is.na(yob))

dat_dob$yob[dat_dob$name == "janelle james"] <- 1979 # imdb, not on wikipedia
dat_dob$yob[dat_dob$name == "karen pittman"] <- 1986 # imdb, not on wikipedia
dat_dob$yob[dat_dob$name == "lisa jacobs"] <- NA # not online!

table(is.na(dat_dob$yob))

# output -----------------------------------------------------------------------
dat <- dat_dob %>% 
  select(name, yob)

clipr::write_clip(dat)
