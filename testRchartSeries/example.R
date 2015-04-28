library(httr)
library(rCharts)
library(RJSONIO)
library(data.table)

# Settings
.API_KEY <- "qg4gmmxzubfnq9hqsdfau2kx"  # fill in your api key
.LIMIT <- 50
.URL <- sprintf(
  "http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=%s&limit=%s",
  .API_KEY,
  .LIMIT
)
# Retrieve the data from the API
movieJSON <- paste(readLines(.URL, warn = FALSE), collapse = "")
movieList <- fromJSON(movieJSON, simplify = F)
movieTable <- rbindlist(lapply(movieList$movies, function(movie) {
    data.table(
        x = movie$ratings$critics_score,
        y = movie$ratings$audience_score,
        name = sprintf("<table cellpadding='4' style='line-height:1.5'><tr><th colspan='3'>%1$s</th></tr><tr><td><img src='%2$s' height='91' width='61'></td><td align='left'>Year: %3$s<br>Runtime: %6$s<br>Audience: %7$s<br>Critics: %4$s<br>M-rating: %5$s</td></tr></table>",
            movie$title,
            movie$posters$thumbnail,
            movie$year,
            movie$ratings$critics_rating,
            movie$mpaa_rating,
            movie$runtime,
            movie$ratings$audience_rating
            ),
        url = movie$links$alternate,
        category = movie$mpaa_rating
    )
}))
# Split the list into categories
movieSeries <- lapply(split(movieTable, movieTable$category), function(x) {
    res <- lapply(split(x, rownames(x)), as.list)
    names(res) <- NULL
    return(res)
})
# Create the chart object
a <- rCharts::Highcharts$new()
invisible(sapply(movieSeries, function(x) {
        a$series(data = x, type = "scatter", name = x[[1]]$category)
    }
))
a$plotOptions(
  scatter = list(
    cursor = "pointer",
    point = list(
      events = list(
        click = "#! function() { window.open(this.options.url); } !#")),
    marker = list(
      symbol = "circle",
      radius = 5
    )
  )
)
a$xAxis(title = list(text = "Critics Score"), labels = list(format = "{value} %"))
a$yAxis(title = list(text = "Audience Score"), labels = list(format = "{value} %"))
a$tooltip(useHTML = T, formatter = "#! function() { return this.point.name; } !#")
a$colors(
  'rgba(223, 83, 83, .75)',
  'rgba(60, 179, 113, .75)',
  'rgba(238, 130, 238, .75)',
  'rgba(30, 144, 255, .75)',
  'rgba(139, 139, 131, .75)'
)
a$legend(
  align = 'right',
  verticalAlign = 'middle',
  layout = 'vertical',
  title = list(text = "M-Rating")
)
a$title(text = "Top 50 DVD Rentals")
a$subtitle(text = "Retrieved using the Rotten Tomatoes API")
# Plot it!
a