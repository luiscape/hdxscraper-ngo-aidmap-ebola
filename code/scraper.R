## Downloading and organizing NGO AidMap's entries for 
## Ebola-related projects. 

# Dependencies
library(RCurl)

# Helper functions.
source('tool/code/write_tables.R')
source('tool/code/sw_status.R')

# Downloading the full-dataset.
downloadFile <- function(url = NULL) {
  download.file(url, "tool/data/original-data.csv") 
}

# Function for segmenting it with the Ebola tags.
segmentData <- function(methods = is.numeric()) {
  data <- read.csv('tool/data/original-data.csv')
  for (i in 1:methods) {
    if (i == 1) {
      it <- data[grep('ebola', data$project_name, ignore.case = TRUE), ]
      outputData <- it
    }
    if (i == 2) {
      it <- data[grep('ebola', data$project_tags, ignore.case = TRUE), ] 
      outputData <- rbind(outputData, it)
    }
  }
  outputData <- outputData[duplicated(outputData) == F, ]
}

# Running.
outputData = segmentData(2)

runScraper <- function() {
  downloadAndSegment <- function(url, methods) {
    downloadFile(url)
    segmentData(methods)
  }
  downloadAndSegment(url = 'http://ngoaidmap.org/sites/download/12.csv',
                     methods = 2)
  
  # Storing output.
  writeTables(outputData, "ngo_aidmap_ebola", "scraperwiki")
  write.csv(outputData, "tool/data/output-data.csv", row.names = FALSE)
}


# Changing the status of SW.
tryCatch(runScraper(),
         error = function(e) {
           cat('Error detected ... sending notification.')
           system('mail -s "NGO AidMap Ebola failed." luiscape@gmail.com')
           changeSwStatus(type = "error", message = "Scraper failed.")
           { stop("!!") }
         }
)
# If success:
changeSwStatus(type = 'ok')
