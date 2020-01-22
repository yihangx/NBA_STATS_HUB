# load libraries
library(rvest)
library(dplyr)

# get player data from year 2015 to year 2020
for (year in 2015:2020) {
  player_url <- paste0("https://www.basketball-reference.com/leagues/NBA_", year, "_per_game.html")
  player_df <- player_url %>%
    read_html() %>%
    html_table() %>%
    as.data.frame(stringsAsFactors=FALSE) %>%
    # remove redundant rows
    filter(Rk != 'Rk')
  
  # reset column names
  names(player_df) <- c('Rk', 'Player', 'Pos', 'Age', 'Tm', 'G', 'GS', 'MP', 'FG', 'FGA', 'FGpct', 
                        '3P', '3PA', '3Ppct', '2P', '2PA', '2Ppct', 'eFGpct', 'FT', 'FTA', 'FTpct', 
                        'ORB', 'DRB', 'TRB', 'AST', 'STL', 'BLK', 'TOV', 'PF', 'PTS')
  
  # convert column types
  player_df <- player_df %>%
    mutate(Rk = as.integer(Rk), Age = as.integer(Age))
  player_df[, 6:30] <- lapply(player_df[, 6:30], as.double)
  
  # save dataframes
  saveRDS(player_df, paste0('./Data/player/player_', year, '.Rda'))
}