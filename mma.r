options(error=traceback)

get_score <- function(fighter, scores) {
  scores[scores[, "Fighter"] == fighter, ]$Score
}

update_scores <- function(fight, scores) {
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
  # This counts no contests as draws
  else if (result == "vs." || result == "vs") {
    f_result = 0.5
    o_result = 0.5
  }
  else {
    return(scores)
  }

  f_new_score = round(f_score + 32 * (f_result - f_exp))
  o_new_score = round(o_score + 32 * (o_result - o_exp))

  scores[scores[, "Fighter"] == fighter, ]$Score <- f_new_score
  scores[scores[, "Fighter"] == opponent, ]$Score <- o_new_score

  return(scores)
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

for (i in 1:nrow(results)) {
  scores <- update_scores(results[i, ], scores)
}

ranked <- scores[order(-scores$Score), ]
top <- ranked[1:30, ]
print(top)
