library(ggplot2)


ed.heat.orig <- read.csv("Energy_Check_original.csv")
ed.heat.orig$tot.rad <- ed.heat.orig$lwnet*(1-ed.heat.orig$albedo.lw) + ed.heat.orig$swnet*(1-ed.heat.orig$albedo.sw)
ed.heat.orig$tot.rad <- ed.heat.orig$qh
ed.heat.orig$tot.rad <- ed.heat.orig$qle
ed.heat.orig$tot.flux <- rowSums(ed.heat.orig[c("qh", "qle")])
ed.heat.orig$tot.fluxg <- rowSums(ed.heat.orig[c("qh", "qle", "qg")])
ed.heat.orig$mo <- as.ordered(ed.heat.orig$mo)
ed.heat.orig$snow2 <- as.factor(ifelse(ed.heat.orig$snow>0, "yes", "no"))
summary(ed.heat.orig)



ed.heat <- read.csv("Energy_Check.csv")
ed.heat$tot.rad <- ed.heat$lwdown*(1-ed.heat$albedo.lw) + ed.heat$swdown*(1-ed.heat$albedo.sw)
ed.heat$tot.rad2 <- ed.heat$lwdown-ed.heat$lwup + ed.heat$swdown-ed.heat$swup
ed.heat$tot.flux <- rowSums(ed.heat[c("qh", "qle")])
ed.heat$tot.fluxg <- rowSums(ed.heat[c("qh", "qle", "qg")])
ed.heat$mo <- as.ordered(ed.heat$mo)
ed.heat$snow2 <- as.factor(ifelse(ed.heat$snow>0, "yes", "no"))
summary(ed.heat)
head(ed.heat)


par(mfrow=c(1,1))
plot(ed.heat$tot.flux ~ ed.heat.orig[1:nrow(ed.heat),"tot.flux"])
  abline(0,1, col="red", lty="dashed")

ggplot(data=ed.heat.orig) +
  geom_point(aes(x=tot.rad, y=tot.flux, color=mo), size=2) +
  geom_abline(intercept=0, slope=1, color="red", linetype="dashed")

ggplot(data=ed.heat) +
  geom_point(aes(x=tot.rad, y=tot.flux, color=mo), size=2) +
  geom_abline(intercept=0, slope=1, color="red", linetype="dashed")


rad.lm <- lm(tot.flux ~ rnet -1, data=ed.heat)
summary(rad.lm)

rad.lm2 <- lm(tot.flux ~ rnet, data=ed.heat)
summary(rad.lm2)

rad.lm <- lm(tot.fluxg ~ rnet -1, data=ed.heat)
summary(rad.lm)


ggplot(data=ed.heat) +
  geom_point(aes(x=tot.rad2, y=tot.fluxg, color=mo), size=2) +
  geom_abline(intercept=0, slope=1, color="red", linetype="dashed")


ggplot(data=ed.heat) +
  geom_point(aes(x=tot.rad, y=tot.flux, color=yr), size=2) +
  geom_abline(intercept=0, slope=1, color="red", linetype="dashed")

ggplot(data=ed.heat) +
  geom_point(aes(x=tot.rad, y=tot.flux, color=mo), size=2) +
#   stat_smooth(aes(x=tot.rad, y=tot.flux), method="lm", se=F)  +
  geom_abline(intercept=0, slope=1, color="black", linetype="dashed") + 
  ggtitle("without ground sensible heat")
  
ggplot(data=ed.heat) +
  geom_point(aes(x=tot.rad, y=tot.fluxg, color=mo), size=2) +
  stat_smooth(aes(x=tot.rad, y=tot.flux, color=mo), method="lm", se=F)  +
  geom_abline(intercept=0, slope=1, color="black", linetype="dashed") +
  ggtitle("with ground sensible heat")


ggplot(data=ed.heat) +
  geom_point(aes(x=tot.rad, y=tot.flux, color=snow2), size=2) +
  stat_smooth(aes(x=tot.rad, y=tot.flux, color=snow2), method="lm")  +
  geom_abline(intercept=0, slope=1, color="black", linetype="dashed") 



  
par(mfrow=c(2,1))
plot(tot.flux ~ tot.rad, data=ed.heat, xlim=range(ed.heat[,c("tot.rad", "tot.fluxg")]), ylim=range(ed.heat[,c("tot.rad", "tot.fluxg")]))
abline(0,1, col="red")

plot(tot.fluxg ~ tot.rad, data=ed.heat, xlim=range(ed.heat[,c("tot.rad", "tot.fluxg")]), ylim=range(ed.heat[,c("tot.rad", "tot.fluxg")]))
abline(0,1, col="red")
