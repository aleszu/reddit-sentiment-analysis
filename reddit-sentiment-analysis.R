library(tidytext)
library(tidyr)
library(stringr)
library(ggplot2)
library(magrittr)
library(dplyr)
library(lubridate)
library(ggridges)

# Load csv of Reddit comments into dataframe

All_comments <- read.csv("reddit/all_Noot_Stack_comments.csv", 
                         header=TRUE, stringsAsFactors=FALSE) 
All_comments %>% glimpse()

# OK, we have more than 164,000 comments from r/Nootropics and r/StackAdvice
# Let's filter these comments by substance and then export each as a CSV for exploration

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

# In Excel, we surveyed each of these substances, adding a corresponding "substance" column to each
# We then pasted all of these into one spreadsheet, "all_substance_mentions.csv" 
# This could have easily been done with the "dplyr" R package, too



# Visualizing substance mentions over time

# Preparing plot of all substance mentions over time

TotalMentions <- read.csv("reddit/all_substance_mentions.csv", 
                          header=TRUE, stringsAsFactors=FALSE) 
TotalMentions %>% glimpse()

# Fix the date and break the data by month

TotalMentions$date <- ymd(TotalMentions$date)

TotalMentions$Month <- as.Date(cut(TotalMentions$date,
                                   breaks = "month"))

TotalMentions %>% 
  arrange(date) %>% glimpse() 

# Visualize mentions of each substance across time

ggplot(TotalMentions, aes(Month)) + geom_histogram(aes(fill=factor(substance)), stat = "count") +
  facet_grid(~substance)

# Look at all substance mentions over time using the Joy Division plot

ggplot(TotalMentions, aes(x = Month, y = substance)) + geom_density_ridges()

# Visualize all using small multiples 

ggplot(TotalMentions, aes(Month, color=substance)) + geom_histogram(aes(binwidth=0.01), stat = "bin") +
  facet_grid(~substance)

# We also tried a few other visualizations

ggplot(TotalMentions, aes(Month)) + geom_histogram(aes(fill=factor(substance)), binwidth="40", stat = "count") +
  facet_grid(~substance)

ggplot(TotalMentions, aes(TotalMentions$Month, color=substance)) + geom_freqpoly(aes(binwidth=0.01), stat="bin") 

ggplot(TotalMentions, aes(time)) + geom_histogram(aes(fill=factor(substance)), stat = "count")


# Sentiment analysis

# We employed sentiment analysis using the "tidytext" R package
# and our CSV file of mentions of 7 substances

# First, load the AFINN sentiment analysis library that comes with "tidytext" 

AFINN <- sentiments %>%
  filter(lexicon == "AFINN") %>%
  select(word, afinn_score = score)

TotalMentionsComments <- TotalMentions

# Tokenize comments into one-word rows and cut out stop words 
# Then join AFINN-scored words with words in comments, if present
# Return 114,000-row tibble with X1, substance, word and sentiment score

all_sentiment <- TotalMentionsComments %>%
  select(body, X1, time, substance, date) %>%
  unnest_tokens(word, body) %>%
  anti_join(stop_words) %>%
  inner_join(AFINN, by = "word") %>%
  group_by(X1, substance, word) %>%
  summarize(sentiment = mean(afinn_score))

all_sentiment

# all_avg_sent <- all_sentiment %>%
#   summarize(avg = mean(sentiment)) 
# 
# all_avg_sent
# 
# write_csv((all_avg_sent), "reddit/all_avg_sent.csv")


# Visualize sentiment analysis 

# Plot words by sentiment and frequency; dot size is count of word

ggplot(all_sentiment, aes(x=substance, y = all_sentiment$sentiment)) +
  geom_point() +
  geom_count() +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1, hjust = 1) +
  geom_hline(yintercept = mean(all_sentiment$sentiment), color = "red", lty = 2)

# Count word occurences, bind two dataframes

all_sentiment_wordcount <- all_sentiment %>%
  select(X1, substance, word, sentiment) %>%
  group_by(word) %>%
  tally()

Bind_sent_and_word <- all_sentiment %>%
  full_join(all_sentiment_wordcount, by="word")

# Plot all substances sentiment vs. word frequency, colored by substance and facetwrapped

ggplot(Bind_sent_and_word, aes(y=n, x=sentiment, color=substance)) +
  geom_point() +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1, hjust = 1) +
  geom_hline(yintercept = mean(Bind_sent_and_word$sentiment), color = "red", lty = 2) +
  facet_wrap(~substance)

# Filter just our 3 substances

Filtered_sent_vs_word <- Bind_sent_and_word %>%
  filter(substance == "modafinil" | substance == "piracetam" | substance == "noopept") %>% glimpse()

# Plot word freq vs. sentiment, colored by substance

ggplot(Filtered_sent_vs_word, aes(y=n, x=sentiment, color=substance)) +
  geom_point() +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1.1, hjust = 1.1) 

# Adding this would add average sentiment line: + geom_hline(yintercept = mean(Filtered_sent_vs_word$sentiment), color = "red", lty = 2) 

# END






