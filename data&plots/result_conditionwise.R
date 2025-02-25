setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


library(ggplot2)



dat_rms<-function(dat)
{
  datn <- paste(dat,".txt",sep="")
  
  # add names
  if (dat =="sub1") {
    nam <- 'GA'
  } else if ( dat =="sub2") {
    nam <- 'YX'
  } else if ( dat =="sub3") {
    nam <- 'MM'
  } else if ( dat =="sub4") {
    nam <- 'JP'
  } else {
    nam <- 'MW'
  }
  
  # read data
  dt.df<-read.table(datn,header=TRUE)
  rms.df<-read.table("rmsContrast.csv",sep=",",header=TRUE)
  
  # add new columns
  dt.df$rms<-NA
  dt.df$matched_rms<-NA
  
  # search nrms contrast value according to tau, alpha, repeat
  for(i in 1:nrow(dt.df))
  {
    dt.df$rms[i]<-rms.df$rmsConstrast[which(rms.df$rep==dt.df$rep[i]
                                            &rms.df$alpha==dt.df$a_test[i]
                                            &rms.df$tau==dt.df$t_test[i])]
    dt.df$matched_rms[i]<-rms.df$rmsConstrast[which(rms.df$rep==dt.df$rep[i]
                                                    &rms.df$alpha==dt.df$matched_alpha[i]
                                                    &rms.df$tau==dt.df$t_test[i])] 
  }
  
  dt.df$alpha<-as.factor(dt.df$a_test)
  dt.df$tau<-as.factor(dt.df$t_test)
  dt.df$matched_rms_diff <- dt.df$matched_rms - dt.df$rms
  
  rms_mean <- aggregate(matched_rms_diff ~ alpha + tau, data = dt.df, FUN= "mean" )
  rms_sd <- aggregate(matched_rms_diff ~ alpha + tau, data = dt.df, FUN= "sd" )
  rms_standard <-aggregate(rms ~ alpha + tau, data = dt.df, FUN= "mean" )
  
  rms.df <- cbind(rms_mean,rms_sd$matched_rms_diff,rms_standard$rms)
  
  #rename column
  colnames(rms.df)[4] <- "sd"
  colnames(rms.df)[5] <- "standard_rms"
  #as.numeric(levels(f))[f]
  rms.df$alpha<-as.numeric(levels(rms.df$alpha))[rms.df$alpha]
  rms.df$nam<-as.factor(nam)
  
  
  return(rms.df)
}  
  
dat0<- c()
for(i in 1:5)
{
  datn <- paste("sub",i,sep="")
  dat<-dat_rms(datn)
  dat0<-rbind(dat0,dat)
}




p<- ggplot(dat0, aes(x=alpha, y=matched_rms_diff, color=tau))+ 
  geom_point()+
  geom_line(aes(group=tau))+
  geom_errorbar(aes(ymin=matched_rms_diff-1/2*sd, ymax=matched_rms_diff+1/2*sd),width=0.02)+
  ylab("contrast difference")+
  xlab("standard rms contrast")+
  ylim(-5, 50)+
  theme_classic()+
  facet_wrap(vars(nam), nrow=2)










'

tit="Matched and Standard normalized rms Contrast by Trial"
  
p<- ggplot(dat0, aes(x=rms, y=matched_rms, shape=alpha, color=tau)) + 
    geom_point() +
    geom_abline(slope=1,color="darkgrey") +
    #geom_vline(xintercept = 0, color="darkgrey")+
    xlab("standard rms contrast")+
    ylab("matched rms contrast")+
    xlim(0, 100)+
    ylim(0, 100)+
    #labs(title=tit)+
    theme(text = element_text(size=100))+
    theme_classic()+
    facet_wrap(vars(nam), nrow=2)

p
' 
