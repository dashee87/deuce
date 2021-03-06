#' Metadata on Charted Matches
#'
#' This dataset contains basic details about the professional tennis matches included in the Match Charting Project. The variables of the dataset are:
#'
#' \itemize{
#'   \item match_id. A character id that uniquely identifies each match
#'   \item Player.1. A character with the full name of the player who served first
#'   \item Player.2. A character with the full name of the player who served second
#'   \item Pl.1.hand. A character indicating the handedness of Player 1
#'   \item Pl.2.hand. A character indicating the handedness of Player 2
#' 	  \item Gender. A character indicating the gender of the match (M = male, F = Female)
#'   \item Date. A numeric date of the tournament start, YYYYYMMDD
#'   \item Tournament. A character name of the tournament
#'   \item Round. A character indicating the round of the match (F, Q2, Q3, QF, R128, R16, R32, R64, RR, SF)
#'   \item Time. A character of the time at which the match began?
#'   \item Court. A character of the court on which the match took place 
#'   \item Surface. A character indicating the major surface used for the match
#'   \item Umpire. A character with the full name of the umpire officiating the match
#'   \item Best.of. A numeric indicating best of 5 (5) or a best of 3 (3) match
#'   \item Final.TB. A numeric indicator whether the match uses a final set tiebreak
#'   \item Charted.by. A character handle for the person who charted the match
#'}
#'
#' @format A data frame with 1,001 rows and 17 variables
#' @source \url{https://github.com/JeffSackmann/tennis_MatchChartingProject}
#' @name charting_matches
NULL