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
```
