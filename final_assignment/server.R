library(shiny)
library(leaflet)
library(RJSONIO)
# This library is not necessary if we run the ShinyApp on a local installation of R; it is necessary if we exploit shinyapps.io for running the app.

# We load in memory a data frame with cities only once, before starting the shinyServer.

# Dataset provided under MIT licence by
# http://simplemaps.com/resources/world-cities-data
# url <- 'http://simplemaps.com/static/demos/resources/world-cities/world_cities.csv'
# download.file(url, destfile = 'world_cities.csv')
cities <- read.csv('world_cities.csv');  n <- dim(cities)[1]

# The fields for latitude and longitude in the data frame are in degrees, we have to convert them in radians.
cities$lat.rad <- cities$lat * pi/180
cities$lng.rad <- cities$lng * pi/180

# Server description.
shinyServer(function(input, output, session) {
  output$text2 <- renderUI({
    HTML('Drag or enlarge to view a portion of the map; click on any point of the map to retrieve nearby cities.')  })
  
  # Creates a new map using leaflet.
  map <- createLeafletMap(session, 'map')

  # Waits for any click on the map, retrieves latitude and longitude and computes nearby cities.
  observe({
    click <- input$map_click
    
    # This instruction is used when the app starts (because there has been no click yet on the map).
    if(is.null(click))  return()
    
    # Retrieve latitude and longitude, converts them in radians.
    lat <- click$lat;    lat.rad <- lat * pi/180
    lng <- click$lng;    lng.rad <- lng * pi/180
    
    output$text1 <- renderUI({
      # Compute latitude and longitude in grads and minutes.
      coord <- c(lat, lng)
      coord.grads <- floor(coord)
      coord.minutes <- round(coord - coord.grads, 2) * 100
      coord.grad.minutes <- paste(coord.grads, '°', coord.minutes, "'", sep = '')
      
      message <- paste('The point that you chose has latitude ', coord.grad.minutes[1], ' and longitude ', coord.grad.minutes[2], '.', sep = '')
      HTML(paste('', message, sep = '<br/>'))
      })
    
    output$text3 <- renderUI({
      HTML(paste('', 'The nearby cities in our database are listed below.', '', 'At the end of the page, you will find the code implementing this ShinyApp.', '', sep='<br/>'))
    })
    
    # Removes all popups from the previous iteration, adds one with the selected spot.
    map$clearPopups()
    map$showPopup(lat, lng, 'Your choice')

    select <- rep(FALSE,n)  # Logical vector used later to select cities.
    dist <- numeric(n)      # Numeric vector storing the distances.
    names(dist) <- 1:n      # Names for the previous vector.
    for(i in 1:n){
      lat2 <- cities$lat[i]
      lng2 <- cities$lng[i]
      lat2.rad <- cities$lat.rad[i]
      lng2.rad <- cities$lng.rad[i]
      
      if(lat-lat2 > 0)
        check.lat <- (lat - lat2) %% 360
      else
        check.lat <- (lat2 - lat) %% 360
      
      if(lng-lng2 > 0)
        check.lng <- (lng - lng2) %% 360
      else
        check.lng <- (lng2 - lng) %% 360

      # Checks only the cities whose latitude and longitude differ for at most 1/10 * 360° from the selected spot.
      if(check.lat < 36  &  check.lng < 36){
        # Implement the formula for the distance from https://en.wikipedia.org/wiki/Haversine_formula
        quad <- sin((lat2.rad-lat.rad)/2)^2 + cos(lat.rad)*cos(lat2.rad)*(sin((lng.rad-lng2.rad)))^2
        R <- 6373  # R = radius of the Earth in km.
        dist[i] <- 2 * R * asin(sqrt(quad))
        # Select only the points not too far away from the selected spot.
        if (dist[i] < 10000) select[i] <- TRUE 
      }
    }
    
    # Sorts the distances and select only the closest cities.
    sort.dist <- sort(dist[select])
    n.obj <- input$number.objects   # Number of cities to retrieve.
    selected_cities <- as.numeric(names(sort.dist[1:n.obj]))
    selection <- cities[selected_cities,]
    
    # Creates the vectors Name and Distance for the final tables.
    Name <- as.character(selection$city_ascii)
    Distance <- paste(round(sort.dist[1:n.obj],1), ' km', sep = '')
    my_table <- data.frame(Name, lat = numeric(n.obj), lng = numeric(n.obj), Distance)
    
    # Converts the coordinates of the selected cities in grads and minutes.
    for(i in c("lat","lng") ){
      coord.city = selection[[i]]
      coord.city.grads <- sapply(coord.city,floor)
      coord.city.minutes <- round(coord.city - coord.city.grads, 2) * 100
      coord.city.grad.minutes <- paste(coord.city.grads, '°', coord.city.minutes, "'", sep = '')
      my_table[[i]] <- paste(coord.city.grads, '°', coord.city.minutes, "'", sep = '')
    }
  
    names(my_table) <- c("Name", "Latitude", "Longitude", "Distance")
    dim.table.left <- ceiling(n.obj/2)
    dim.table.right <- n.obj - dim.table.left
    output$table.left <- renderTable(my_table[1:dim.table.left,])
    output$table.right <- renderTable(my_table[dim.table.left+1:dim.table.right,])
    
    # Adds the marker of the selected cities on the map.
    for(i in 1:n.obj){
      my_text <- as.character(selection$city_ascii[i])
      map$showPopup(selection$lat[i], selection$lng[i], my_text)
    }

    # Updates text2.
    output$text2 <- renderUI({
      HTML(paste('', 'If you want, you can continue playing with the parameter above and/or the map.', sep = '<br/>')) })
  }) # Ends the observe({...}) routine.
  
  output$text4 <- renderUI({
    HTML(paste('Here is the code generating this ShinyApp (excluding the code from this point until the end of the page).')) })
  
}) # End of the shinyServer.