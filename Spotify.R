#Spotify project
################
library(rvest)
library(spotifyr)
library(tidyverse)
library(qpcR)
library(equate)
library(purrr)
library(plotly)

setwd("C:/Users/Gonzalo/Dropbox/Programación/R/Projects/Spotify/github")

#Web scraping (Countries, codes, and charts)
###########################################
#Kworb
link_countries_kworb = "https://kworb.net/spotify/"
page_kworb = read_html(link_countries_kworb)

countries = page_kworb %>%
  html_nodes("#countrytable td:nth-child(1)") %>%
  html_text()

kworb = data.frame(countries[which(countries!="Global")])
colnames(kworb) = c("countries")

#Countrycodes
link_countrycodes = "https://www.iban.com/country-codes"
page_countrycodes = read_html(link_countrycodes)

countries = page_countrycodes %>%
  html_nodes("td:nth-child(1)") %>%
  html_text()

codes = page_countrycodes %>%
  html_nodes("td:nth-child(2)") %>%
  html_text()

countrycodes = data.frame(countries, codes)

#Join
spotifycountries = countrycodes %>%
  right_join(kworb, by = c("countries"))

spotifycountries[spotifycountries$countries=="United States",2] = "US"
spotifycountries[spotifycountries$countries=="United Kingdom",2] = "GB"
spotifycountries[spotifycountries$countries=="Bolivia",2] = "BO"
spotifycountries[spotifycountries$countries=="Czech Republic",2] = "CZ"
spotifycountries[spotifycountries$countries=="Dominican Republic",2] = "DO"
spotifycountries[spotifycountries$countries=="Netherlands",2] = "NL"
spotifycountries[spotifycountries$countries=="Philippines",2] = "PH"
spotifycountries[spotifycountries$countries=="Taiwan",2] = "TW"
spotifycountries[spotifycountries$countries=="Vietnam",2] = "VN"

spotifycountries[,2] = tolower(spotifycountries[,2])
spotifycountrycodes = spotifycountries$codes

rm(kworb, page_countrycodes, page_kworb, codes, countries, link_countries_kworb, link_countrycodes)

#Making the charts' data frame
charts = data.frame()

for (countrycode in spotifycountrycodes){

link = paste0("https://kworb.net/spotify/country/",countrycode,"_weekly_totals.html")
page = read_html(link)

songsandartists = page %>%
  html_nodes(".mp div") %>%
  html_text()

streams = page %>%
  html_nodes(".mini~ td+ td") %>%
  html_text()

streams = as.numeric(str_remove_all(streams,","))

v_countrycode = rep(countrycode, length(songsandartists))

charts = rbind(charts, data.frame(songsandartists,streams, v_countrycode)) 

}

rm(link, page, songsandartists, streams, v_countrycode, countrycode, spotifycountrycodes)

artists = str_trim(lapply(strsplit(charts$songsandartists, "-"), function(x) x[1]))
songs = str_trim(paste(
  str_trim(lapply(strsplit(charts$songsandartists, "-"), function(x) x[2])),
  sapply(str_trim(lapply(strsplit(charts$songsandartists, "-"), function(x) x[3])), function(x) ifelse(is.na(x),"",paste("-",x)))
))

charts = data.frame(charts, artists, songs)
charts = inner_join(charts,spotifycountries,by=c("v_countrycode"="codes"))

save(charts,file="charts.rda")

#Restricting charts to the top 200 songs per country
####################################################
load("charts.rda")

#Keeping only the top 200 from each country
charts200 = charts %>% 
  arrange(countries,-streams) %>%
  group_by(countries) %>%
  top_n(200,streams)

#Songs only ranked in the top 200 in one country
songsinonecountry = charts200 %>%
  group_by(songsandartists) %>%
  summarize_(onecountry = ~n()) %>%
  subset(onecountry==1)

#No duplicates of songs
charts200_son = subset(charts200[!duplicated(charts200$songsandartists),], select = c(songsandartists, songs, artists))

#Analyzing top 200 songs' variability among countries
charts200 = left_join(charts200, songsinonecountry, by=c("songsandartists"))
charts200$onecountry[is.na(charts200$onecountry)] = 0
p_songsinonecountry_percountry = charts200 %>%
  group_by(countries) %>%
  summarize(prop = mean(onecountry))

#Plot
#####
worldmap = plot_geo(p_songsinonecountry_percountry,
                    locationmode = 'country names') %>%
  add_trace(locations = ~countries,
            z = ~prop,
            color = ~prop)

g <- list(
  showframe = FALSE
)

worldmap = worldmap %>% colorbar(title = "Top 200 Songs (%)", y=0.8)
worldmap = worldmap %>% layout(
  title = list(text = "Top 200 Songs Only Charted Nationally (Per Country)", y=0.95),
  geo = g
)






