# load libraries
library(rvest)
library(dplyr)
library(tidyverse)

salary_url <- "https://www.basketball-reference.com/contracts/players.html"
salary_df <- salary_url %>%
  read_html() %>%
  html_table() %>%
  as.data.frame(stringsAsFactors=FALSE)

# reset column names
names(salary_df) <- salary_df[1, ]

salary_df <- salary_df %>%
  # remove redundant rows
  filter(Rk != 'Rk' & Rk != '') %>%
  # clean salay string
  mutate_all(funs(str_replace(., "\\$", ""))) %>%
  mutate_all(funs(str_replace_all(., ",", ""))) %>%
  # convert column types
  mutate(Rk = as.integer(Rk), Guaranteed = as.integer(Guaranteed))
salary_df[, 4:9] <- lapply(salary_df[, 4:9], as.integer)

# save dataframe
saveRDS(salary_df, paste0('./Data/salary.Rda'))