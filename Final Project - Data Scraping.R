
##############
#LOAD PACKAGES
##############

library("rvest")
library("httr")
library("twitteR")
library("dplyr")
library("stringr")
library("lubridate")
library("readr")



########
#WEBPAGE
########
  
#This example will just be scraping the data for last names beginning with 'a' - to get the other names you will need to repeat the steps for all letters of the alphabet
  
#This is the first webpage where all the names are listed
#For each letter you need to change the end character to the letter you are trying to scrape - in this case it is an 'a' and we will get the last names that begin with 'a'
webpage <- read_html("https://ideas.repec.org/i/ea.html")
  
#This is the webpage that will take us to the individual's bios - get the first name, last name, and user ID
webpage.1 <- ("https://ideas.repec.org")
  
#This is the webpage where you get the citations - the h index, i10 index, and number of citations
#You will need to change the letter at the end for each letter in the alphabet - in this case we are using 'a'
webpage.2 <- ("http://citec.repec.org/p/a/")
  
#This is a list of all the Economists on Twitter
webpage.3 <- read_html("https://ideas.repec.org/i/etwitter.html")
  
#This webpage will be used to scrape the Twitter data - number of followers, number following, and number of tweets
webpage.4 <- ("https://twitter.com/")
  
#Use the first webpage to scrape the individual URLs for each Economist
webpage.names <- webpage %>% html_nodes("td a") %>% html_attr("href")


###########
#FIRST LOOP
###########
    
#Paste the individual webpages for each user into the larger URL from webpage.1 - this will allow the loop to go to each Economist's individual page to get their information
temp.webpage <- paste0(webpage.1, webpage.names)
  
#Create a vector for the information to be stored in
records <- vector("list", length = length(temp.webpage))
  
#Create a loop that will collect the data for the first name, last name, and ID of each Economist
for (i in seq_along(temp.webpage)){
  tryCatch(
    {
      first.name <- read_html(temp.webpage[i]) %>% html_nodes("tr:nth-child(1) td+ td") %>% html_text(.)
      last.name  <- read_html(temp.webpage[i]) %>% html_nodes("tr:nth-child(3) td+ td") %>% html_text(.)
      ID         <- read_html(temp.webpage[i]) %>% html_nodes("tr:nth-child(5) td+ td") %>% html_text(.)
    },
    error = function(e) print("NA")
  )
  records[[i]] <- data_frame(first.name = first.name, last.name = last.name, ID = ID)
}
  
#Bind the rows together into a data frame
df <- bind_rows(records)
  
#Create the CSV file for the records collected in the loop
write_csv(df1, "records-1.csv")
 
 
############
#SECOND LOOP
############
  
#Read in the CSV file you just created to be used for the next loop
records.1 <- read.csv("records-1.csv")
  
#Create a new webpage by pasting the ID number from the CSV file in with the citations webpage and adding .html to the end
temp.webpage.2 <- paste0(webpage.2, records.1$ID, '.html')
  
#Create a vector for the information to be stored in
records.2 <- vector("list", length = length(temp.webpage.2))
  
#Create a loop that will collect the data from the citation cite - the h.index, i10.index, and number of citations
for (i in seq_along(temp.webpage.2)){
  tryCatch(
    {  
      h.index   <- read_html(temp.webpage.2[i]) %>% html_nodes("#Ahindex:nth-child(1) .indData") %>% html_text(.)
      i10.index <- read_html(temp.webpage.2[i]) %>% html_nodes("#Ahindex:nth-child(2) .indData") %>% html_text(.)
      citations <- read_html(temp.webpage.2[i])%>% html_nodes("#Ahindex~ #Ahindex+ #Ahindex .indData") %>% html_text(.)
    },
    error = function(e) print("NA")
  )
  records.2[[i]] <- data_frame(h.index = h.index, i10.index = i10.index, citations = citations)
}
  
#Bind the records into a data frame
df2 <- bind_rows(records.2)
  
#Create a CSV of the data frame
write_csv(df2, "records-2.csv")
  
  
#################
#TWITTER LOOP ONE
#################
  
#Scrape the URL's of the Economists with Twitter accounts
names.twitter <- webpage.3 %>% html_nodes("td a") %>% html_attr("href")
  
#Paste the Economist's URLs into the equation to go to their pages
temp.webpage.twitter <- paste0(webpage.1, names.twitter)
  
#Create a vector to collect information
records.twitter <- vector("list", length(temp.webpage.twitter))
  
#Create a loop to collect the first name, last name, and twitter handle of every Economist with a Twitter
for(i in seq_along(temp.webpage.twitter)){
  tryCatch(
    {
      first.name <- read_html(temp.webpage.twitter[i]) %>% html_nodes("tr:nth-child(1) td+ td") %>% html_text(.)
      last.name  <- read_html(temp.webpage.twitter[i]) %>% html_nodes("tr:nth-child(3) td+ td") %>% html_text(.)
      ID         <- read_html(temp.webpage.twitter[i]) %>% html_nodes("tr:nth-child(5) td+ td") %>% html_text(.)
      twitter    <- read_html(temp.webpage.twitter[i]) %>% html_nodes("tr:nth-child(10) td+ td") %>% html_text(.)
    },
    error = function(e) print("NA")
  )
  records.twitter[[i]] <- data_frame(first.name = first.name, last.name = last.name, ID = ID, twitter = twitter)
}
  
#Bind the records together
df.twitter <- bind_rows(records.twitter)
  
#Create a CSV with the Twitter Economist's info
write_csv(df.twitter, "records-twitter.csv")
  
#################
#TWITTER LOOP TWO
#################
    
#Read in the CSV file of Twitter Users - you will have to do this for each letter, again we are starting with 'a' 
twitter <- read.csv("twitter-a.csv")
  
#Paste the Twitter User names into the webpage and then '.hmtl'
temp.webpage.twitter2 <- paste0(webpage.2, twitter$ID, '.html')
  
#Create a vector to store the citation information
records.twitter2 <- vector("list", length = length(temp.webpage.twitter2))
  
#Create a loop to collect the citation information
for (i in seq_along(temp.webpage.twitter2)){
  tryCatch(
    {
      h.index   <- read_html(temp.webpage.twitter2[i]) %>% html_nodes("#Ahindex:nth-child(1) .indData") %>% html_text(.)
      i10.index <- read_html(temp.webpage.twitter2[i]) %>% html_nodes("#Ahindex:nth-child(2) .indData") %>% html_text(.)
      citations <- read_html(temp.webpage.twitter2[i]) %>% html_nodes("#Ahindex~ #Ahindex+ #Ahindex .indData") %>% html_text(.)
    },
    error = function(e) print("NA")
  )
  records.twitter2[[i]] <- data_frame(h.index = h.index, i10.index = i10.index, citations = citations)
}
  
#Bind the rows
df.twitter2 <- bind_rows(records.twitter2)
  
#Create the CSV file of the Twitter User's citations
write_csv(df.twitter2, "twitter-a2.csv")
  
###################
#TWITTER LOOP THREE
###################

#Read in all the Economists on Twitter
twitter <- read_csv("records-twitter.csv")

#Select the twitter usernames for each economist
username <- (twitter$twitter)

#Each username has a space in front of it, trim that so we can insert it into the Twitter URL
username <- trimws(username, "l")

#Paste the Twitter usernames with the webpage for Twitter
temp.webpage.twitter3 <- paste0(webpage.4, username)
  
#Create a vector to collect the Twitter data
records.twitter3 <- vector("list", length = length(temp.webpage.twitter3))
  
#Create a loop to collect the Twitter data - number of tweets, followers, and following
#For some reason the tweets come with a '\n' at the end of them so you will need to trim that
for (i in seq_along(temp.webpage.twitter3)){
  tryCatch(
    {
      tweets    <- read_html(temp.webpage.twitter3[i]) %>% html_nodes(".is-active .ProfileNav-value") %>% html_text(trim = TRUE)
      following <- read_html(temp.webpage.twitter3[i]) %>% html_nodes(".ProfileNav-item--following .ProfileNav-value") %>% html_text(.)
      followers <- read_html(temp.webpage.twitter3[i]) %>% html_nodes(".ProfileNav-item--followers .ProfileNav-value") %>% html_text(.)
    },
    error = function(e) print("NA")
  )
  records.twitter3[[i]] <- data_frame(tweets = tweets, following = following, followers = followers)
}
  
#Bind together the Twitter data
df.twitter3 <- bind_rows(records.twitter3)
  
#Create a CSV
write_csv(df.twitter3, "records-twitter3.csv")
  
  
  
