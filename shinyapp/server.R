 #Server

library("ggplot2")
library("shiny")


data <- read.csv("date.csv",stringsAsFactors=FALSE)
# y <- data %>% group_by(word) %>% summarize(count=n(), mean=mean(rank), sd=sd(rank), skew=skewness(rank),kurt=kurtosis(rank), corr=cor(rank,year))
# y <- y[y$count>5 & y$corr<0,]
# y <- y[order(y$corr),]
# write.csv(y,"y.csv")
y <- read.csv("y.csv",stringsAsFactors=FALSE)
names(y)
y$X <- NULL
colnames(y)[1] <- "Word"
colnames(y)[2] <- "Years.Appearing"
colnames(y)[3] <- "Mean.Rank"
colnames(y)[4] <- "StandardDev.Rank"
colnames(y)[5] <- "Skewness.Rank"
colnames(y)[6] <- "Kurtosis.Rank"
colnames(y)[7] <- "Corr.Rank"
data$X <- NULL

shinyServer(function(input,output) {
  
  
  output$wordtime <- renderPlot ({
    
    x <- data[data$word==input$wordz,]
    if (input$ion==TRUE) {
      x <- data[data$word==tolower(input$wordchoice),]
    }
      ggplot(x,aes(x=year,y=rank)) + geom_point(size=5) +   
        xlab("Year") +
        ylab("Word Rank") +
        ggtitle(paste("Rank of", capitalize(unique(x$word)), "in MRS Abstracts by Number of Occurences", sep=" ")) +
        theme(text=element_text(size=16), panel.background=element_rect(fill='white'), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), legend.text=element_text(size=12), legend.position="none") 
    
    
  })
  
  output$values <- renderDataTable(y, options = list(paging = FALSE))
  

})
