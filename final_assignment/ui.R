library(shiny)
library(leaflet)
library(RJSONIO)
# This library is not necessary if we run the ShinyApp on a local installation of R; it is necessary if we exploit shinyapps.io for running the app.

# User interface.
shinyUI(fluidPage(
  titlePanel('Final assignment of the Developing Data Products course on Coursera'),
  h4('Author: Matteo Tommasini'),
  h4('Date: 5 December 2016'),
  h5('See the description of the assignment at the following', a('link.', href='https://www.coursera.org/learn/data-products/peer/tMYrn/course-project-shiny-application-and-reproducible-pitch')),
  h5('The current project promts the user to choose a point on a map, and how many nearby cities to select. The database of the cities that we use is available under MIT license at', a('simplemaps.com', href='http://simplemaps.com/resources/world-cities-data'), "and contains 'over 7.300 cities from around the world, including all country/province capitals, major cities and towns, as well as smaller towns in sparsely inhabited regions'."),
  h5('For each such city, the database contains (among other data) its latitude and longitude, so the correct way of computing distances in this application is via the so called', a('Haversine formula.', href='https://en.wikipedia.org/wiki/Haversine_formula')),
  h5('For a presentation of the app, we refer to the following', a('link.', href='https://matteo-tommasini.github.io/DevelopingDataProducts_FinalAssignment/')),
  tags$hr(),
  fluidRow(
    column(4,
          sliderInput('number.objects', 'Slide to select how many nearby cities to retrieve:', min = 2, max = 30, value = 4),
  
          # The next 3 lines appear after the user has selected a point on the map.
          htmlOutput('text1'),  # 'The point that you chose has latitude ... etc.'

          htmlOutput('text2'),  # 'Drag or enlarge to view a portion of the map.' / 'If you want, you can continue playing with the map.'
        
          htmlOutput('text3')  # 'The nearby cities in our database are listed below.'
        ),
    column(8,
           leafletMap('map', '100%', 400, options=list(zoom = 7, center = c(48.90, 2.28)))
           # We choose the coordinates of Paris as center of the map.
          )
  ), # End of fluidRow.
  tags$hr(),
  fluidRow( # 2 tables with nearby cities
    column(6,tableOutput('table.left')),
    column(6,tableOutput('table.right'))
  ), # End of fluidRow.
  tags$hr(),
  fluidRow(column(12, htmlOutput('text4')))
 
) # End of fluidPage.
) # End of shinyUI.