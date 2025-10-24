rm(list=ls())

ats <- load("../data/key_west_annual_mean_temperature.RData")


permutation <- function(df, number_of_permutation){
    cof_result <- vector(, number_of_permutation)
    for(i in 1:number_of_permutation) {
        cof_result[i]<- cor(df$Year, sample(df$Temp, nrow(df), replace = FALSE))
    }
    return(cof_result)
 }

calc_p_value <- function(sequential_cof, permutation_cof) {
    greater_than <- 0
    less_than <- 0
    for(i in 1:length(permutation_cof)) {
        if (permutation_cof[i] > sequential_cof) {
            greater_than <- greater_than + 1 
        } else { 
            less_than <- less_than + 1
        }
    }
    return(greater_than/less_than) 
}

sequential_cof <-cor(ats$Year, ats$Temp)

permutation_cof <- permutation(ats, 100000)

calc_p_value(sequential_cof, permutation_cof)
