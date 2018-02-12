
# coding: utf-8
# In[29]:
#!/usr/bin/python

import praw

# In[30]:


reddit = praw.Reddit(client_id='XXXXXXX',
                     client_secret='XXXXXXX',
                     user_agent='XXXXXXX',
                     username='XXXXXXX',
                     password='XXXXXXX')


# In[31]:


subreddit = reddit.subreddit('Nootropics')


# In[32]:


big_bang = subreddit.created
big_bang


# In[51]:


topics_dict = { "title":[], "score":[], "id":[], "url":[], "comms_num": [], "created": [], "body":[] }


# In[52]:


for submission in subreddit.submissions(1485796660, 1517332671):
    topics_dict["title"].append(submission.title)
    topics_dict["score"].append(submission.score)
    topics_dict["id"].append(submission.id)
    topics_dict["url"].append(submission.url)
    topics_dict["comms_num"].append(submission.num_comments)
    topics_dict["created"].append(submission.created)
    topics_dict["body"].append(submission.selftext)

len(topics_dict["title"])


# In[53]:


for submission in subreddit.submissions(1454174260, 1485796660):
    topics_dict["title"].append(submission.title)
    topics_dict["score"].append(submission.score)
    topics_dict["id"].append(submission.id)
    topics_dict["url"].append(submission.url)
    topics_dict["comms_num"].append(submission.num_comments)
    topics_dict["created"].append(submission.created)
    topics_dict["body"].append(submission.selftext)

len(topics_dict["title"])


# In[54]:


for submission in subreddit.submissions(1422638260, 1454174260):
    topics_dict["title"].append(submission.title)
    topics_dict["score"].append(submission.score)
    topics_dict["id"].append(submission.id)
    topics_dict["url"].append(submission.url)
    topics_dict["comms_num"].append(submission.num_comments)
    topics_dict["created"].append(submission.created)
    topics_dict["body"].append(submission.selftext)

len(topics_dict["title"])


# In[55]:


for submission in subreddit.submissions(1391102260, 1422638260):
    topics_dict["title"].append(submission.title)
    topics_dict["score"].append(submission.score)
    topics_dict["id"].append(submission.id)
    topics_dict["url"].append(submission.url)
    topics_dict["comms_num"].append(submission.num_comments)
    topics_dict["created"].append(submission.created)
    topics_dict["body"].append(submission.selftext)

len(topics_dict["title"])


# In[56]:


for submission in subreddit.submissions(1359566260, 1391102260):
    topics_dict["title"].append(submission.title)
    topics_dict["score"].append(submission.score)
    topics_dict["id"].append(submission.id)
    topics_dict["url"].append(submission.url)
    topics_dict["comms_num"].append(submission.num_comments)
    topics_dict["created"].append(submission.created)
    topics_dict["body"].append(submission.selftext)

len(topics_dict["title"])


# In[57]:


for submission in subreddit.submissions(1327943860, 1359566260):
    topics_dict["title"].append(submission.title)
    topics_dict["score"].append(submission.score)
    topics_dict["id"].append(submission.id)
    topics_dict["url"].append(submission.url)
    topics_dict["comms_num"].append(submission.num_comments)
    topics_dict["created"].append(submission.created)
    topics_dict["body"].append(submission.selftext)

len(topics_dict["title"])


# In[58]:


for submission in subreddit.submissions(1296407860, 1327943860):
    topics_dict["title"].append(submission.title)
    topics_dict["score"].append(submission.score)
    topics_dict["id"].append(submission.id)
    topics_dict["url"].append(submission.url)
    topics_dict["comms_num"].append(submission.num_comments)
    topics_dict["created"].append(submission.created)
    topics_dict["body"].append(submission.selftext)

len(topics_dict["title"])


# In[59]:


for submission in subreddit.submissions(1264871860, 1296407860):
    topics_dict["title"].append(submission.title)
    topics_dict["score"].append(submission.score)
    topics_dict["id"].append(submission.id)
    topics_dict["url"].append(submission.url)
    topics_dict["comms_num"].append(submission.num_comments)
    topics_dict["created"].append(submission.created)
    topics_dict["body"].append(submission.selftext)

len(topics_dict["title"])


# In[60]:


for submission in subreddit.submissions(1233335860, 1264871860):
    topics_dict["title"].append(submission.title)
    topics_dict["score"].append(submission.score)
    topics_dict["id"].append(submission.id)
    topics_dict["url"].append(submission.url)
    topics_dict["comms_num"].append(submission.num_comments)
    topics_dict["created"].append(submission.created)
    topics_dict["body"].append(submission.selftext)

len(topics_dict["title"])


# In[21]:


import pandas as pd


# In[61]:


topics_data = pd.DataFrame(topics_dict)

import datetime

def get_date(submission):
    time = submission
    return datetime.datetime.fromtimestamp(time)

timestamps = topics_data["created"].apply(get_date)

topics_data = topics_data.assign(timestamp = timestamps)


# In[67]:


topics_data.info()


# In[80]:


comms_dict = { "topic": [], "body":[], "comm_id":[], "created":[] }


# In[79]:


iteration = 1
for topic in topics_data["id"]:
    print(str(iteration))
    iteration += 1
    submission = reddit.submission(id=topic)
    for top_level_comment in submission.comments:
        comms_dict["topic"].append(topic)
        comms_dict["body"].append(top_level_comment.body)
        comms_dict["comm_id"].append(top_level_comment)
        comms_dict["created"].append(top_level_comment.created)

print("done")


# In[14]:


comms_data = pd.DataFrame(comms_dict)
comms_data

timestamps = comms_data["created"].apply(get_date)

comms_data = comms_data.assign(timestamp = timestamps)


# In[15]:


topics_data.to_csv("subreddit_Nootropics_topics.csv")
comms_data.to_csv("subreddit_Nootropics_comments.csv")

