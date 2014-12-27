#Cleaning and Visualizing Scraped Data from mrs.org
#Last edited by Matt Groh on December 23, 2014

require("dplyr")
require("ggplot2")
require("wordcloud")
require("tm")
require("NLP")
require("cwhmisc")
require("slam")
require("e1071")
require("Hmisc")


setwd("~/Desktop/MRS/")

list.files()

df1 <- read.csv("MRS1001.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df2 <- read.csv("MRS1002.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df3 <- read.csv("MRS1003.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df4 <- read.csv("MRS1004.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df5 <- read.csv("MRS1005.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df6 <- read.csv("MRS1006.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df7 <- read.csv("MRS1007.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df8 <- read.csv("MRS1008.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df9 <- read.csv("MRS1009.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df10 <- read.csv("MRS1010.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df11 <- read.csv("MRS1011.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df12 <- read.csv("MRS1012.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df13 <- read.csv("MRS1013.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)
df14 <- read.csv("MRS1014.csv",sep="\t",header=FALSE, stringsAsFactors=FALSE)

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


#ggplot(df,aes(twords)) + geom_histogram(binwidth=5)
ggplot(df,aes(awords)) + geom_histogram(binwidth=10)

View(df)

#Questions 

#(1) Term Frequency

mach_corpus <- Corpus(VectorSource(as.character(df$Abstract)))
#(1a) Create Document Term Matrix
tdm <- TermDocumentMatrix(mach_corpus,
                          control = list(removePunctuation = TRUE,
                                         stopwords = c(stopwords("english"),"well","also","like","will","one","two"),
                                         removeNumbers = TRUE, tolower = TRUE))
tdm2 <- removeSparseTerms(tdm, 0.99999)
dtm3 <- rollup(tdm, 2, na.rm=TRUE, FUN = sum)

#(1b) define TDM as Matrix
m = as.matrix(dtm3)
n<-data.frame(m)
n<-data.frame(as.character(rownames(n)),n)
colnames(n)[1]="word"
colnames(n)[2]<-"count"
n<-n[order(-n$count),]


#(1c) Plot Wordcloud
wordcloud(n$word[1:200], n$count[1:200], random.order=FALSE, colors=brewer.pal(8, "Dark2"))
View(n)

# save the image in png format
png("MRS_WordCloud.png", width=12, height=8, units="in", res=300)
wordcloud(n$word[1:200], n$count[1:200], random.order=FALSE, colors=brewer.pal(8, "Dark2"))
dev.off()


c(1997:1999,2007:2011)

#(2) Changes in Frequency over Time
for (i in c(1997:1999,2007:2011)) {
mach_corpus <- Corpus(VectorSource(as.character(df$Abstract[df$year==i])))
tdm <- TermDocumentMatrix(mach_corpus,
                          control = list(removePunctuation = TRUE,
                                         stopwords = c(stopwords("english"),"well","also","like","will","one","two"),
                                         removeNumbers = FALSE, tolower = TRUE))
tdm2 <- removeSparseTerms(tdm, 0.99999)
dtm3 <- rollup(tdm, 2, na.rm=TRUE, FUN = sum)
m = as.matrix(dtm3)
n<-data.frame(m)
n<-data.frame(as.character(rownames(n)),n)
colnames(n)[1]="word"
colnames(n)[2]<-"count"
n<-n[order(-n$count),]
#n <- n[1:100,]
n$rank <- seq_along(1:length(n$count)) 
n$year <- i
assign(paste("y",i,sep=""),n)
}

data <- rbind(y1997,y1998,y1999,y2007,y2008,y2009,y2010,y2011)

y <- data %>% group_by(word) %>% summarize(count=n(), mean=mean(rank), sd=sd(rank), skew=skewness(rank),kurt=kurtosis(rank), corr=cor(rank,year))
y <- y[y$count>5 & y$corr<0,]
y <- y[order(y$corr),]
View(y)

m="silicon"
m="carbon"
m="nanowires"
m="nanofibers"
m="zno"


x <- data[data$word==m,]

ggplot(x,aes(x=year,y=rank)) + geom_point(size=5) +   
  xlab("Year") +
  ylab("Word Rank") +
  ggtitle(paste("Rank of", capitalize(m), "in MRS Abstracts by Number of Occurences", sep=" ")) +
  theme(text=element_text(size=16), panel.background=element_rect(fill='white'), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), legend.text=element_text(size=12), legend.position="none") 



View(y)

#(3) Topic Modelling
 

#Clean up Document Term Matrix
a.tdm.sp.t <- t(tdm2) # transpose document term matrix, necessary for the next steps using mean term frequency-inverse document frequency (tf-idf) to select the vocabulary for topic modeling
summary(col_sums(a.tdm.sp.t)) # check median...
term_tfidf <- tapply(a.tdm.sp.t$v/row_sums(a.tdm.sp.t)[a.tdm.sp.t$i], a.tdm.sp.t$j,mean) * log2(nDocs(a.tdm.sp.t)/col_sums(a.tdm.sp.t>0)) # calculate tf-idf values
summary(term_tfidf) # check median... note value for next line... 
a.tdm.sp.t.tdif <- a.tdm.sp.t[,term_tfidf>=1.0] # keep only those terms that are slightly less frequent that the median
a.tdm.sp.t.tdif <- a.tdm.sp.t[row_sums(a.tdm.sp.t) > 0, ]
summary(col_sums(a.tdm.sp.t.tdif)) # have a look

#Choose the number of topics
ntop <-5
lda <- LDA(a.tdm.sp.t.tdif, ntop) # generate a LDA model the optimum number of topics
user_topic <- posterior(lda)[[2]]  # rows give each document’s proportion from each topic   

get_terms(lda, 5) # get keywords for each topic, just for a quick look

