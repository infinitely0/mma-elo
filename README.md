# MMA Elo Rankings

This is a quick-and-dirty rankings generator for MMA fighters. It works by
scraping Wikipedia for all UFC fights, then using the Elo rating system to give
each fighter a score.

## Current top 30

Here is the top 30 table as of 2 June 2020:

| Rank | Fighter               | Score |
|------|-----------------------|-------|
| 1    | Georges St-Pierre     | 1244  |
| 2    | Jon Jones             | 1244  |
| 3    | Khabib Nurmagomedov   | 1191  |
| 4    | Tony Ferguson         | 1188  |
| 5    | Kamaru Usman          | 1171  |
| 6    | Amanda Nunes          | 1165  |
| 7    | Charles Oliveira      | 1163  |
| 8    | Max Holloway          | 1163  |
| 9    | Dustin Poirier        | 1162  |
| 10   | Israel Adesanya       | 1152  |
| 11   | Demetrious Johnson    | 1147  |
| 12   | Stipe Miocic          | 1147  |
| 13   | Glover Teixeira       | 1145  |
| 14   | Ryan Bader            | 1143  |
| 15   | Daniel Cormier        | 1142  |
| 16   | Conor McGregor        | 1140  |
| 17   | Henry Cejudo          | 1138  |
| 18   | Gegard Mousasi        | 1135  |
| 19   | Gilbert Burns         | 1133  |
| 20   | Alexander Volkanovski | 1133  |
| 21   | Francis Ngannou       | 1131  |
| 22   | Leon Edwards          | 1128  |
| 23   | Royce Gracie          | 1127  |
| 24   | Jon Fitch             | 1127  |
| 25   | Joseph Benavidez      | 1127  |
| 26   | Santiago Ponzinibbio  | 1126  |
| 27   | Francisco Trinaldo    | 1125  |
| 28   | Derrick Lewis         | 1125  |
| 29   | Cain Velasquez        | 1124  |
| 30   | Frankie Edgar         | 1121  |

The full list is in `rankings.txt`.

## Limitations

If some names look out of place, it's probably because of one of the following
issues:

 - The Elo rating system doesn't yield accurate scores until players have
   played enough games to overcome the initial volatility of their scores. Some
   fighters in the UFC have competed fewer than 10 times which is quite low for
   the system. Playing around with the k-factor (currently set to 32) might
   gently improve the accuracy of the scores, but there's no way of solving the
   small sample size problem.
 - If you're wondering why Anderson Silva and Chuck Liddell (and many other
   fighters that are regarded as some of the greatest in history) aren't even
   in the top 50, consider that the losses at the end of their careers are
   going to affect their rankings no matter which algorithm is used. The scores
   are calculated using all results; this will affect fighters with early or
   late career losses.
 - This repository is called mma-elo, but it's really just ufc-elo, hence no
   Fedor on the list, and Cro Cop so far down the list. I was going to scrape
   PRIDE, Bellator, and Strikeforce events but these Wikipedia pages are even
   more messy than the pages for UFC events, which were not all formatted in a
   clear, uniform manner (Wikipedia doesn't like individual articles for non
   PPV events).
 - Obviously, the algorithm doesn't take into account circumstances. Another
   reason why Anderson Silva, who makes top 5 in any subjective rankings, is
   nowhere to be seen on this list is the following. Silva took the fight
   against Daniel Cormier on 48 hours' notice, in a weight class above his own,
   with no training camp. This wouldn't count as a loss to anyone following the
   sport.
 - It's possible that a fighter will appear as two distinct fighters if their
   name is spelled in two different ways. The data have not been checked for
   these kinds of errors.

## Instructions

If you would like to update the rankings to include more recent event, here's
some instructions on how to use this. Warning: this is pretty hacky.

1. Scrape

Use `scrape.py` to gather all the fights from UFC events. If you're updating
the current list, you don't need to scrape all of the previous events - just
skip the ones I've already scraped and go from there to the most recent event.
In the python file, if you print the list of event links (this is `links =
find_event_links()`) you can inspect the list of events being scraped, and just
cut this list to the most recent x events (`links = links[0:x]`).

The results are saved in `results.csv`, overwriting the previous ones. If
you're only updating the list, you need to append whatever new results are
stored in this file to the results that were previously there. Make sure sure
you insert new data in the right place.

2. Add missing results

The results saved in `results.csv`, may be incomplete. The console output will
tell you if the scraper couldn't find the results for an event. This might be
because the even was cancelled or the Wikipedia page is badly formatted. You
will have to add these manually to `results_extra.csv`, just make sure the
format is the same. I've already added all the early events that were missed,
just append anything else to these.

3. Run analysis

Use `mma.r` to generate the top 30 table. Run with `Rscript mma.r` (requires R
-- I probably shouldn't have used two languages for a small project like this,
but it was easier for me to work with data in R than python, and I'm used to
using python's BeautifulSoup for scraping).

To update the full rankings, which are saved to the `rankings.txt` file,
uncomment the last line in `mma.r`.
