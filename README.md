# Sentiment analysis of Reddit comments using R's tidytext package

In February 2018, Felippe Rodrigues and I published a story at Smithsonianmag.com about brain-boosting substances that are at once banned in the Olympics and popular in the tech world. To understand the size and tenor of the conversation surrounding these so-called "nootropics" - think the pill from the movie *Limitless* - we used R's ```tidytext``` package to analyze more than 150,000 Reddit comments scraped using Python.

Here's how we did it. 

First, load the following packages.

```{r}
# for data wrangling
library(tidyr)
library(stringr)
library(magrittr)
library(dplyr)
library(lubridate)

# for sentiment analysis
library(tidytext)

# for visualization
library(ggplot2)
library(ggridges)
```

## Load in the data

Next, load in the 164,000 comments we scraped from the subreddits *r/Nootropics* and *r/StackAdvice*. By using ```glimpse()``` we can take a peek at the tibble in RStudio's console. 

```{r}
All_comments <- read.csv("reddit/all_Noot_Stack_comments.csv", 
                         header=TRUE, stringsAsFactors=FALSE) 
All_comments %>% glimpse()
```

Next, we's filtered these Reddit comments by substance and then exported each as a CSV for manual exploration in Excel using ```write.csv()```. 

```{r}
# Get caffeine comments
All_caffeine_comments <- All_comments %>%
  filter(str_detect(body, "caffeine")) %>% glimpse()
write.csv((All_caffeine_comments), "reddit/substances/all_caffeine_mentions.csv")

# Get theanine comments
All_theanine_comments <- All_comments %>%
  filter(str_detect(body, "theanine")) %>% glimpse()
write.csv((All_theanine_comments), "reddit/substances/all_theanine_mentions.csv")

# Get piracetam comments
All_piracetam_comments <- All_comments %>%
  filter(str_detect(body, "piracetam")) %>% glimpse()
write.csv((All_piracetam_comments), "reddit/substances/all_piracetam_mentions.csv")

# Get noopept comments
All_noopept_comments <- All_comments %>%
  filter(str_detect(body, "noopept")) %>% glimpse()
write.csv((All_noopept_comments), "reddit/substances/all_noopept_mentions.csv")

# Get modafinil comments
All_modafinil_comments <- All_comments %>%
  filter(str_detect(body, "modafinil")) %>% glimpse()
write.csv((All_modafinil_comments), "reddit/substances/all_modafinil_mentions.csv")

# Get phenibut comments
All_phenibut_comments <- All_comments %>%
  filter(str_detect(body, "phenibut")) %>% glimpse()
write.csv((All_phenibut_comments), "reddit/substances/all_phenibut_mentions.csv")

# Get bacopa comments
All_bacopa_comments <- All_comments %>%
  filter(str_detect(body, "bacopa")) %>% glimpse()
write.csv((All_bacopa_comments), "reddit/substances/all_bacopa_mentions.csv")
```

In Excel, we surveyed each of these substances, adding a corresponding ```substance``` column to each csv. We then pasted all of these into one spreadsheet, which we named ```all_substance_mentions.csv.

This could have easily been done with the ```dplyr``` R package, too, FYI.

## Visualize substance mentions over time

First, we load in our csv with the all Reddit substance mentions

```{r}
TotalMentions <- read.csv("reddit/all_substance_mentions.csv", 
                          header=TRUE, stringsAsFactors=FALSE) 
TotalMentions %>% glimpse()
```

We need to fix the date using ```lubridate``` and then breakdown the data by month. This will make a much more presentable plot. 

```{r}
TotalMentions$date <- ymd(TotalMentions$date)
TotalMentions$Month <- as.Date(cut(TotalMentions$date,
                                   breaks = "month"))
TotalMentions %>% 
  arrange(date) %>% glimpse() 
```

Finally, we'll use the ```ggplot2``` visualization package to plot mentions of each substance over time. Note: ```facet_grid``` breaks the plot out into small plots for each substance. 

```{r}
ggplot(TotalMentions, aes(Month)) + geom_histogram(aes(fill=factor(substance)), stat = "count") +
  facet_grid(~substance)
```

We also wondered if we could stack these substance mentions over time using what some call the "Joy Division" plot. It comes with the ```ggridges``` package. 

```{r}
ggplot(TotalMentions, aes(x = Month, y = substance)) + geom_density_ridges()
```

We also tried visualizing using some other plots. 

```{r}
ggplot(TotalMentions, aes(Month, color=substance)) + geom_histogram(aes(binwidth=0.01), stat = "bin") +
  facet_grid(~substance)
```

```{r}
ggplot(TotalMentions, aes(Month)) + geom_histogram(aes(fill=factor(substance)), binwidth="40", stat = "count") + facet_grid(~substance)
```

```{r}
ggplot(TotalMentions, aes(TotalMentions$Month, color=substance)) + geom_freqpoly(aes(binwidth=0.01), stat="bin") 
```

```{r}
ggplot(TotalMentions, aes(time)) + geom_histogram(aes(fill=factor(substance)), stat = "count")
```


# Sentiment analysis

We employed sentiment analysis using the "tidytext" R package on our CSV file of mentions of all seven substances.

First, load the AFINN sentiment analysis library that comes with "tidytext"

```{r}
AFINN <- sentiments %>%
  filter(lexicon == "AFINN") %>%
  select(word, afinn_score = score)
```

## Tokenize comments and merge with words ranked by sentiment

Next, tokenize comments into one-word rows and cut out stop words. Then join AFINN-scored words with words in comments, if present. Next, return a 114,000-row tibble with X1, substance, word and sentiment score. (Uncomment the ```write.csv()``` line to create a CSV of this tibble.)

```{r}
TotalMentionsComments <- TotalMentions

all_sentiment <- TotalMentionsComments %>%
  select(body, X1, time, substance, date) %>%
  unnest_tokens(word, body) %>%
  anti_join(stop_words) %>%
  inner_join(AFINN, by = "word") %>%
  group_by(X1, substance, word) %>%
  summarize(sentiment = mean(afinn_score))

all_sentiment

# write.csv((all_sentiment), "reddit/all_sentiment.csv")
```

## Visualize sentiment analysis 

Let's see what we've got. Using ```ggplot2``` we will plot words by sentiment and frequency, with dot size representing the frequency of words. Add a ```geom_hline``` to show the average sentiment. 

```{r}
ggplot(all_sentiment, aes(x=substance, y = all_sentiment$sentiment)) +
  geom_point() +
  geom_count() +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1, hjust = 1) + geom_hline(yintercept = mean(all_sentiment$sentiment), color = "red", lty = 2)
```

To eventually plot sentiment vs. word frequency, we will need to count word occurences and then merge these two dataframes. 

```{r}
all_sentiment_wordcount <- all_sentiment %>%
  select(X1, substance, word, sentiment) %>%
  group_by(word) %>%
  tally()

Bind_sent_and_word <- all_sentiment %>%
  full_join(all_sentiment_wordcount, by="word")
```

Ok, now we're ready to plot sentiment of all substances vs. word frequency, using ```facet_wrap``` to split up the charts by substance.

```{r}
ggplot(Bind_sent_and_word, aes(y=n, x=sentiment, color=substance)) +
  geom_point() +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1, hjust = 1) +
  geom_hline(yintercept = mean(Bind_sent_and_word$sentiment), color = "red", lty = 2) +
  facet_wrap(~substance)
```

Since our Smithsonian story is only about modafinil, piracetam and noopept, let's filter by those three substances.

```{r}
Filtered_sent_vs_word <- Bind_sent_and_word %>%
  filter(substance == "modafinil" | substance == "piracetam" | substance == "noopept") %>% glimpse()
```

## Visualize our publication-ready chart

The graph we included in the story plots word frequency vs. sentiment and colors the points by substance and labels them by word. 

```{r}
ggplot(Filtered_sent_vs_word, aes(y=n, x=sentiment, color=substance)) +
  geom_point() +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1.1, hjust = 1.1) 
```

We exported an SVG, brought it into Adobe Illustrator and designed it up. 

That's it! 


