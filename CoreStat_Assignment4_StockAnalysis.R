rm(list = ls())

library(readr)
library(curl)

url_AAPL <- "https://raw.githubusercontent.com/JiyaYUN/CoreStatAssignment4/main/AAPL.csv"
url_CSCO <- "https://raw.githubusercontent.com/JiyaYUN/CoreStatAssignment4/main/CSCO.csv"
url_HD <- "https://raw.githubusercontent.com/JiyaYUN/CoreStatAssignment4/main/HD.csv"
url_VZ <- "https://raw.githubusercontent.com/JiyaYUN/CoreStatAssignment4/main/VZ.csv"
url_W5000 <- "https://github.com/JiyaYUN/CoreStatAssignment4/blob/main/W5000.csv"
url_MktRf <- "https://github.com/JiyaYUN/CoreStatAssignment4/blob/main/F-F_Research_Data_Factors.CSV"


AAPL <- "AAPL.csv" 
CSCO <- "CSCO.csv"
HD <- "HD.csv"
VZ <- "VZ.csv"
W5000 <- "W5000.csv"
MktRf <- "MktRf.csv"

curl_download(url_AAPL, AAPL)
curl_download(url_CSCO, CSCO)
curl_download(url_HD, HD)
curl_download(url_VZ, VZ)
curl_download(url_W5000, W5000)
curl_download(url_MktRf, MktRf)

AAPL_Stock <- read.csv(AAPL)
CSCO_Stock <- read.csv(CSCO)
HD_Stock <- read.csv(HD)
VZ_Stock <- read.csv(VZ)

W5000_Stock <- read.csv("D:/Simon.UR/Fall A/GBA462 Core Statistics/Core Stat Assignment/^W5000.csv")
MktRf <- read.csv("D:/Simon.UR/Fall A/GBA462 Core Statistics/Core Stat Assignment/F-F_Research_Data_Factors.CSV")

library(dplyr)
AAPL_Stock <- na.omit(
     AAPL_Stock %>%
          select(Date, Open) %>%
          mutate(Date = as.Date(Date, format = "%m/%d/%Y"),
                 R = (Open - lag(Open)) / lag(Open)
          )
)

CSCO_Stock <- na.omit(
     CSCO_Stock %>%
          select(Date, Open) %>%
          mutate(Date = as.Date(Date, format = "%m/%d/%Y"),
                 R = (Open - lag(Open)) / lag(Open)
          )
)

HD_Stock <- na.omit(
     HD_Stock %>%
          select(Date, Open) %>%
          mutate(Date = as.Date(Date, format = "%m/%d/%Y"),
                 R = (Open - lag(Open)) / lag(Open)
          )
)

VZ_Stock <- na.omit(
     VZ_Stock %>%
          select(Date, Open) %>%
          mutate(Date = as.Date(Date, format = "%m/%d/%Y"),
                 R = (Open - lag(Open)) / lag(Open)
          )
)

MktRf <- na.omit(
     MktRf %>%
     select(Date, MktRF, RF) %>%
     mutate(
          Date = as.Date(Date, format = "%m/%d/%Y"),
          Rm = (MktRF - lag(MktRF)) / lag(MktRF),
          Rf = (RF - lag(RF)) / lag(RF)
     )
)

W5000_Stock <- na.omit(
     W5000_Stock %>% 
     select(Date, Open) %>%
     mutate(
          Date = as.Date(Date, format = "%m/%d/%Y"), 
          Open = (Open) / 100,
          R = Open - lag(Open) / lag(Open)
     )
)

Mktdf <- merge(W5000_Stock, MktRf, by = "Date") %>%
     mutate(market_excess_return = R - RF)

AAPL_Stock= merge(AAPL_Stock, MktRf, by = "Date")
AAPL_Stock = AAPL_Stock %>% mutate(excess_return = R - Rf)

ols = lm(AAPL_Stock$excess_return ~ Mktdf$market_excess_return)
print(summary(ols)) 
