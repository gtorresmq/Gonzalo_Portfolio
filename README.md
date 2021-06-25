# Cross-Country Variability in Music Preferences with R

## Overview
- I scraped data from Kworb.net to obtain the top 200 most streamed songs per country on Spotify over the 2013-2021 period.
- For each country, I estimated which percentage of the top 200 most streamed songs did not reach the top 200 anywhere else.

## Preliminary findings
- The data contains 12,600 songs for a total of 63 countries.
- There is considerable cross-country variability on which songs reach the top 200. Most songs are "local hits": 75% of the 12,600 songs considered only reached the top 200 in one country.
- Very few songs are "worldwide hits": only 8% of songs have reached the top 200 in ten or more countries.
- The top 3 most idiosyncratic countries in terms of music preferences are Turkey, Japan and Brazil. The percentage of songs which only reached the top 200 within these countries (and not anywhere else) is 89%, 86% and 84%, respectively. This means, for example, that 178 out of the 200 most streamed songs for Turkey have not reached the top 200 in another country.
- Spanish- and English-speaking American countries together with Australia and New Zealand are the least idiosyncratic countries in terms of music preferences.

The following figure shows the cross-country variability in music preferences: 
![](https://github.com/gtorresmq/spotifydata/blob/main/images/Rplot02.png)


