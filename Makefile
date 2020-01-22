NBA_Stats_Analysis.html: NBA_Stats_Analysis.Rmd Data/advanced.Rda Data/salary.Rda Data/team_age.Rda Data/other_players.Rda Data/player/*.Rda Data/team/*.Rda
	Rscript -e "library(rmarkdown); render('NBA_Stats_Analysis.Rmd')"

Data/player/player%.Rda: get_player.R
	mkdir -p Data/player
	Rscript $<

Data/team/team%.Rda: get_team.R
	mkdir -p Data/team
	Rscript $<

Data/advanced.Rda: get_advanced.R
	Rscript $<

Data/salary.Rda: get_salary.R
	Rscript $<

Data/team_age.Rda: team_age.R
	Rscript $<

Data/other_players.Rda: other_players.R
	Rscript $<

.PHONY: clean_html clean_data
clean_html:
	rm NBA_Stats_Analysis.html
	rm -rf NBA_Stats_Analysis_files/
	
clean_data:
	rm -rf Data/