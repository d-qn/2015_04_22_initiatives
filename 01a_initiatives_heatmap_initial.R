library("swiTheme")
library("swiRcharts")
library("dplyr")
library("rjson")
library("gsheet")

############################################################################################
###		SETTINGS
############################################################################################

votefile <- "data/VOTEScsv_cleaned.csv"

#votefile <- "https://docs.google.com/spreadsheets/d/10dZ9GkOo25Nm9l71-zuS-tzGc5H5HWYEdBDvq8lF0kI/edit?usp=sharing"


############################################################################################
###		load initiative data
############################################################################################
#b<- gsheet2tbl(votefile)

initiatives.read <- read.csv(votefile, check.names = F, stringsAsFactors = F, encoding = "latin1")


# reverse order
initiatives.read <- initiatives.read[rev(as.numeric(rownames(initiatives.read))),]

# filter columns
initiatives <- initiatives.read %>% select(`Date of Votes`, `Title in English`, `Title in German`, `Title in French`, `Title in Italien`, `Yes [%]`, `Theme codes`, `Result`)
# transform date to date
initiatives$date <- as.Date(initiatives$`Date of Votes`)

initiatives$year <- as.numeric(substr(initiatives$`Date of Votes`,1, 4))
# add counter iniitiative per year
initiatives <- do.call(rbind, by(initiatives, initiatives$year, function(ii) {
	cbind(ii, n = 0:(nrow(ii)-1))
}))


############################################################################################
###		Plot
############################################################################################

## PLOT SETTINGS
plot.height <- 400


data <- initiatives %>% select (`Title in English`, `year`, `n`,  `Yes [%]`)
colnames(data) <- c('name', 'x', 'y', 'value')
# add HTML break for name longer than given threshold
data$name <- gsub('(.{1,50})(\\s|$)', '\\1\\<br\\>', data$name)


a <- Highcharts$new()

# use type='heatmap' for heat maps
a$chart(zoomType = "xy", type = 'heatmap', height = plot.height, plotBackgroundColor = "#f7f5ed")

a$series( data = rCharts::toJSONArray2(data, json = F, names = T))
# seriesList <- by(data, as.factor(data$series), function(df.s) {
#     list(
#       data = lapply(1:nrow(df.s), function(i) list(x = df.s[i,'x'], y = df.s[i,'y'], value = as.character(df.s[i,'value']), name = as.character(df.s[i,'name']))),
#       name = as.character(df.s$series[1])
#     )
#   }, simplify = F)
# attributes(seriesList) <- NULL
#a$series( data = seriesList)

a$addParams(colorAxis =
  list(min = 0, max = 100, stops = list(
	  list(0, '#ab3d3f'),
      list(0.499, '#EED8D9'),
      list(0.5, '#ADC2C2'),
      list(1, '#336666')
  ))
)

a$legend(align='center',
         layout='horizontal',
         margin=-42,
		 width = 100,
         verticalAlign='top',
         symbolHeight=5
		 )

a$xAxis(min = min(data$x), max = max(data$x), ceiling = max(data$x), maxPadding = 0, tickAmount = 2,title = list(text = ""))
a$yAxis(min = min(data$y), max = max(data$y),
	maxPadding = 0, lineWidth = 0, minorGridLineWidth = 0, lineColor = 'transparent', title = list(text = ""),
	labels = list(enabled = FALSE), minorTickLength = 0, tickLength =  0,gridLineWidth =  0, minorGridLineWidth = 0)




formatter <- "#! function() { return '<div class=\"tooltip\" style=\"color:#686868;font-size:0.8em\">In <b>' + this.point.x + ',</b> the initative:<br><i>' +
	this.point.name + '</i>gathered <b>' + this.point.value + '%</b> of yes</div>'; } !#"
#a$tooltip(formatter = formatter, useHTML = T, backgroundColor = 'rgba(255,255,255,0.8)', positioner = "#! function () { return {x: 20, y:80};} !#" )
a$tooltip(formatter = formatter, useHTML = T, borderWidth = 2, backgroundColor = 'rgba(255,255,255,0.8)')

a$addAssets(
   c(#"https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js",
     # "https://code.highcharts.com/highcharts.js",
     # "https://code.highcharts.com/highcharts-more.js",
     #"https://code.highcharts.com/modules/exporting.js",
     "https://code.highcharts.com/modules/heatmap.js"
     )
)
#a

a$save(destfile = 'initiative.html')

yRange <- paste(range(data$x), collapse = "-")

output.html <- "initiative_heatmap.html"
hChart2responsiveHTML("initiative.html", output.html = output.html, h2 = "Les initiatives populaires suisses",
descr = paste("INTERACTIF: Explorer toutes les initiatives populaires soumises au vote national en Suisse de ", yRange,
	". Le % de oui pour chaque initiative populaire est coloré en rouge (moins de 50%) ou vert (plus de 50% de oui).
	Sélectionner une région ou pincer pour zoomer. Déplacer votre curseur ou tapoter sur un carré pour en lire plus sur l'initiative. ", sep =""),
	source = "source: C2D.ch", h3 = "", author = "Duc-Quang Nguyen | swissinfo.ch")
browseURL(output.html)

