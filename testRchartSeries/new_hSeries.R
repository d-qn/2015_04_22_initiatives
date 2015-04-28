library(swiRcharts)

hSeries2 <- function(df, series) {
  # TO DO !!!! Check input that series is a character and is in the given data.frame
  seriesList <- by(df, as.factor(df[,series]), function(df.s) {
	# remove the column series of the data.frame
	seriesName <- as.character(df.s[1,series])
	df.s <- df.s[,-which(colnames(df.s) == series)]
  	list(data = rCharts::toJSONArray2(df.s, json = F, names = T), name = seriesName)
  }, simplify = F)
  attributes(seriesList) <- NULL

  seriesList
}

 library(swiTheme)

 x <- 1:10
 y <- seq(1, 100, 10)
 z <- 10:1
 color <- as.factor(rep(c("grey", "red"), 5))
 name <- c("a", "b", "c", "d", "e", "f", "g", "h", "i", "j")
 series <- c(rep(c("blob", "poop", "doop"), 3), "asdf")
 hSeries2 <- hSeries2(data.frame(x = x, y = y, z = z, color = color, name = name, series = series), "series")
 hSeries1 <- hSeries(x,y,z,name, color, series)
 identical(hSeries1, hSeries2)
 b <- rCharts::Highcharts$new()
 b$series(hSeries2)

 # tweak the bubble plot
 a$chart(zoomType = "xy", type = "bubble")
 a$plotOptions(bubble = list(dataLabels = list(enabled = T, style = list(textShadow = 'none') ,
 color = '#aa8959', formatter = "#! function() { return this.point.name; } !#")))

 a$colors(swi_rpal)
 a$tooltip(formatter = "#! function() { return this.point.name + ':' +this.x + ', ' + this.y; } !#")
 a$xAxis(title = list(text = "important indicator", align = "high"), lineColor = list ('#FF0000'))
 a
