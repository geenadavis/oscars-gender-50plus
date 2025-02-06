# prep -------------------------------------------------------------------------
library(googlesheets4)
library(tidyverse)
library(reticulate)
library(glue)
use_virtualenv()
source_python("dobs.py")

gs4_auth()
2

dat <- read_sheet("<...>") %>% 
  mutate(
    across(everything(), as.character),
    program = na_if(program, "NULL")
  ) %>% 
  transmute(name, title = coalesce(film, program), dob = NA)

# dobs -------------------------------------------------------------------------
template <- "{actor}, who acted in *{title}*"

for (i in seq_len(nrow(dat))) {
  if (i %% 250 == 0) cat(i, "\n")
  dat$dob[i] <- get_dob(
    glue(
      template, 
      actor = dat$name[i],
      title = dat$title[i]
    )
  )
}

clipr::write_clip(dat)

# for andy/mark check ----------------------------------------------------------
round(length(unique(dat$name)) * .15) # 311 is a 15% random sample of names
# do 312 for 156 each

set.seed(1839)
to_review <- dat %>% 
  group_by(name) %>% 
  slice_sample(n = 1) %>% 
  ungroup() %>% 
  slice_sample(n = 312)

clipr::write_clip(to_review)
