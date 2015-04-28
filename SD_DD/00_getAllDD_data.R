
# warning it wil delete the data.file from the ~/Downloads folder

############################################################################################
###		SETTINGS
############################################################################################



data.file <- 'VOTEScsv.csv'
data.path <- file.path("~/Downloads", data.file)
output.file <- file.path(".", paste(data.file, "_", Sys.Date(), ".csv", sep =""))
# the number of rows at the bottom to be discarded
footerLength <- 5

allDataPath <- "http://www.c2d.ch/votes.php?level=1&country=0&yearr=allyears&speyear%5B%5D=2015&result=0&terms=&table=votes&sub=Submit_Query"
path <- "http://www.c2d.ch/ref_export.php?lname=votes&table=votes&level=1&country=0&type=csv"

############################################################################################
###	download the data file
############################################################################################

# remove the data.file if exists in the download folder!
if(file.exists(data.path)) {
	file.remove(data.path)
}
browseURL(allDataPath)
Sys.sleep(3)
browseURL(path)
Sys.sleep(7)

# move the downloaded file to the working directory
stopifnot(file.rename(data.path, output.file))


############################################################################################
###
############################################################################################

cat("\n", "open the file with Western european encoding iso and resave it!!!\n")
Sys.sleep(30)

############################################################################################
###	cleanup the data file
############################################################################################
data.read.lines <- readLines(output.file)
length(data.read.lines) - footerLength


data <- read.csv(text = data.read.lines, check.names = F, stringsAsFactors = F, encoding = "latin1")
data[,1] <- as.numeric(data[,1])