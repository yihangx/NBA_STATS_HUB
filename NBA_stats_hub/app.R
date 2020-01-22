#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(tidyverse)
library(jsonlite)
library(dplyr)
library(httr)
library(shiny)
library(shinydashboard)
library(htmltools)
library(DT)

team2015 <- readRDS("Data/team/team_2015.Rda")
team2016 <- readRDS("Data/team/team_2016.Rda")
team2017 <- readRDS("Data/team/team_2017.Rda")
team2018 <- readRDS("Data/team/team_2018.Rda")
team2019 <- readRDS("Data/team/team_2019.Rda")
team2020 <- readRDS("Data/team/team_2020.Rda")

player2015 <- readRDS("Data/player/player_2015.Rda")
player2016 <- readRDS("Data/player/player_2016.Rda")
player2017 <- readRDS("Data/player/player_2017.Rda")
player2018 <- readRDS("Data/player/player_2018.Rda")
player2019 <- readRDS("Data/player/player_2019.Rda")
player2020 <- readRDS("Data/player/player_2020.Rda")

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

# Define UI for application that draws a histogram
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

# Run the application 
shinyApp(ui = ui, server = server)
