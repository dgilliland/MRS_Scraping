#Cleaning and Visualizing Scraped Data from mrs.org
#Lasted edited by Matt Groh on December 23, 2014

require("dplyr")
setwd("~/Desktop/MRS/")

list.files()

df1 <- read.csv("MRS1.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df2 <- read.csv("MRS2.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df3 <- read.csvC"MRS3.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df4 <- read.csvC"MRS4.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df5 <- read.csvC"MRS5.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df6 <- read.csvC"MRS6.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df7 <- read.csvC"MRS7.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df8 <- read.csvC"MRS8.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df9 <- read.csvC"MRS9.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df10 <- read.csvC"MRS10.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df11 <- read.csvC"MRS11.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df12 <- read.csvC"MRS12.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df13 <- read.csvC"MRS13.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df14 <- read.csvC"MRS14.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)

df <- rbind(df1,df2,df3,df4,df5,df6,df8,df9,df11,df12,df13,df14)

#Name Variables
colnames(df)[1] <- "URL"
colnames(df)[2] <- "Symposium"
colnames(df)[3] <- "Title"
colnames(df)[4] <- "Abstract"
df$V5 <- NULL

df <- df[!duplicated(df),]


#Generate Column Indicating Year
df$year <- NA
df$year[grepl("99",df$URL)] <- 1999
df$year[grepl("00",df$URL)] <- 2000
df$year[grepl("97",df$URL)] <- 1997
df$year[grepl("98",df$URL)] <- 1998
df$year[grepl("01",df$URL)] <- 2001
df$year[grepl("02",df$URL)] <- 2002
df$year[grepl("03",df$URL)] <- 2003
df$year[grepl("04",df$URL)] <- 2004
df$year[grepl("05",df$URL)] <- 2005
df$year[grepl("06",df$URL)] <- 2006
df$year[grepl("07",df$URL)] <- 2007
df$year[grepl("08",df$URL)] <- 2008
df$year[grepl("09",df$URL)] <- 2009
df$year[grepl("10",df$URL)] <- 2010
df$year[grepl("11",df$URL)] <- 2011
df$year[grepl("12",df$URL)] <- 2012
df$year[grepl("13",df$URL)] <- 2013
df$year[grepl("14",df$URL)] <- 2014
#Generate Column Indicating Spring or Fall Session
df$fall <- grepl("f",df$URL)
#Examine Abstract and Title Length and Drop Unwanted Scrapes
df$n <- nchar(df$Abstract)
df$awords <- sapply(strsplit(df$Abstract, "\\s+"), length)
df$twords <- sapply(strsplit(df$Title, "\\s+"), length)
df <- df[!(df$awords<20 & df$twords<10),]
df <- df[!(df$awords<15),]
df <- df[!(df$twords<7),]
#Show Number of Years, Symposiums, Abstracts Scraped
length(unique(df$year))
length(unique(df$Symposium))
length(unique(df$Abstract))

x <- df %>% group_by(year, fall) %>% summarize(count=n())
x$year[x$fall==TRUE] <- x$year[x$fall==TRUE] +.5
ggplot(x,aes(x=year,y=count)) + geom_point(size=4) +   
  xlab("Year") +
  ylab("Number of Papers") +
  ggtitle("Annual Volume of Papers Presented at MRS") +
  theme(text=element_text(size=16), panel.background=element_rect(fill='white'), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), legend.text=element_text(size=12), legend.position="none") 


ggplot(df,aes(twords)) + geom_histogram(binwidth=5)
ggplot(df,aes(awords)) + geom_histogram(binwidth=10)

View(df)


#Questions 
#(1) Term Frequency
#(2) Changes in Frequency over Time
#(3) Topic Modelling

