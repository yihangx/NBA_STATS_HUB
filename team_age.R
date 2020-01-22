# load libraries
library(tidyverse)
library(dplyr)
library(multidplyr)

# read data
player <- readRDS('./Data/player/player_2020.Rda')

# average age group by team
team_age <- player %>%
  select(Age, Tm) %>%
  group_by(Tm) %>%
  summarize(avg_age = round(mean(Age),1))

# save data
saveRDS(team_age, paste0('./Data/team_age.Rda'))