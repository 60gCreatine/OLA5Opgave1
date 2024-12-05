# For ubuntu, do not run on MAC - makes all the paths in here automatically go to Repo folder
setwd("/home/ubuntu/git/OLA5Opgave2")

#for (entry in stations) {
#  Sys.sleep(1)
#  print(entry)
#  for (station in entry$station) {
#    Sys.sleep(1)
#    print(station)
#  }
#}

library(httr)
library(rvest)
stations <- list(
  list(area = "Copenhagen", station = "HCAB"),
  list(area = "Aarhus", station = "AARH3"),
  list(area = "Rural", station = c("ANHO", "RISOE")))

args = commandArgs(trailingOnly = TRUE)
operator_area <- args[1]
operator <- args[2]

df=NULL
UserA <- "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
operator_link <- paste0("https://envs2.au.dk/Luftdata/Presentation/table/",operator_area, "/",operator)
link <- operator_link
rawres <- GET(url = link, add_headers(`User Agent`= UserA))
#if (rawres$status_code == 200) {
#  cat(paste0("Statuskoden er: ", rawres$status_code, ", begynder scraping :) \n"))
#} else { 
#  status <- paste0("Statusfejl: ", rawres$status_code, ". Kan ikke få adgang til hjemmesiden.") 
#  stop(print(status)) 
#}

content <- httr::content(rawres,as = "text", encoding = "UTF-8")
operator_js <- paste0("https://envs2.au.dk/Luftdata/Presentation/table/MainTable/",operator_area, "/",operator)
js <- operator_js

token <- read_html(content) %>% html_element("input[name=__RequestVerificationToken]") %>% html_attr("value")
post <- POST(
  url = js,
  add_headers(`User Agent`= UserA),
  body = list(`__RequestVerificationToken` = token))

table_html <- content(post, as = "text", encoding = "UTF-8")
table <- read_html(table_html)

rows <- table %>% html_elements("tr")
table_data <- rows %>% html_elements("td") %>% html_text(trim = T)
header <- table %>% html_elements("th") %>% html_text(trim = T)
header_amount <- as.numeric(length(header))
unlist <- unlist(table_data)
df <- as.data.frame(matrix(data = unlist, ncol = header_amount, byrow = T))
colnames(df) <- header
df[,2:header_amount] <- lapply(df[,2:header_amount], function(x) as.numeric(gsub(",",".",x)))
idk <- paste0(operator, " havde: ", nrow(df), " rows\n")

currentscrape <- assign(operator, df)


library(RMariaDB)

readRenviron(".Renviron")
password <- Sys.getenv("password")

con <- dbConnect(MariaDB(),
                 dbname = "airflow",
                 host = "16.170.239.179",
                 port = 3306,
                 user = "testuser",
                 password = password)

#dbWriteTable(con,operator,currentscrape)

print(nrow(currentscrape))
#rds <- paste0(HCAB,".rds")
#saveRDS(rds,"4Dec")

