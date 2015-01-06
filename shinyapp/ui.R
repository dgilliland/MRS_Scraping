#UI
library("shiny")

y <- read.csv("y.csv", stringsAsFactors=FALSE)

shinyUI(navbarPage(
  title = 'MRS Abstract Trends',
  tabPanel('Plot over Time',   
  titlePanel(
    "Plot Word Count in Material Research Society Abstracts over Time"
  ),
  
  titlePanel(
    img(src='wordcloud.png', align = "center", width=200, height=200),
    
  ),
  
  selectInput(inputId = "wordz",
              label = strong("\n Choose a word form a list sorted by rank correlation:"),
              choices = y$word,
              selected = "material"),
  
  checkboxInput(inputId="ion", label="Click here to activate Text Input", value = FALSE),
  
  textInput(inputId="wordchoice", label="Text Input: Search for any word", value = ""),
  
  
  
  plotOutput(outputId = "wordtime", height = "300px")),
  
  tabPanel('Summary Table',     dataTableOutput('values'))
)

)