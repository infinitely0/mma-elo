options(error=traceback)

get_score <- function(fighter, scores) {
  scores[fighter, ]$Score
}

update_scores <- function(fight, scores, k=32) {
  fighter <- as.character(fight$Fighter)
  opponent <- as.character(fight$Opponent)
  result <- as.character(fight$Result)

  f_score <- get_score(fighter, scores)
  o_score <- get_score(opponent, scores)

  # Transformed rating for Elo algorithm
  f_rating <- 10 ^ (f_score / 400)
  o_rating <- 10 ^ (o_score / 400)

  # Expected score
  f_exp = f_rating / (f_rating + o_rating)
  o_exp = o_rating / (f_rating + o_rating)

  if (result == "def." || result == "def") {
    f_result = 1
    o_result = 0
  }
  # "Fighter" never loses to "Opponent"
  # else if (result == "loss") {
  #  f_result = 0
  #  o_result = 1
  #}
  else if (result == "vs." || result == "vs") {
    if (result == "No Contest" || result == "No contest") {
      return(scores)
    } else {
      f_result = 0.5
      o_result = 0.5
    }
  }
  else {
    return(scores)
  }

  f_new_score = round(f_score + k * (f_result - f_exp))
  o_new_score = round(o_score + k * (o_result - o_exp))

  scores[scores[, "Fighter"] == fighter, ]$Score <- f_new_score
  scores[scores[, "Fighter"] == opponent, ]$Score <- o_new_score

  return(scores)
}

save_rankings <- function(rankings, filename) {
  sink(filename)
  print(data.frame(Rank=1:nrow(rankings), rankings), row.names=FALSE)
  closeAllConnections()
  print(paste(c("Full list saved in", filename), collapse=" "))
}

parse_date <- function(date_string) {
  date_formats <- c("%B %d, %Y", "%B %d %Y", "%d %B, %Y", "%d %B %Y")

  for (date_format in date_formats) {
    date_obj <- as.Date(date_string, format=date_format)
    if (!is.na(date_obj)) {
      break
    }
  }
  return(date_obj)
}

scraped_results <- read.csv2("results.csv")
extra_results <- read.csv2("results_extra.csv")

results <- rbind(scraped_results, extra_results)
results$Date <- sapply(results$Date, parse_date)
results <- results[order(results$Date, results$Fight.Number), ]

all_names <- c(as.character(results$Fighter), as.character(results$Opponent))
fighters <- unique(all_names)

scores <- data.frame(fighters, 1000)
names(scores) <- c("Fighter", "Score")
rownames(scores) <- scores$Fighter

for (i in 1:nrow(results)) {
  scores <- update_scores(results[i, ], scores)
}

ranked <- scores[order(-scores$Score), ]

top <- ranked[1:30, ]
print("Top 30:")
print(top, row.names=FALSE)

# Uncomment to save full list to file
# save_rankings(ranked, "rankings.txt")
