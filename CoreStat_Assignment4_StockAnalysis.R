rm(list = ls())

# package
library(readr)
library(curl)

# data collection
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

# 0 obs. in github
W5000_Stock <- read.csv("D:/Simon.UR/Fall A/GBA462 Core Statistics/Core Stat Assignment/^W5000.csv")
MktRf <- read.csv("D:/Simon.UR/Fall A/GBA462 Core Statistics/Core Stat Assignment/F-F_Research_Data_Factors.CSV")

# R and Datatype conversion
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

# Hypothesis test
# Mkt
Mktdf <- merge(W5000_Stock, MktRf, by = "Date") %>%
     mutate(market_excess_return = R - RF)

#AAPL
AAPL_Stock= merge(AAPL_Stock, MktRf, by = "Date")
AAPL_Stock = AAPL_Stock %>% mutate(excess_return = R - Rf)

ols_AAPL = lm(AAPL_Stock$excess_return ~ Mktdf$market_excess_return)
print(summary(ols_AAPL)) 

#CSCO
CSCO_Stock= merge(CSCO_Stock, MktRf, by = "Date")
CSCO_Stock = CSCO_Stock %>% mutate(excess_return = R - Rf)

ols_CSCO = lm(CSCO_Stock$excess_return ~ Mktdf$market_excess_return[4:nrow(Mktdf)])
print(summary(ols_CSCO)) 

#HD
HD_Stock= merge(HD_Stock, MktRf, by = "Date")
HD_Stock = HD_Stock %>% mutate(excess_return = R - Rf)

ols_HD = lm(HD_Stock$excess_return ~ Mktdf$market_excess_return)
print(summary(ols_HD))

#VZ
VZ_Stock= merge(VZ_Stock, MktRf, by = "Date")
VZ_Stock = VZ_Stock %>% mutate(excess_return = R - Rf)

ols_VZ = lm(VZ_Stock$excess_return ~ Mktdf$market_excess_return)
print(summary(ols_VZ)) 


library(readxl)
rfj <- read_excel("D:/Simon.UR/Fall A/GBA462 Core Statistics/rfj_data_Q2.xlsx")
#regression model
ols_Tropicana <- summary(lm(q1 ~ p1, data = rfj))
ols_MinuteMade <- summary(lm(q2 ~ p2, data = rfj))
ols_PrivateLabel<- summary(lm(q3 ~ p3, data = rfj))

#extract alpha and beta
alpha_Tropicana <- coef(ols_Tropicana)[1]
beta_Tropicana <- coef(ols_Tropicana)[2]

alpha_MinuteMade <- coef(ols_MinuteMade)[1]
beta_MinuteMade <- coef(ols_MinuteMade)[2]

alpha_PrivateLabel <- coef(ols_PrivateLabel)[1]
beta_PrivateLabel <- coef(ols_PrivateLabel)[2]

#elasticity
p_elasticity_Tropicana <- beta_Tropicana * (mean(rfj$p1) / mean(rfj$q1))
p_elasticity_MinuteMade <- beta_MinuteMade * (mean(rfj$p2) / mean(rfj$q2))
p_elasticity_PrivateLabel <- beta_PrivateLabel * (mean(rfj$p3) / mean(rfj$q3))

#optimization
profit_Tropicana <- function(price) {
     profit <- (price - 0.01) * (alpha_Tropicana + (beta_Tropicana * price))
     return(profit)
}
optimize(profit_Tropicana, 
         interval = c(min(rfj$p1), max(rfj$p1)), 
         maximum = TRUE)

profit_MinuteMade <- function(price) {
     profit <- (price - 0.01) * (alpha_MinuteMade + (beta_MinuteMade * price))
     return(profit)
}
optimize(profit_MinuteMade, 
         interval = c(min(rfj$p2), max(rfj$p2)), 
         maximum = TRUE)

profit_PrivateLabel<- function(price) {
     profit <- (price - 0.01) * (alpha_PrivateLabel + (beta_PrivateLabel * price))
     return(profit)
}
optimize(profit_PrivateLabel, 
         interval = c(min(rfj$p3), max(rfj$p3)), 
         maximum = TRUE)
