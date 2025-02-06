# README

This repository holds code and explains deeper the methodology used in the GDI report: "Actresses Ages 50 Years and Older Are Still Recognized by the Academy Awards Less Than Their Male Counterparts."  

## Creating the Data

First, we scraped Wikipedia tables for the names of nominees and winners, the movies for which they were nominated, and the year in which that movie was released. That code can be found in the `names/` directory. There is no guarantee that the code will reproduce exactly in the future: If the underlying table structure of the page changes from what they were in January 2025, the code will have to be updated. (We also pulled Emmy data at the same time, which we plan to discuss in the future.)  

Second, we passed this data along to Perplexity AI, which was running on the foundational model [llama-3.1-sonar-large-128k-online](https://medium.com/@bobcristello/llama-3-1-sonar-huge-transforming-digital-architecture-with-cutting-edge-ai-3026f98bfa63) at the time. (The precise prompt template can be found at `ages/dob.py`.) There were 2,071 unique individuals (remembering again that we included Emmy data here, as well). The first two authors of the report hand-checked 7.5% (156) cases for a total of 15% of the data. The birth date error rate 98%, with seven misses in the hand-checked data totak. Two were wrong dates but the correct year, which would be the correct coding for how we calculated age. One was off by a year, two were off by two years, and two were off by three years. However, two of these seven were contested: Different sources reported different birth dates. We considered Wikipedia to be ground truth, so these two were incorrect because they differed from Wikipedia. Taken together, we feel confident in the accuracy of compiled years of birth for the actors in the data.  

Actors who were nominated more than once had their birth date searched as many times as they were nominated. This led to 31 actors with multiple dates of birth returned. Each of these 31 were hand-checked and coded with their correct date of birth. Three further birth dates failed to parse. Two were looked up manually, and a third could not be found online and was not included in the data set (this was an actor nominated for an Emmy, so not relevant to the current report).  

As is mentioned in the report, the age was calculated as the year of the movie's release minus the year of birth for the actor. Scripts relevant to calculating and cleaning age data are found in the `ages/` directory.  

Note that specific Google Sheet IDs and other information have been suppressed and replaced with `<...>`.  
