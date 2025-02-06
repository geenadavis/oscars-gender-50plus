# prep -------------------------------------------------------------------------
library(googlesheets4)
library(tidyverse)

gs4_auth()
2

# get names --------------------------------------------------------------------
tabs <- sheet_names("<...>")

dat <- tibble()

for (i in tabs) {
  cat("starting", i, "\n")
  
  dat <- bind_rows(
    dat,
    read_sheet("<...>", i) %>% 
      mutate(key = i) %>% 
      mutate(across(where(is.list), as.character))
  )
}

# coalesce ---------------------------------------------------------------------
dat <- dat %>% 
  mutate(title = coalesce(film, program)) %>% 
  select(-program, -film)

# join yob ---------------------------------------------------------------------
dat_yob <- read_sheet(
  "<...>", 
  "clean_yob"
)

nrow(dat)

dat <- dat %>% 
  left_join(dat_yob, by = "name")

nrow(dat)

# rearrange and copy -----------------------------------------------------------
dat <- dat %>% 
  separate(key, c("ceremony", "award"), sep = "-") %>% 
  transmute(year, ceremony, award, winner, name, role, title, age = year - yob)

clipr::write_clip(dat)
