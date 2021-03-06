#' Create Point-by-point Data
#'
#' Creates an expanded point-level version from the flat representation in \code{point_by_point}
#'
#' @param obj a row of the \code{point_by_point} data frame
#'
#' @export
pbp <- function(obj){
	
set_score <- function(x){
	games <- strsplit(x, split = ";")[[1]]
	ngames <- sapply(games, nchar)
	output <- do.call("rbind", lapply(games, game_score))
	output$Game <- rep(1:length(games), ngames)
output
}

game_score <- function(x){
	
	points <- strsplit(x, split = "")[[1]]
	ace <- grepl("A", points)
	df <- grepl("D", points)
	points <- sub("D", "R", sub("A", "S",  points))
	x <- points == "S"
	
	data.frame(
     	serve_won = x > 1 - x,
		serve_points = cumsum(x),
		return_points = cumsum(1-x),
		serve_score = as.character(point_score(x)),
		return_score = as.character(point_score(1 - x)),
		ace = ace,
		df = df,
		stringsAsFactors = FALSE
	)
}

point_score <- function(x){
	
	s1 <- cumsum(x)
	s2 <- cumsum(1 - x)
	
	score <- ifelse(s1 == 0, "0",
		ifelse(s1 == 1, "15",
		  ifelse(s1 == 2, "30",
		     ifelse(s1 == 3, "40", 
		        ifelse(s1 > 3 & s1 > s2, "Ad", "40")))))

	if(s1[length(s1)] > s2[length(s2)])		        
		score[length(score)] <- "GM"

score
}

tiebreak <- function(x){
	
	points <- strsplit(x, split = "/")[[1]]
	points <- unlist(sapply(points, function(x) strsplit(x, split = "")[[1]]))
	
	ace <- grepl("A", points)
	df <- grepl("D", points)
	points <- sub("D", "R", sub("A", "S",  points))
	
	x <- points == "S"
	s1 <- cumsum(x)
	s2 <- cumsum(1 - x)
	
	player1 <- c(TRUE, rep(c(FALSE, FALSE, TRUE, TRUE), length = length(points)-1))
	player1_points <- x # Points won on serve
	player1_points[!player1] <- (1-x)[!player1] # Not serving

	player2_points <- (1-x)
	player2_points[!player1] <- x[!player1] # Serving

	player1_points <- cumsum(player1_points)
	player2_points <- cumsum(player2_points)
	

	output <- data.frame(
     	serve_won = x > 1 - x,
		serve_points = player1_points,
		return_points = player2_points,
		ace = ace,
		df = df,
		stringsAsFactors = FALSE
	)
		
	output$serve_points[!player1] <- player2_points[!player1]
	output$return_points[!player1] <- player1_points[!player1]
	
	output$serve_score <- as.character(output$serve_points)	
	output$return_score <- as.character(output$return_points)	
	
	if(output$serve_points[nrow(output)] > output$return_points[nrow(output)] )		        
		output$serve_score[nrow(output)] <- "GM"
	else
		output$return_score[nrow(output)] <- "GM"
		
output
}

	
	s1 <- obj$server1
	s2 <- obj$server2
	date <- obj$tny_date
	
	tb_obj <- obj[,c("TB1","TB2","TB3","TB4","TB5")]
	tb_index <- sapply(tb_obj, is.na)
	
	obj <- obj[,c("Set1","Set2","Set3","Set4","Set5")]
	obj <- obj[,!sapply(obj, is.na)]
	
	if(all(tb_index)){
			
		obj <- obj[,!sapply(obj, is.na)]
		
		result <- lapply(obj, set_score)
		max_game <- sapply(result, function(x) max(x$Game))
		max_game <- c(0, max_game)
		
		for(i in 1:length(result)){
			result[[i]]$Set <- i
			result[[i]]$CumGame <- sum(max_game[1:i]) + result[[i]]$Game
		}
		
		result <- do.call("rbind", lapply(result, function(x) x))
		result$serve <- ifelse(result$CumGame %% 2 != 0, s1, s2)
		result$return <- ifelse(result$CumGame %% 2 != 0, s2, s1)
		result$tiebreak <- FALSE
	}
	else{
		
		tb_obj <- tb_obj[,!tb_index, drop = FALSE]	
		obj <- obj[,!sapply(obj, is.na)]
		
		result <- lapply(obj, set_score)
		max_game <- sapply(result, function(x) max(x$Game))
		max_game <- c(0, max_game)
		
		for(i in 1:length(tb_index))
			if(!tb_index[i]) max_game[(i+1)] <- max_game[(i+1)] + 1
		
		tiebreaks <- lapply(tb_obj, tiebreak)
		tb_sets <- which(!tb_index)
		
		for(i in 1:length(tiebreaks)){
			
			serve_index <- c(TRUE, 
				rep(c(FALSE, FALSE,TRUE, TRUE), length = nrow(tiebreaks[[i]])-1))		
			
			tiebreaks[[i]]$Game <- 13
			tiebreaks[[i]]$Set <- tb_sets[i]
			tiebreaks[[i]]$CumGame <- sum(max_game[1:(i+1)])
				
			if(sum(max_game[1:(tb_sets[i]+1)]) %% 2 != 0){
				tiebreaks[[i]]$serve <- s2
				tiebreaks[[i]]$return <- s1
				tiebreaks[[i]]$serve[serve_index] <- s1 # even game + tb goes to first server
				tiebreaks[[i]]$return[serve_index] <- s2
				}
			else{
				tiebreaks[[i]]$serve <- s1
				tiebreaks[[i]]$serve[serve_index] <- s2
				tiebreaks[[i]]$return <- s2
				tiebreaks[[i]]$return[serve_index] <- s1
			}
			tiebreaks[[i]]$tiebreak <- TRUE
		}
		
		for(i in 1:length(result)){
			result[[i]]$Set <- i
			result[[i]]$CumGame <- sum(max_game[1:i]) + result[[i]]$Game
			result[[i]]$serve <- ifelse(result[[i]]$CumGame %% 2 != 0, s1, s2)
			result[[i]]$return<- ifelse(result[[i]]$CumGame %% 2 != 0, s2, s1)
			result[[i]]$tiebreak <- FALSE
			if(any(tb_sets == i))
				result[[i]] <- rbind(result[[i]], tiebreaks[[which(tb_sets == i)]])
		}
		
		result <- do.call("rbind", lapply(result, function(x) x))
	}
	
	result$tourney_start_date <- date
	result$breakpoint <- (result$return_score == "40" & !(result$serve_score %in% c("40","Ad"))) | result$return_score == "Ad"
	
result
}