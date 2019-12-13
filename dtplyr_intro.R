##############################
## dtplyr introduction
##
## Matt Brachmann (PhDMattyB)
##
## 2019-12-12
##
##############################

setwd('~/PhD/R users group/')

library(devtools)
library(data.table)
library(tidyverse)
library(dtplyr)
library(stringi)
library(microbenchmark)

theme_set(theme_bw())

# Other packages to load
#devtools::install_github('tidyverse/dtplyr')

## tutorial taken and modified from:
## https://towardsdatascience.com/introduction-to-dtplyr-783d89e9ae56


# Generate data -----------------------------------------------------------
n <- 10000000

data_dt <- data.table(id=stri_rand_strings(n, 
                                           3, 
                                           pattern = "[A-Z]"),
                      product=stri_rand_strings(n, 
                                                3, 
                                                pattern = "[A-Z]"),
                      date=sample(seq(as.Date('2010/12/13'), 
                                      as.Date('2019/12/13'), 
                                      by="day"), 
                                  n, 
                                  replace=TRUE),
                      amount=sample(1:10000,
                                    n,
                                    replace=TRUE),
                      price=rnorm(n, 
                                  mean = 100, 
                                  sd = 20))

# Manipulate the data -----------------------------------------------------

result_df = as.tibble(data_dt) %>% 
  dplyr::filter(date > as.Date('2019/01/01')) %>% 
  dplyr::arrange(amount) %>% 
  dplyr::mutate(value = amount * price)

result_dt = data_dt[date > as.Date('2019/01/01')][order(date)][,value := amount * price]

result_dtplyr = lazy_dt(data_dt) %>% 
  filter(date > as.Date('2019/01/01')) %>% 
  arrange(amount) %>% 
  mutate(value = amount * price) %>% 
  as.tibble()


# Time it! ----------------------------------------------------------------

## use system.time to time things individually
system.time(as.tibble(data_dt) %>% 
              dplyr::filter(date > as.Date('2019/01/01')) %>% 
              arrange(amount) %>% 
              mutate(value = amount * price))

system.time(data_dt[date > as.Date('2019/01/01')][order(date)][,value := amount * price])

system.time(lazy_dt(data_dt) %>% 
              filter(date > as.Date('2019/01/01')) %>% 
              arrange(amount) %>% 
              mutate(value = amount * price) %>% 
              as.tibble())
## use microbenchmark to time everything at once
speed_test = microbenchmark(dplyr = as.tibble(data_dt) %>% 
                              dplyr::filter(date > as.Date('2019/01/01')) %>% 
                              arrange(amount) %>% 
                              mutate(value = amount * price),
                            data.table = data_dt[date > as.Date('2019/01/01')][order(date)][,value := amount * price],
                            dtplyr = lazy_dt(data_dt) %>% 
                              filter(date > as.Date('2019/01/01')) %>% 
                              arrange(amount) %>% 
                              mutate(value = amount * price) %>% 
                              as.tibble())
## look at the summary
speed_test

## plot the results using the autoplot function in ggplot 
## doesn't need to be nice, just need the results
autoplot(speed_test)
