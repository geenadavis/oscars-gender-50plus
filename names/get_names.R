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
      select(2, 4) %>% 
      mutate(across(everything(), as.character)) %>% 
      unique()
  )
}

dat <- dat %>% 
  unique() %>% 
  arrange(name)

clipr::write_clip(dat)
