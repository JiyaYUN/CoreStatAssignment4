rm(list = ls())

library(readr)
library(curl)

url_AAPL <- "https://raw.githubusercontent.com/JiyaYUN/CoreStatAssignment4/main/AAPL.csv"
url_CSCO <- "https://raw.githubusercontent.com/JiyaYUN/CoreStatAssignment4/main/CSCO.csv"
url_HD <- "https://raw.githubusercontent.com/JiyaYUN/CoreStatAssignment4/main/HD.csv"
url_VZ <- "https://raw.githubusercontent.com/JiyaYUN/CoreStatAssignment4/main/VZ.csv"
url_W5000 <- "https://raw.githubusercontent.com/JiyaYUN/CoreStatAssignment4/main/%5EW5000.csv"

AAPL <- "AAPL.csv" 
CSCO <- "CSCO.csv"
HD <- "HD.csv"
VZ <- "VZ.csv"
W5000 <- "W5000.csv"

curl_download(url_AAPL, AAPL)
curl_download(url_CSCO, CSCO)
curl_download(url_HD, HD)
curl_download(url_VZ, VZ)
curl_download(url_W5000, W5000)

AAPL_Stock <- read.csv(AAPL)
CSCO_Stock <- read.csv(CSCO)
HD_Stock <- read.csv(HD)
VZ_Stock <- read.csv(VZ)
W5000_Stock <- read.csv(W5000)
