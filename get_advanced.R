# load libraries
library(rvest)
library(dplyr)

advanced_url <- "https://www.basketball-reference.com/leagues/NBA_2020_advanced.html"
advanced_df <- advanced_url %>%
  read_html() %>%
  html_table() %>%
  as.data.frame(stringsAsFactors=FALSE) %>%
  # remove redundant columns
  select(-Var.20, -Var.25) %>%
  # remove redundant rows
  filter(Rk != "Rk") %>%
  # convert column types
  mutate(Rk = as.integer(Rk), Age = as.integer(Age), G = as.integer(G), MP = as.integer(MP))

# reset column names
names(advanced_df) <- c('Rk', 'Player', 'Pos', 'Age', 'Tm', 'G', 'MP', 'PER', 'TSpct', '3PAr', 'FTr', 
                        'ORBpct', 'DRBpct', 'TRBpct', 'ASTpct', 'STLpct', 'BLKpct', 'TOVpct', 'USGpct', 
                        'OWS', 'DWS', 'WS', 'WS/48', 'OBPM', 'DBPM', 'BPM', 'VORP')

# convert column types
advanced_df[, 8:27] <- lapply(advanced_df[, 8:27], as.double)

# save dataframes
saveRDS(advanced_df, paste0('./Data/advanced.Rda'))