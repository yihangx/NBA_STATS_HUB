# load libraries
library(tidyverse)
library(dplyr)
library(multidplyr)

# read data
player <- readRDS('./Data/player/player_2020.Rda')

df <- player %>% 
  filter(Player != "LeBron James") %>%
  select(Age, PTS, eFGpct, AST, ORB, DRB, STL, BLK, TOV, PF)
df[is.na(df)] <- 0
df[c(2:10)] <- lapply(df[c(2:10)], scale)

df <- df %>%
  group_by(Age) %>%
  filter(Age>19 & Age<36) %>%
  summarize(PTS = mean(PTS), eFG = mean(eFGpct), AST = mean(AST), ORB = mean(ORB),
            DRB = mean(DRB), STL = mean(STL), BLK = mean(BLK), 
            TOV = mean(TOV), PF = mean(PF))

# save data
saveRDS(df, paste0('./Data/other_players.Rda'))