
#plot.fsh.size.summaries(filename="Q:/skj/2014/assessment/Model_runs/R4D/length.fit",
#                                   xlabel="Length (cm)",remove.fsh="TRUE",
#                                   fsh.labels=paste(letters[1:23],"1",sep=""), Ncols=4,
#                                   plotname="F:/Seagate Backup/Documents/Administration/SPC_Admin/InsuranceClaims/June2014/SizeFit.png", plot.wdth=12, plot.hgt=10, line.wdth=1.2)

#plot.fsh.size.summaries(filename="Q:/bet/2014/assessment/Model_runs/2014s/Run18/weight.fit",
#                                   xlabel="Weight (kg)",remove.fsh="TRUE",
#                                   fsh.labels=c(letters,paste(letters[1:7],"1",sep="")), Ncols=4,
#                                   plotname="SizeFit.png", plot.wdth=12, plot.hgt=10, line.wdth=1.2)

plot.fsh.size.summaries = function(filename,xlabel,remove.fsh,fsh.labels,Ncols,plotname,plot.wdth,plot.hgt,line.wdth)
{
#    windows(dlfhsakfhhd)
    require(ggplot2)
    require(reshape2)
    
    Nfsh <- scan(filename, nlines=1, skip=2) - 1   # Determine the number of fisheries from file header
    Nskips <- scan(filename, nlines=1, skip=4)   # Determine the number of lines in the matrix for each fishery, from file header
    size.pars <- scan(filename, nlines=1, skip=1)  # Extract the parameters that determine the size bins - no. bins, first bin size, bin width
    sizebins <- seq(from=size.pars[2], by=size.pars[3], length.out=size.pars[1])   # Construct the size bins from the file header
    
    VecFsh <- 1:(Nfsh)   # Vector of fisheries numbers - just numeric for now
    LineKeep <- (VecFsh-1) * (Nskips + 6) + 1   # Identify the lines of the observed size frequencies for the fisheries
    VecFsh <- paste(VecFsh, fsh.labels, sep="  -  ")   # Add the text labels to the vector of fisheries names - these are printed in the figure
    
    dat <- readLines(filename)   # Read in the file as text - run time could be reduced by only reading in from '# fishery totals' down but no skiplines argument in readLines - will have a hunt
    dat <- dat[(grep("totals",dat)+4):length(dat)]   # Remove all unwanted data above the fishery totals

    dat.obs <- dat[LineKeep]   # This is the only observed data we want keep - pulls out vector for the fishery then skips down to the next fishery and grabs vector, etc. etc.
    dat.obs <- as.data.frame(t(read.table(text=dat.obs, nrows=length(LineKeep))))   # Get it in the right format and transpose
    names(dat.obs) <- VecFsh   # Match the fishery names to the columns
    
    keep.fsh = c(na.omit(ifelse(apply(dat.obs,2,sum) > 0, names(dat.obs), NA)), "sizebin", "set")   # Used to identify which fisheries have data - if all zeros then removed later on if remove.fsh == "TRUE"
    
    dat.obs$sizebin <- sizebins   # Add sizebins - becomes the x axis later on
    dat.obs$set <- "Observed"   # Neet to identify this data as observed


# Same process as above done for predicted sizes - could have done them simultaneously but harder to get them in the right format for plotting
    dat.pred <- dat[LineKeep+1]
    dat.pred <- as.data.frame(t(read.table(text=dat.pred, nrows=length(LineKeep))))
    names(dat.pred) <- VecFsh
    dat.pred$sizebin <- sizebins
    dat.pred$set <- "Predicted"

# Combine observed and predicted datasets
    dat.full <- rbind(dat.obs, dat.pred)

    if(remove.fsh == "TRUE")    dat.full <- dat.full[,match(keep.fsh,names(dat.full))]   # If true only fisheries with data will be plotted, if false then will be plotted as zeros

    plot.dat <- melt(dat.full, id=c("set","sizebin")); names(plot.dat)[3:4] <- c("Fishery","freq")   # Format data into the shape required for ggplot

# Produce and print plot
    p <- ggplot(plot.dat[plot.dat$set == "Observed",], aes(x=sizebin, y=freq)) + geom_bar(stat="identity", colour="black", fill="black")
        p <- p + facet_wrap(~ Fishery, ncol=Ncols, scales="free_y")
        p <- p + xlab(xlabel) + ylab("Samples")
        p <- p + geom_line(data=plot.dat[plot.dat$set == "Predicted",], aes(x=sizebin, y=freq), colour='red', size=line.wdth)
    print(p)
    
    ggsave(p, file=plotname, width=plot.wdth, height=plot.hgt)
}










get.obs.pred.length <- function(fitfile,fishery,ssfile,nage=40,type="length")
{
# SJH 5/19/2014 7:24:40 PM
# Goes to the fit file and gets the observed and predicted proportions at length
# and gets the residual  (p-phat)
# then returns all three in a list object
# one fishery at a time!

#
##gets residuals from length.fit file
filename <- fitfile
#number of fisheries
nfish <- scan(filename, nlines=1, skip=2)
#records per fishery
nfish2 <- scan(filename, nlines=1, skip=3)
#length intervals
lendat <- scan(filename, nlines=1, skip=1)
lenint <- lendat[2] + 1:lendat[1] * lendat[3] - lendat[3]

##time step for fishery matrix
tstep <- matrix(NA, nfish2[fishery], 3)
##set up obs. and pred. matrices
obslf <- matrix(NA, nfish2[fishery], lendat[1])
predlf <- matrix(NA, nfish2[fishery], lendat[1])

##read in
loadfit <- readLines(filename)
##locate first line
line1 <- grep(paste("# fishery", fishery), loadfit)
#deal with multiples
line1 <- ifelse(fishery == 1, line1[1], line1)
line1 <- ifelse(fishery == 2, line1[1], line1)

    if(type=="length") {
    x <- c(1,4,5)
    count2 <- nage + 7
    }
    if(type=="weight") {
    x <- c(1,6,8)
    count2 <- nage + 11
    }

count <- line1
#browser()
for(i in 1:nfish2[fishery]){
#print(i)
        tstep[i,] <- as.numeric(unlist(strsplit(loadfit[count+x[1]]," ")))
        obslf[i,] <- as.numeric(unlist(strsplit(loadfit[count+x[2]]," "))[-1])
        predlf[i,] <- as.numeric(unlist(strsplit(loadfit[count+x[3]]," "))[-1])
        count <- count + count2
}
#residuals: rows = time; col = length interval
resid <- obslf - predlf
return(list(obslf=obslf,predlf=predlf,resid=resid))
}










