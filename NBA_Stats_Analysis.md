---
title: "nba_stats_analysis"
author: 'project-lockerlock'
date: "12/14/2019"
output: 
  html_document:
    keep_md: yes
    code_folding: hide
---




```r
library(tidyverse)
library(dplyr)
library(ggplot2)
library(patchwork)
library(scales)
library(RCurl)
library(ggrepel)
library(ggimage)
library(plotly)
library(gridExtra)
library(fmsb)
library(radarchart)
library(patchwork)
library(plyr)
library(rowr)
library(ggrepel)
library(jsonlite)
library(httr)
library(shiny)
library(shinydashboard)
library(htmltools)
library(DT)
```
Summary

1. main objective: 

  -- scrape data from NBA stats website

  -- perform stats analysis including age and efficiency

  -- build R shiny app to search stats

2. data: 

  https://www.basketball-reference.com/

3. methods: 

  -- use 4 .R files to get players general and advanced data, teams data, and salary data

  -- perform analysis about players' age and efficiency and plot them

  -- use dashboard to build an app to search NBA stats for current season and the last 5 seasons

4. results: 

  -- get 4 types of data including: player, advanced, salary and team

  -- get analysis plots including: Oldest and Youngest NBA Teams at the Start of the 2019 Season, Age Effect on NBA Players, Age Legend LeBron, MVP Candidates Comparsion and Efficiency versus Salary

  -- build an app 

```r
player <- readRDS('./Data/player/player_2020.Rda')
salary <- readRDS('./Data/salary.Rda')
team <- readRDS('./Data/team/team_2020.Rda')
team_age <- readRDS('./Data/team_age.Rda')
```
# NBA STATS ANALYSIS
## 1. Player Age Story
### 1.1 Oldest and Youngest NBA Teams at the Start of the 2019 Season
    The Memphis currently have the NBA’s youngest roster. The league’s data shows that the average age of a Memphis player this season is just 24.1 years. Teams also on the youngest team list is led by Chicago(24.2), Phoenix(24.5), Gloden State(24.6), and Boston(24.5). On the other end of the spectrum, the Rockets have the league’s oldest roster, with an average age of 28.6.

```r
top5_oldest <- team_age %>%
  arrange(desc(avg_age)) %>%
  slice(1:5)

top5_youngest <- team_age %>%
  arrange(avg_age) %>%
  slice(1:5)
```


```r
young_rosters <- ggplot(top5_youngest, mapping = aes(x = reorder(Tm,-avg_age), y = avg_age)) +
  geom_bar(stat = "identity",  width = 0.6, fill = "#5cc58c") +
  scale_y_continuous(limit = c(22, 29),oob = rescale_none) +
  geom_text(aes(label = avg_age), hjust = -0.2) +
  theme_bw(base_size = 12) +
  labs(y = "Age", x = "Team", title = "Top 5 Youngest Rosters") +
  coord_flip()

old_rosters <- ggplot(top5_oldest, mapping = aes(x = reorder(Tm,avg_age), y = avg_age)) +
  geom_bar(stat = "identity", width = 0.6, fill = "#b85b3b") +
  scale_y_continuous(limit = c(22, 29),oob = rescale_none) +
  geom_text(aes(label = avg_age), hjust = -0.2) +
  theme_bw(base_size = 12) +
  labs(y = "Age", x = "Team", title = "Top 5 Oldest Rosters") +
  coord_flip()

young_rosters + old_rosters + plot_layout(ncol = 1)
```

![](NBA_Stats_Analysis_files/figure-html/unnamed-chunk-3-1.png)<!-- -->

### 1.2 Age Effect on NBA Players
  The age is a very important factor to precise the performance levels of players in all physical sports. The following plots depict players’ average efficiency grouping by the age. The ages of under 19 and over 36 are excluded due to small number of players. LeBron James regarded as an outlier at his age is excluded and is discussed separately. 
  We are seeing that 29-31 years old is the gloden age with peak defensive and offensive efficiency. A clear performance drop can be seen starting by age 31. However, as players with more experience, they better control turnovers and fouls. Also, effective field goal percentage goes up, indicating more reasonable shooting choice.

```r
df <- readRDS('./Data/other_players.Rda')
```


```r
offence <- ggplot(df, aes(x = Age)) +
  geom_smooth(aes(y = PTS, colour="pts"), method = 'loess', se = FALSE) +
  geom_smooth(aes(y = eFG, colour="efg"), method = 'loess', se = FALSE) +
  geom_smooth(aes(y = AST, colour="ast"), method = 'loess', se = FALSE) +
  geom_smooth(aes(y = ORB, colour="orb"), method = 'loess', se = FALSE) +
  scale_colour_manual(name = 'Offence',
                      guide = 'legend',
                      values = c('pts' = "#ff5463",'efg' = "#a5a0a1",'ast' = "#ffcb64", 'orb' = "#c5a970"),
                      labels = c('Points', 'Effective Field Goal Percentage', 'Assists', 'Offensive Rebounds')) +
  theme_bw(base_size = 8) +
  labs(x = "Age", y = "Scaled Number Per Game", title = "Offence Efficiency versus Age")

defence <- ggplot(df, aes(x = Age)) +
  geom_smooth(aes(y = DRB, colour="drb"), method = 'loess', se = FALSE) +
  geom_smooth(aes(y = STL, colour="stl"), method = 'loess', se = FALSE) +
  geom_smooth(aes(y = BLK, colour="blk"), method = 'loess', se = FALSE) +
  scale_colour_manual(name = 'Defence',
                      guide = 'legend',
                      values = c('drb' = "#ffb8bd",'stl' = "#b99433", 'blk' = "#ff764c"),
                      labels = c('Defensive Rebounds', 'Steals', 'Blocks')) +
  theme_bw(base_size = 8) +
  labs(x = "Age", y = "Scaled Number Per Game", title = "Defence Efficiency versus Age")

mistakes <- ggplot(df, aes(x = Age)) +
  geom_smooth(aes(y = TOV, colour="tov"), method = 'loess', se = FALSE) +
  geom_smooth(aes(y = PF, colour="pf"), method = 'loess', se = FALSE) +
  scale_colour_manual(name = 'Mistakes',
                      guide = 'legend',
                      values = c('tov' = "#b28c96",'pf' = "#c4803e"),
                      labels = c('Turnovers', 'Personal Fouls')) +
  theme_bw(base_size = 8) +
  labs(x = "Age", y = "Scaled Number Per Game", title = "Mistake Numbers versus Age")
  
offence + defence + mistakes + plot_layout(ncol = 1)
```

![](NBA_Stats_Analysis_files/figure-html/unnamed-chunk-5-1.png)<!-- -->

### 1.3 Age Legend -- LeBron
  LeBron thinks his game is at ‘an all-time high.’ Based on his age, he may be right. We pull out all players data from 2014-2015 season when LeBron was 30 to 2019-2020 season when he is 35. Despite the fact that he is the top 10 oldest, LeBron is still far away from dropping to be an average. Also, it's easy to see a late effect on him compared with above. A clear effective field goal drop starts at 33 but with clear rise at assist afterwards and top scoring ability as usually.  

```r
lbj <- rbind()
avg <- rbind()
for (year in 2015:2020){
  player_year <- readRDS(paste0('./Data/player/player_', year, '.Rda')) %>%
    select(Player, Age, PTS, eFGpct, AST, TRB)
  avg <- rbind(avg, 
               player_year %>%
                 mutate(Player = 'Avg Player', Age = year-1985) %>%
                 group_by(Player) %>%
                 summarize(Age = mean(Age),
                           PTS = mean(PTS, na.rm=TRUE), 
                           eFGpct = mean(eFGpct, na.rm=TRUE), 
                           AST = mean(AST, na.rm=TRUE), 
                           TRB = mean(TRB, na.rm=TRUE)))
  lbj <- rbind(lbj, 
               player_year %>% 
                 filter(Player == "LeBron James"))
}
```


```r
pts <- ggplot() +
  geom_line(avg, mapping = aes(x=Age, y=PTS, colour="avg"), linetype="dashed", color = '#56ae6c', size=1.2) +
  geom_line(lbj, mapping = aes(x=Age, y=PTS, colour="lbj"), color = '#56ae6c', size=1.2) +
  labs(title = "Points Comparison") 

efg <- ggplot() +
  geom_line(avg, mapping = aes(x=Age, y=eFGpct, colour="avg"), linetype="dashed", color = '#8960b3', size=1.2) +
  geom_line(lbj, mapping = aes(x=Age, y=eFGpct, colour="lbj"), color = '#8960b3', size=1.2) +
  labs(title = "Effective Field Goal Comparison") 

ast <- ggplot()+
  geom_line(avg, mapping = aes(x=Age, y=AST, colour="avg"), linetype="dashed", color = '#b0923b', size=1.2) +
  geom_line(lbj, mapping = aes(x=Age, y=AST, colour="lbj"), color = '#b0923b', size=1.2) +
  labs(title = "Assists Comparison") 

trb <- ggplot() +
  geom_line(avg, mapping = aes(x=Age, y=TRB, colour="avg"), linetype="dashed", color = '#ba495b', size=1.2) +
  geom_line(lbj, mapping = aes(x=Age, y=TRB, colour="lbj"), color = '#ba495b', size=1.2) +
  labs(title = "Total Rebounds Comparison") 

grid.arrange(grobs = list(pts, efg, ast, trb), top = "── LeBron --- Average", ncol=2)
```

![](NBA_Stats_Analysis_files/figure-html/unnamed-chunk-7-1.png)<!-- -->


```r
player <- readRDS('./Data/player/player_2020.Rda')
salary <- readRDS('./Data/salary.Rda')
team <- readRDS('./Data/team/team_2020.Rda')
advanced <- readRDS('./Data/advanced.Rda')
```

## 2. Player Efficiency
### 2.1 MVP Candidates Comparsion
  We select players based on ESPN's "The Top 5 this week in the 2019-20 Kia Race to the MVP Ladder" and perform comparsion using general stats--points, steals, assists, blocks and rebounds, setting each entry's peak as max and 0 as min. 
  Antetokounmpo has the most blocks and rebounds, also most "shade area". It’s clear why Antetokounmpo is the betting favorite to win the award. Dončić is good at every item except blocks. Harden has the most points and steals but much less blocks and rebounds. LeBron has the most assists but not competative at blocks, rebounds or points. 

```r
MVP_candidates <- player %>%
  select('PTS','Player','BLK','TRB','AST','STL') %>%
  filter(Player %in% c('James Harden','Giannis Antetokounmpo','Luka Dončić','LeBron James','Pascal Siakam'))
rownames(MVP_candidates) <- MVP_candidates$Player
MVP_candidates <- MVP_candidates %>% select(-Player)
MVP_candidates <- rbind( c(max(MVP_candidates$PTS), max(MVP_candidates$BLK), max(MVP_candidates$TRB),
                           max(MVP_candidates$AST), max(MVP_candidates$STL)), rep(0,5), MVP_candidates)
```


```r
p_Giannis = radarchart(MVP_candidates[c(1,2,3),],
                       axistype = 2,
                       pcol = rgb(0.1,0.3,0.5,0.7),
                       pfcol = rgb(0.1,0.3,0.5,0.7),
                       plwd = 1.5,
                       cglcol = "grey",
                       cglty = 1,
                       axislabcol = "black",
                       vlcex = 1.0,
                       title = "Giannis Antetokounmpo"
)
```

![](NBA_Stats_Analysis_files/figure-html/plot-1.png)<!-- -->

```r
p_Luka = radarchart(MVP_candidates[c(1,2,4),],
                    axistype = 2,
                    pcol = rgb(0.2,0.5,0.5,0.9),
                    pfcol = rgb(0.2,0.5,0.5,0.5),
                    plwd = 1.5,
                    cglcol = "grey",
                    cglty = 1,
                    axislabcol = "black",
                    vlcex = 1.0,
                    title = "Luka Dončić"
)
```

![](NBA_Stats_Analysis_files/figure-html/plot-2.png)<!-- -->

```r
p_James = radarchart(MVP_candidates[c(1,2,5),],
                     axistype = 2,
                     pcol = rgb(0.6,0.3,0.8,0.9),
                     pfcol = rgb(0.6,0.5,0.6,0.5),
                     plwd = 1.5,
                     cglcol = "grey",
                     cglty = 1,
                     axislabcol = "black",
                     vlcex = 1.0,
                     title = "James Harden"
)
```

![](NBA_Stats_Analysis_files/figure-html/plot-3.png)<!-- -->

```r
p_LeBron = radarchart(MVP_candidates[c(1,2,6),],
                      axistype = 2,
                      pcol = rgb(0.4,0.4,0.9,0.9),
                      pfcol = rgb(0.7,0.8,1.0,0.5),
                      plwd = 1.5,
                      cglcol = "grey",
                      cglty = 1,
                      axislabcol = "black",
                      vlcex = 1.0,
                      title = "Lebron James"
)
```

![](NBA_Stats_Analysis_files/figure-html/plot-4.png)<!-- -->

```r
p_Pascal = radarchart(MVP_candidates[c(1,2,7),],
                      axistype = 2,
                      pcol = rgb(1,0.6,0,0.9),
                      pfcol = rgb(1,0.7,0.5,0.5),
                      plwd = 1.5,
                      cglcol = "grey",
                      cglty = 1,
                      axislabcol = "black",
                      vlcex = 1.0,
                      title = "Pascal Siakam"
)
```

![](NBA_Stats_Analysis_files/figure-html/plot-5.png)<!-- -->

```
[DATA NOT ENOUGH] at 3
NA
 [DATA NOT ENOUGH] at 3
NA
 [DATA NOT ENOUGH] at 3
NA
 [DATA NOT ENOUGH] at 3
NA
 [DATA NOT ENOUGH] at 3
NA
```

### 2.2 Efficiency versus Salary
  PER stands for "Player Efficiency Rating." It's an important factor to precise the performance of players on the count. Generally speaking, players with better performance earn more salary. There are always exceptions to the rule, performance and salary can be disproportionate with two conditions: high PER with low salary and low PER with high salary. The plot indicates the former condition in green and the latter in red. 
  

```r
get_salary <- salary %>% select('Player','2019-20') 
get_PER <- advanced %>%  select('Player','PER')

salary_PER <- data.frame(merge(get_salary, get_PER, by='Player', all=TRUE))
colnames(salary_PER) <- c("Player", "salary" , "PER")
salary_PER <- na.omit(salary_PER) %>%
   mutate_if(is.numeric, scale)

p <- quantile(salary_PER$PER)
s <- quantile(salary_PER$salary)
```


```r
ggplot(salary_PER, aes(x= PER, y= salary)) +
  geom_point(size = 0.1) +
  geom_text_repel(aes(label=ifelse(PER<p[[2]]&salary>s[[4]],as.character(Player),'')), size=3, color = "#f11c90") +
  geom_text_repel(aes(label=ifelse(PER>p[[4]]&salary<s[[2]],as.character(Player),'')), size=3, color = "#00cf80") +
  geom_vline(xintercept = p[[2]], linetype="dashed") +
  geom_vline(xintercept = p[[3]]) +
  geom_vline(xintercept = p[[4]], linetype="dashed") +
  geom_hline(yintercept = s[[2]], linetype="dashed") +
  geom_hline(yintercept = s[[3]]) +
  geom_hline(yintercept = s[[4]], linetype="dashed") +
  labs(x = "scaled PER", y= "scaled salary", title = "── Median --- Quatile")
```

![](NBA_Stats_Analysis_files/figure-html/unnamed-chunk-8-1.png)<!-- -->

# NBA STATS HUB APP

```r
team2015 <- readRDS("Data/team/team_2015.RDA")
team2016 <- readRDS("Data/team/team_2016.RDA")
team2017 <- readRDS("Data/team/team_2017.RDA")
team2018 <- readRDS("Data/team/team_2018.RDA")
team2019 <- readRDS("Data/team/team_2019.RDA")
team2020 <- readRDS("Data/team/team_2020.RDA")

player2015 <- readRDS("Data/player/player_2015.RDA")
player2016 <- readRDS("Data/player/player_2016.RDA")
player2017 <- readRDS("Data/player/player_2017.RDA")
player2018 <- readRDS("Data/player/player_2018.RDA")
player2019 <- readRDS("Data/player/player_2019.RDA")
player2020 <- readRDS("Data/player/player_2020.RDA")

logo1 <- data.frame(
  Team = c('Atlanta Hawks', 'Cleveland Cavaliers','Chicago Bulls',
              'Toronto Raptors','Washington Wizards','Indiana Pacers',
              'Milwaukee Bucks','Boston Celtics','Detroit Pistons',
              'Brooklyn Nets','Miami Heat','Charlotte Hornets',
              'Orlando Magic','Philadelphia 76ers','New York Knicks'),
  Logo = c('<img src="http://content.sportslogos.net/logos/6/220/thumbs/22091682016.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/222/thumbs/22269212018.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/221/thumbs/hj3gmh82w9hffmeh3fjm5h874.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/227/thumbs/22745782016.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/219/thumbs/21956712016.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/224/thumbs/22448122018.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/225/thumbs/22582752016.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/213/thumbs/slhg02hbef3j1ov4lsnwyol5o.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/223/thumbs/22321642018.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/3786/thumbs/hsuff5m3dgiv20kovde422r1f.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/214/thumbs/burm5gh2wvjti3xhei5h16k8e.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/5120/thumbs/512019262015.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/217/thumbs/wd9ic7qafgfb0yxs7tem7n5g4.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/218/thumbs/21870342016.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/216/thumbs/2nn48xofg0hms8k326cqdmuis.gif" height="52"></img>'
  )
)

logo2 <- data.frame(
  Team = c('Golden State Warriors', 'Los Angeles Clippers','San Antonio Spurs',
              'Portland Trail Blazers','Houston Rockets','Memphis Grizzlies',
              'Dallas Mavericks','Oklahoma City Thunder','New Orleans Pelicans',
              'Utah Jazz','Phoenix Suns','Denver Nuggets',
              'Sacramento Kings','Los Angeles Lakers','Minnesota Timberwolves'),
  Logo = c('<img src="http://content.sportslogos.net/logos/6/235/thumbs/23531522020.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/236/thumbs/23654622016.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/233/thumbs/23325472018.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/239/thumbs/23997252018.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/230/thumbs/23068302020.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/231/thumbs/23143732019.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/228/thumbs/22834632018.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/2687/thumbs/khmovcnezy06c3nm05ccn0oj2.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/4962/thumbs/496226812014.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/234/thumbs/23467492017.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/238/thumbs/23843702014.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/229/thumbs/22989262019.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/240/thumbs/24040432017.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/237/thumbs/uig7aiht8jnpl1szbi57zzlsh.gif" height="52"></img>',
           '<img src="http://content.sportslogos.net/logos/6/232/thumbs/23296692018.gif" height="52"></img>'
  )
)
```


```r
ui <- dashboardPage(
  skin = "black",
  dashboardHeader(title = "Basketball Reference",
  dropdownMenu(type = "messages",
  messageItem(
    from = "Support",
    message = "The Application is ready."
)
)
),
 dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Teams", tabName = "teams", icon = icon("th")),
      menuItem("Leaders", tabName = "leaders", icon = icon("th")),
      menuItem("Points Leaders Radar Chart", tabName = "radar", icon = icon("th"))
    )
  ),
dashboardBody(
     tabItems(
      tabItem(tabName = "dashboard",
        h1("Welcome to Basketball Reference!",align = "center"),

      img(src = "https://cdn.nba.net/nba-drupal-prod/2019-09/SEO-image-NBA-logoman.jpg" ,style="display: block; margin-left: auto; margin-right: auto;")
    ,


  
    
        h2("Basketball Reference gives you access to statistics and scores for the NBA.",align = "center"),
        h2("This application is created by Rshiny.",align = "center"),
        h2("This application has three functions: Teams, Leaders and Points Leaders Radar Chart",align = "center"),
         h5("For further information about data, please read", a("here.", href="https://www.basketball-reference.com/")),
        h6("Copyright (c) 2019 Yihang Xin, Ziyuan Shen, Mengxuan Cui, Yujie Wang.
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the Software), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."),
a(actionButton(inputId = "email1", width = '200px', label = "Feedback", style="display: block; margin-left: auto; margin-right: auto;",
                 icon = icon("envelope", lib = "font-awesome")),
    href="mailto:yx141@duke.edu"),
a(actionButton(inputId = "email1", width = '200px',label = "Help",  style="display: block; margin-left: auto; margin-right: auto;",
                 icon = icon("question", lib = "font-awesome")),
    href="mailto:yx141@duke.edu"),

a(actionButton(inputId = "email1", width = '200px',label = "Special Thanks",  style="display: block; margin-left: auto; margin-right: auto;",
                 icon = icon("heart", lib = "font-awesome")),
    href="https://shawnsanto.com/teaching/duke/sta523/"),
a(actionButton(inputId = "email1", width = '200px',label = "Source Code",  style="display: block; margin-left: auto; margin-right: auto;",
                 icon = icon("github", lib = "font-awesome")),
    href="https://github.com/ziyuan-shen/NBA_STATS_HUB"),


)
,
tabItem(tabName = "teams",
        h2("Teams' Statstics (TOP 8)",align = "center"),
        box(
          title = "Eastern",  solidHeader = TRUE,
  background = "blue",width=6,
        radioButtons("team1", "Please Select Season", c('2014-15'="five", '2015-16'="six", '2016-17'="seven", '2017-18'="eight", '2018-19'="nine", '2019-20'="ten")),
                actionButton(inputId = "teamse", "Go!"),

                tags$hr(),
                br(),
                br(),
                tags$div(id = "team1")),
                
     box(
          title = "Western",  solidHeader = TRUE,
  background = "red",width=6,
               radioButtons("team2", "Please Select Season", c('2014-15'="five", '2015-16'="six", '2016-17'="seven", '2017-18'="eight", '2018-19'="nine", '2019-20'="ten")),
                actionButton("teamsw", "Go!"),
                tags$hr(),
                br(),
                br(),
                tags$div(id = "team2")),
  box(title = "Eastern", width = 6,status = "primary",solidHeader = TRUE, DT::dataTableOutput("table1")),
  box(title = "Western", width = 6,status = "danger",solidHeader = TRUE, DT::dataTableOutput("table2")),
                
      ),






tabItem(tabName = "leaders",
        h2("Leaders' Statstics (TOP 5)", align ="center"),
        box(
          title = "Points",  solidHeader = TRUE,
  background = "black",width=4,
               radioButtons("player1", "Please Select Season", c('2014-15'="five", '2015-16'="six", '2016-17'="seven", '2017-18'="eight", '2018-19'="nine", '2019-20'="ten")),
                actionButton("player11", "Go!"),
                tags$hr(),
                br(),
                br(),
                tags$div(id = "player1")),

     box(
          title = "Rebounds",  solidHeader = TRUE,
  background = "black",width = 4,
              radioButtons("player2", "Please Select Season", c('2014-15'="five", '2015-16'="six", '2016-17'="seven", '2017-18'="eight", '2018-19'="nine", '2019-20'="ten")),
                actionButton("player22", "Go!"),
                tags$hr(),
                br(),
                br(),
                tags$div(id = "player22")),
     box(
          title = "Assists",  solidHeader = TRUE,
  background = "black",width = 4,
              radioButtons("player3", "Please Select Season", c('2014-15'="five", '2015-16'="six", '2016-17'="seven", '2017-18'="eight", '2018-19'="nine", '2019-20'="ten")),
                actionButton("player33", "Go!"),
                tags$hr(),
                br(),
                br(),
                tags$div(id = "player33")),
  
  
   box(title = "Points", width = 4,height = "275px",status = "warning",solidHeader = TRUE, DT::dataTableOutput("table3")),
  box(title = "Rebounds", width = 4,height = "275px",status = "warning",solidHeader = TRUE, DT::dataTableOutput("table4")),
   box(title = "Assists", width = 4,height = "275px",status = "warning",solidHeader = TRUE, DT::dataTableOutput("table5")),
  
  
  box(
          title = "Trunovers",  solidHeader = TRUE,
  background = "black",width = 4,
              radioButtons("player4", "Please Select Season", c('2014-15'="five", '2015-16'="six", '2016-17'="seven", '2017-18'="eight", '2018-19'="nine", '2019-20'="ten")),
                actionButton("player44", "Go!"),
                tags$hr(),
                br(),
                br(),
                tags$div(id = "player44")),
  box(
          title = "Steals",  solidHeader = TRUE,
  background = "black",width = 4,
              radioButtons("player5", "Please Select Season", c('2014-15'="five", '2015-16'="six", '2016-17'="seven", '2017-18'="eight", '2018-19'="nine", '2019-20'="ten")),
                actionButton("player55", "Go!"),
                tags$hr(),
                br(),
                br(),
                tags$div(id = "player55")),
  box(
          title = "Blocks",  solidHeader = TRUE,
  background = "black",width = 4,
              radioButtons("player6", "Please Select Season", c('2014-15'="five", '2015-16'="six", '2016-17'="seven", '2017-18'="eight", '2018-19'="nine", '2019-20'="ten")),
                actionButton("player66", "Go!"),
                tags$hr(),
                br(),
                br(),
                tags$div(id = "player66")),
  
   box(title = "Trunovers", width = 4,height = "275px",status = "warning",solidHeader = TRUE, DT::dataTableOutput("table6")),
  box(title = "Steals", width = 4,height = "275px",status = "warning",solidHeader = TRUE, DT::dataTableOutput("table7")),
   box(title = "Blocks", width = 4,height = "275px",status = "warning",solidHeader = TRUE, DT::dataTableOutput("table8")),

      ),
tabItem(tabName = "radar",
        h1("Points Leaders Radar Chart",align = "left"),
        htmlTemplate("radar.html"))
)))


server <- function(input, output) { 
data1 <- eventReactive(input$teamse,{
    if(is.null(input$team1)){
      return()
    }
   choose <- switch(input$team1,
                   five = team2015,
                   six = team2016,
                   seven = team2017,
                   eight = team2018,
                   nine = team2019,
                   ten = team2020)
  
  
    df1 <- filter(choose, Conf == "E") %>%
  select(Rk,Team,W,L,"W/L%")
    df1 <- merge(df1,logo1,by="Team", sort = FALSE)
    df1 <- df1[c(6,1,2,3,4,5)]
    df1 <- DT::datatable(df1, escape = FALSE, options = list(searching = FALSE,initComplete = JS(
    "function(settings, json) {",
    "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
    "}"),pageLength = 8,lengthMenu = c(8, 15), order = list(3,'asc')))


})

data2 <- eventReactive(input$teamsw,{
    if(is.null(input$team2)){
      return()
    }

   choose <- switch(input$team2,
                   five = team2015,
                   six = team2016,
                   seven = team2017,
                   eight = team2018,
                   nine = team2019,
                   ten = team2020)

    df2 <- filter(choose, Conf == "W") %>%
  select(Rk,Team,W,L,"W/L%")
    df2 <- merge(df2,logo2,by="Team", sort = FALSE)
    df2 <- df2[c(6,1,2,3,4,5)]
    df2 <- DT::datatable(df2, escape = FALSE, options = list(searching = FALSE,initComplete = JS(
    "function(settings, json) {",
    "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
    "}"),pageLength = 8,lengthMenu = c(8, 15), order = list(3,'asc')))


  })




data3 <- eventReactive(input$player11,{
    if(is.null(input$player1)){
      return()
    }
  
     choose <- switch(input$player1,
                   five = player2015,
                   six = player2016,
                   seven = player2017,
                   eight = player2018,
                   nine = player2019,
                   ten = player2020)
  df3 <- filter(choose, PTS > 0) %>%
  select(Player,PTS)
  df3 <- df3[with(df3, order(-PTS)),]
    df3 <- head(df3,n=5)
    rownames(df3)<- c()

    df3 <- DT::datatable(df3, escape = FALSE, options = list(dom = 't',searching = FALSE,initComplete = JS(
    "function(settings, json) {",
    "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
    "}"),pageLength = 5,lengthMenu = c(5, 10), order = list(2,'desc')))
  })


data4 <- eventReactive(input$player22,{
    if(is.null(input$player2)){
      return()
    }
 choose <- switch(input$player2,
                   five = player2015,
                   six = player2016,
                   seven = player2017,
                   eight = player2018,
                   nine = player2019,
                   ten = player2020)
  df4 <- filter(choose, TRB > 0) %>%
  select(Player,TRB)
  df4 <- df4[with(df4, order(-TRB)),]
    df4 <- head(df4,n=5)
    rownames(df4)<- c()

    df4 <- DT::datatable(df4, escape = FALSE, options = list(dom = 't',searching = FALSE,initComplete = JS(
    "function(settings, json) {",
    "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
    "}"),pageLength = 5,lengthMenu = c(5, 10), order = list(2,'desc')))
  })


data5 <- eventReactive(input$player33,{
    if(is.null(input$player3)){
      return()
    }

     choose <- switch(input$player3,
                   five = player2015,
                   six = player2016,
                   seven = player2017,
                   eight = player2018,
                   nine = player2019,
                   ten = player2020)
  df5 <- filter(choose, AST > 0) %>%
  select(Player,AST)
  df5 <- df5[with(df5, order(-AST)),]
    df5 <- head(df5,n=5)
    rownames(df5)<- c()

    df5 <- DT::datatable(df5, escape = FALSE, options = list(dom = 't',searching = FALSE,initComplete = JS(
    "function(settings, json) {",
    "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
    "}"),pageLength = 5,lengthMenu = c(5, 10), order = list(2,'desc')))
  })


data6 <- eventReactive(input$player44,{
    if(is.null(input$player4)){
      return()
    }
       choose <- switch(input$player4,
                   five = player2015,
                   six = player2016,
                   seven = player2017,
                   eight = player2018,
                   nine = player2019,
                   ten = player2020)
  df6 <- filter(choose, TOV > 0) %>%
  select(Player,TOV)
  df6 <- df6[with(df6, order(-TOV)),]
    df6 <- head(df6,n=5)
        rownames(df6)<- c()

    df6 <- DT::datatable(df6, escape = FALSE, options = list(dom = 't',searching = FALSE,initComplete = JS(
    "function(settings, json) {",
    "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
    "}"),pageLength = 5,lengthMenu = c(5, 10), order = list(2,'desc')))

  })
data7 <- eventReactive(input$player55,{
    if(is.null(input$player5)){
      return()
    }

   choose <- switch(input$player5,
                   five = player2015,
                   six = player2016,
                   seven = player2017,
                   eight = player2018,
                   nine = player2019,
                   ten = player2020)
  df7 <- filter(choose, STL > 0) %>%
  select(Player,STL)
  df7 <- df7[with(df7, order(-STL)),]
    df7 <- head(df7,n=5)
      rownames(df7)<- c()

    df7 <- DT::datatable(df7, escape = FALSE, options = list(dom = 't',searching = FALSE,initComplete = JS(
    "function(settings, json) {",
    "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
    "}"),pageLength = 5,lengthMenu = c(5, 10), order = list(2,'desc')))
  })
data8 <- eventReactive(input$player66,{
    if(is.null(input$player6)){
      return()
    }

    choose <- switch(input$player6,
                   five = player2015,
                   six = player2016,
                   seven = player2017,
                   eight = player2018,
                   nine = player2019,
                   ten = player2020)
  df8 <- filter(choose, BLK > 0) %>%
  select(Player,BLK)
  df8 <- df8[with(df8, order(-BLK)),]
    df8 <- head(df8,n=5)
      rownames(df8)<- c()

    df8 <- DT::datatable(df8, escape = FALSE, options = list(dom = 't',searching = FALSE,initComplete = JS(
    "function(settings, json) {",
    "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
    "}"),pageLength = 5,lengthMenu = c(5, 10), order = list(2,'desc')))
  })

  output$table1 <- renderDataTable({
    data1()
  })
    output$table2 <- renderDataTable({
    data2()
  })
      output$table3 <- renderDataTable({
    data3()
  })
        output$table4 <- renderDataTable({
    data4()
    })      
    output$table5 <- renderDataTable({
    data5()
  })
        output$table6 <- renderDataTable({
    data6()
  })
          output$table7 <- renderDataTable({
    data7()
  })
        output$table8 <- renderDataTable({
    data8()
  })
  
  }
shinyApp(ui, server)
```

<!--html_preserve--><div style="width: 100% ; height: 400px ; text-align: center; box-sizing: border-box; -moz-box-sizing: border-box; -webkit-box-sizing: border-box;" class="muted well">Shiny applications not supported in static R Markdown documents</div><!--/html_preserve-->
