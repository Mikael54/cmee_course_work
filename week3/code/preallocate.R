NoPreallocFun <- function(x) {
    a <- vector() # empty vector
    for (i in 1:x) {
        a <- c(a, i) # concatenate
        # print(a)
        # print(object.size(a))
    }
}

PreallocFun <- function(x) {
    a <- rep(NA, x) # pre-allocated vector
    for (i in 1:x) {
        a[i] <- i # assign
        # print(a)
        # print(object.size(a))
    }
}

print(system.time(NoPreallocFun(10000)))
print(system.time(PreallocFun(10000)))