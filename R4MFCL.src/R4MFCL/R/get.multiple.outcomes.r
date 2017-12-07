#' 
#' @importFrom xtable xtable print.xtable
#' @export
#'
get.multiple.outcomes = function(direcs=c("SKJ14/","SKJ14/"), repnm="plot-12.par.rep", parnm="12.par", nofsh=TRUE, nofshp=c(44,4), ltyr=2011,
                                 vers="latex", keep.vector=c("bo","sbo","sbcsbmsy"), rnd.cutoff=10, output.tab=FALSE, out.file=NULL,
                                 output.percent=FALSE, per.file=NULL, captn.out="Define caption", captn.per="Define caption", 
                                 tab.header=c("Quantity","1","2"), calc.quants=c(0.5,0.05,0.95), size.out=NULL, size.per=NULL)
{

require(xtable)  
    
    if(length(repnm == 1)) repnm = rep(repnm, length(direcs))
    if(length(parnm == 1)) parnm = rep(parnm, length(direcs))
  
    out.fun = function(x)
    {
      
      get.outcomes(file.rep=read.rep(paste0(direcs[x], repnm[x])), file.par=read.par(paste0(direcs[x], parnm[x])), catch.rep=paste0(direcs[x], "catch.rep"),
                   nofish=nofsh, nofishp=nofshp, lateyr=ltyr, version=vers, re.keep=keep.vector)

    }

    mult.out <- lapply(1:length(direcs), out.fun)

    outtab <- unlist(mult.out)
    dim(outtab) <- c(length(keep.vector), length(outtab)/length(keep.vector))
    tmpout <- outtab
    outtab <- cbind(paste0("\\", names(mult.out[[1]])), as.data.frame(outtab))
    names(outtab) <- tab.header
    outtab[,1] <- as.character(outtab[,1])
    
    rnd.mat <- matrix(c(rep(0, nrow(outtab)), as.numeric(ifelse(outtab > rnd.cutoff, 0, 2))), nrow=nrow(outtab), ncol=ncol(outtab) + 1, byrow=FALSE)
    
    if(output.tab)
    {    
      grid.xtab <- xtable(outtab, align=c("l","l",rep("c", dim(outtab)[2]-1)), digits=rnd.mat, caption=captn.out, label="tab:refpnttab") # digits=rep(0,5), 
      
      print.xtable(grid.xtab, file=out.file, include.rownames=FALSE, sanitize.text.function = function(x) x, size=size.out, caption.placement="top")       
    }
    
    if(output.percent)
    {   

      pertab <- cbind(paste0("\\", names(mult.out[[1]])), as.data.frame(t(apply(outtab[,-1], 1, quantile, probs=calc.quants))))
      names(pertab) <- c("Quantity", paste0(calc.quants*100, "\\%"))
      pertab[,1] <- as.character(pertab[,1])
      
      rnd.mat <- matrix(c(rep(0, nrow(pertab)), as.numeric(ifelse(pertab > rnd.cutoff, 0, 2))), nrow=nrow(pertab), ncol=ncol(pertab) + 1, byrow=FALSE)
      
      per.xtab <- xtable(pertab, align=c("l","l",rep("c", dim(pertab)[2]-1)), digits=rnd.mat, caption=captn.per, label="tab:gridperc") # digits=rep(0,5), 
      
      print.xtable(per.xtab, file=per.file, include.rownames=FALSE, sanitize.text.function = function(x) x, size=size.per, caption.placement="top")       
    }
        
    return(outtab)
}