# mma-elo

This is a qnd rankings generator for MMA fighters. It works by scraping
Wikipedia for all UFC fights, then using the Elo rating system to give each
fighter a score.

Here is the top 30 table (as of 1 October 2019):

                 Fighter Score
        Georges St-Pierre  1244
                Jon Jones  1234
            Tony Ferguson  1210
      Khabib Nurmagomedov  1191
             Max Holloway  1182
           Dustin Poirier  1162
             Kamaru Usman  1156
             Amanda Nunes  1153
       Demetrious Johnson  1147
             Stipe Miocic  1147
         Joseph Benavidez  1146
               Ryan Bader  1143
           Daniel Cormier  1142
            Frankie Edgar  1141
         Charles Oliveira  1139
         Robert Whittaker  1138
           Gegard Mousasi  1135
          Colby Covington  1133
              Demian Maia  1128
            Chris Weidman  1128
             Leon Edwards  1128
             Royce Gracie  1127
                Jon Fitch  1127
        Junior dos Santos  1127
         Rafael dos Anjos  1126
     Santiago Ponzinibbio  1126
           Cain Velasquez  1124
           Conor McGregor  1124
             Henry Cejudo  1124
           Donald Cerrone  1121

The full list is in `rankings.txt`.

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

If you would like to update the rankings to include more recent event, here's
some instructions on how to use this. Warning: this is pretty hacky.

- Use `scrape.py` to gather all the fights from UFC events, which are saved in
  `results.csv`.
- The console output will tell you if the scraper couldn't find the results for
  an event. You will have to add these manually to `results_extra.csv` (make
  sure the format is the same -- I've already added all the early events that
  were missed, just append anything else to these).
- Run `mma.r` to generate the top 30 table. Uncommon the last line to update
  the full rankings, which are saved to the `rankings.txt` file.
