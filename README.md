#Final Project - Economists of Twitter

This is my final project for ECON 5970 - Data Science for Economists. In this project I scraped data from the RePEc website on all
the Economists they had in their system, as well as data on all the Economists that had registered their Twitter accounts with RePEc.
I then look at the profiles of each of these categories of Economist - ones that are on Twitter and ones that aren't. In this README 
document I will go over how to replicate my results.

##Collecting the Data

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
