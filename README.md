# Final Project - Economists of Twitter

This is my final project for ECON 5970 - Data Science for Economists. In this project I scraped data from the RePEc website on all
the Economists they had in their system, as well as data on all the Economists that had registered their Twitter accounts with RePEc.
I then look at the profiles of each of these categories of Economist - ones that are on Twitter and ones that aren't. In this README 
document I will go over how to replicate my results.

## Collecting the Data

I will first go over how I collected the data for this project, which I did through R and Excel.

First you will need to go into R and load several packages

```
library("rvest")
library("httr")
library("twitteR")
library("dplyr")
library("stringr")
library("lubridate")
library("readr")
```
Next you will need to read in the various website that will be used. The main ones are the RePEc website which will be used to get the names and ID's for the Economists, the CitEc website which will be used to gather the citation information on the Economists, and Twitter's main webiste which will be used to gather the Twitter information for those Economists on Twitter.

```
#This example will just be scraping the data for last names beginning with 'a' - to get the other names you will need to repeat the steps for all letters of the alphabet
  
#This is the first webpage where all the names are listed
#For each letter you need to change the end character to the letter you are trying to scrape - in this case it is an 'a' and we will get the last names that begin with 'a' - if we wanted to get the last names beginning with 'b' we would need to replace the '/ea.html' with '/eb.html'
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
 ```
Now we will start actually scraping the data. The first step is to go to the main RePEc webiste and get the URL for each Economist. This will be used to take us to each of their pages. Since the Economists are listed by last name, you will need to do this individually for each letter of the alphabet.
```
#Use the first webpage to scrape the individual URLs for each Economist
webpage.names <- webpage %>% html_nodes("td a") %>% html_attr("href")
```
We will now use the URL to go to each Economist's indiviual page on the RePEc webiste and gather their first and last names, as well as their specific ID number.

```
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
 ```
 Next, we will use the ID's we just scraped to create another loop, which will go to the individual's page on CitEc and gather their h.index, i10.index, and citations.
 ```
 #Read in the CSV file you just created to be used for the next loop
records.1 <- read.csv("records-1.csv")
  
#Create a new webpage by pasting the ID number from the CSV file in with the citations webpage and adding .html to the end
temp.webpage.2 <- paste0(webpage.2, records.1$ID, '.html')
  
#Create a vector for the information to be stored in
records.2 <- vector("list", length = length(temp.webpage.2))
  
#Create a loop that will collect the data from the citation cite - the h.index, i10.index, and number of citations, and number of years they have been active.
for (i in seq_along(temp.webpage.2)){
  tryCatch(
    {  
      h.index        <- read_html(temp.webpage.2[i]) %>% html_nodes("#Ahindex:nth-child(1) .indData") %>% html_text(.)
      i10.index      <- read_html(temp.webpage.2[i]) %>% html_nodes("#Ahindex:nth-child(2) .indData") %>% html_text(.)
      citations      <- read_html(temp.webpage.2[i])%>% html_nodes("#Ahindex~ #Ahindex+ #Ahindex .indData") %>% html_text(.)
      years.active   <- read_html(temp.webpage.2[i]) %>% html_nodes("div+ p") %>% html_text(.)
      years.active   <- str_sub(years.active[1], start = 4, end = 5)
    },
    error = function(e) print("NA")
  )
  records.2[[i]] <- data_frame(h.index = h.index, i10.index = i10.index, citations = citations, years.active = years.active)
}
  
#Bind the records into a data frame
df2 <- bind_rows(records.2)
  
#Create a CSV of the data frame
write_csv(df2, "records-2.csv")
```
Now, we will open both our records-1.csv and records-2.csv in Excel and combine the two files, thus creating one file that contains the first and last names, ID, h index, i10 index, citation count for each of the Economists, and the number of years they have been active. In Excel we will also clean the data up a bit. Some of the records were incomplete or did not exist anymore, and so R put zeros in each the h index, i10 index, and citations columns. We will delete these columns and then re-alphabatize the records by last name.

We will then also have to add all of the letters together in Excel, as each letter had to be gathered individually. Once done we have a list of all Economists data which I named 'records-final.csv'.

Next, we will gather the data for Economists on Twitter, which are listed on a seperate page on RePEc's webiste.

The first two loops are the same as the previous two, except now we also gather the username for each Twitter user.
```
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
```
Again, for this second loop you will have to go through each letter individually as the webpage for CitEc changes for each letter. In this example we start with 'a'.
```
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
      h.index        <- read_html(temp.webpage.twitter2[i]) %>% html_nodes("#Ahindex:nth-child(1) .indData") %>% html_text(.)
      i10.index      <- read_html(temp.webpage.twitter2[i]) %>% html_nodes("#Ahindex:nth-child(2) .indData") %>% html_text(.)
      citations      <- read_html(temp.webpage.twitter2[i]) %>% html_nodes("#Ahindex~ #Ahindex+ #Ahindex .indData") %>% html_text(.)
      years.active   <- read_html(temp.webpage.2[i]) %>% html_nodes("div+ p") %>% html_text(.)
      years.active   <- str_sub(years.active[1], start = 4, end = 5)
    },
    error = function(e) print("NA")
  )
  records.twitter2[[i]] <- data_frame(h.index = h.index, i10.index = i10.index, citations = citations, years.active = years.active)
}
  
#Bind the rows
df.twitter2 <- bind_rows(records.twitter2)
  
#Create the CSV file of the Twitter User's citations
write_csv(df.twitter2, "twitter-a2.csv")
```
Again, like the non-Twitter Economists we take these records into Excel to combine the columns and rows of different letters, and to deleted any incomplete records. I ended up saving the Economists of Twitters info as 'records-twitter.csv'.

Lastly, we will gather the twitter data for these users. You will read in the csv file we just created for all the Economists on Twitter and use a loop to collect the number of tweets they have, the number of followers, and the number of accounts they are following.
```
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
```
You will then open this file in Excel and add these columns to the rest of the records in 'records-twitter.csv'. After that you will also need to do a select all and find all of the '.k's and replace them with zeros. For example, if a person has 12,000 followers Twitter reported it as 12.k, and by doing a replace all in Excel you can turn 12.k into 12,000.

And you have done it! You now have CSV files for both the Economists on Twitter and those who are not!

## Analyzing the Data

Now we will look at the data was have collected to see what it can tell us.

```
#Install ggplot
library("ggplot2")

#Import the csv files we created
econ.twitter <- read.csv("Economists-Twitter.csv")
non.twitter <- read.csv("Economists-NonTwitter.csv")
all.names <- read.csv("Economists-All.csv")

#Get a quick look at the data
summary(econ.twitter)
summary(non.twitter)
summary(all.names)

#Create a lindear regression model
lmodel <- lm(log(citations) ~ log(followers) + I(years.active^2), data = econ.twitter)

#Get the Summary of the model
summary(lmodel)

#Create a lindear regression model
lmodel <- lm(log(citations) ~ log(followers) + years.active + I(years.active^2), data = econ.twitter)

#Get the Summary of the model
summary(lmodel)

#Plot the two independent variables with the dependant variable and regression
plot(log(econ.twitter$followers), log(econ.twitter$citations), pch = 16, col = "#3BB9FF", main = "Twitter: Citations vs. Followers", xlab = "log(Citations)", ylab = "log(Followers)")
abline(lm(log(econ.twitter$citations) ~ log(econ.twitter$followers)))

plot(I(econ.twitter$years.active^2), log(econ.twitter$citations), pch = 16, col = "#3BB9FF", main = "Twitter: Citations vs. Years Active", xlab = "log(Citations)", ylab = "I(Years Active^2)")
abline(lm(log(econ.twitter$citations) ~ I(econ.twitter$years.active^2)))
