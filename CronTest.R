setwd("/home/ubuntu/git/OLA5Opgave2")
sysTime <- as.data.frame(Sys.time())
library(RMariaDB)

readRenviron(".Renviron")
password <- Sys.getenv("password")

con <- dbConnect(MariaDB(),
                 dbname = "airflow",
                 host = "16.170.239.179",
                 port = 3306,
                 user = "testuser",
                 password = password)

dbWriteTable(con,"crontabTest",sysTime, append = TRUE)

dbDisconnect(con)
