# load libraries
library(rvest)
library(dplyr)

# get team data from year 2015 to year 2020
for (year in 2015:2020) {
  team_url <- paste0("https://www.basketball-reference.com/leagues/NBA_", year, "_ratings.html")
  team_df <- team_url %>%
    read_html() %>%
    html_table() %>%
    as.data.frame(stringAsFactors=FALSE)
  
  # reset column names
  names(team_df) <- team_df[1, ]
  team_df <- team_df %>%
    # remove redundant rows
    filter(Rk != 'Rk') %>%
    # convert column types
    mutate(Rk = as.integer(Rk), W = as.integer(W), L = as.integer(L))
  team_df[, 7:15] <- lapply(team_df[, 7:15], as.double)
  
  # save dataframes
  saveRDS(team_df, paste0('./Data/team/team_', year, '.Rda'))
}