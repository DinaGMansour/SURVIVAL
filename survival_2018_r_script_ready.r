setwd("C:/Users/di3053ma/Desktop/MedBioInfo/SURVIVAL")
library("survival")
library("survminer")
Big_liver = read.csv("BIG_liver_DATA.csv", sep = ";", header = T)
head(Big_liver)
names(Big_liver)
Transcript_means_LIVER <-colMeans(Big_liver[8:816], na.rm = TRUE)
big_liver_again = rbind(Big_liver, Transcript_means_LIVER)
write.csv(big_liver_again, "big_liver_col_means.csv")
#str(Big_liver)
summary(Big_liver$Stage)
summary(Big_liver$Race)
Big_liver$STATUS = ifelse(Big_liver$Status == "dead", 1,0)
Big_liver$SEX = ifelse(Big_liver$Gender == "male", 1,2)
str(Big_liver)
summary(Big_liver$Gender)
summary(Big_liver$Race)
summary(Big_liver$Stage)
##### Kaplan-Meier estimate of the survival function:
fit_time_death = survfit(Surv(as.numeric(Big_liver$LivingDays),Big_liver$STATUS) ~ 1)
summary(fit_time_death)
str(fit_time_death)
median(fit_time_death$time)
plot(fit_time_death, main= "Kaplan-Meier estimate with 95% confidence bounds",xlab = "time", ylab = "Survival Probability")
##### Kaplan-Meier estimate of the survival function and sex:
big_fit_survival_time_sex = survfit(Surv(as.numeric(Big_liver$LivingDays),Big_liver$STATUS) ~ Big_liver$SEX)
summary(big_fit_survival_time_sex)
plot(big_fit_survival_time_sex,main= "Kaplan-Meier estimate in different sex", xlab = "time", ylab = "Survival Probability", col = c("blue", "purple"))
legend(30,1,c("Male", "Female"), col = c("blue", "purple"), lwd = 0.5, pch = c(1,2), lty = c(1,2))
##### Kaplan-Meier estimate of the survival function and stage:
big_fit_survival_time_stage = survfit(Surv(as.numeric(Big_liver$LivingDays),Big_liver$STATUS) ~ Big_liver$Stage)
summary(big_fit_survival_time_stage)
plot(big_fit_survival_time_stage, main= "Kaplan-Meier estimate in different stages", xlab = "time", ylab = "Survival Probability", col = c(1:10))
legend(30,1,c("stage i", "stage ii", "stage iii", "stage iiia","stage iiib","stage iiic","stage iv","stage iva","stage ivb","not_reported"), col = c(1:10), lwd = 0.5)
##### Kaplan-Meier estimate of the survival function and Race:
big_fit_survival_time_Race = survfit(Surv(as.numeric(Big_liver$LivingDays),Big_liver$STATUS) ~ Big_liver$Race)
summary(big_fit_survival_time_Race)
plot(big_fit_survival_time_Race,main= "Kaplan-Meier estimate in different Races", xlab = "time", ylab = "Survival Probability", col = c(1:5))
legend(30,1,c("American", "Asian", "African", "White","not_reported"), col = c(1:5), lwd = 0.5)
##### Cox_regression analysis using age, gender, race and stage as covariates:
cox_reg_all_cov_sctest.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(Big_liver$LivingDays),Big_liver$STATUS) ~ as.numeric(x) + Big_liver$SEX + Big_liver$Age + Big_liver$Race + Big_liver$Stage)
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  return(SCTEST_p)
}
sctest_p_all_cov <- apply(Big_liver[8:816],2, cox_reg_all_cov_sctest.it)
sctest_p_all_cov = data.frame(sctest_p_all_cov)
head(sctest_p_all_cov)
#colnames(sctest_p_all_cov) = c("TRANSCRIPT", "sctest_p")
cox_reg_all_cov_wald.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(Big_liver$LivingDays),Big_liver$STATUS) ~ as.numeric(x)+ Big_liver$SEX + Big_liver$Age + Big_liver$Race + Big_liver$Stage)
  summ_of_gene <- summary(cox_transcript)
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  return(WALDTEST_p)
}
waldtest_p_all_cov <- apply(Big_liver[8:816],2, cox_reg_all_cov_wald.it)
waldtest_p_all_cov = data.frame(waldtest_p_all_cov)
#head(waldtest_p_all_cov)
#colnames(waldtest_p_all_cov) = c("TRANSCRIPT", "waldtest_p")
cox_reg_all_cov_log.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(Big_liver$LivingDays),Big_liver$STATUS) ~ as.numeric(x) + Big_liver$SEX + Big_liver$Age + Big_liver$Race + Big_liver$Stage)
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  #df_res_1 = as.data.frame (SCTEST_p, WALDTEST_p, LOGTEST_p)
  #return(summ_of_gene)
  #df_res = tidy(summ_of_gene)
  return(LOGTEST_p)
}
logtest_p_all_cov <- apply(Big_liver[8:816],2, cox_reg_all_cov_log.it)
logtest_p_all_cov = data.frame(logtest_p_all_cov)
#head(logtest_p_all_cov)
#colnames(logtest_p_all_cov) = c("TRANSCRIPT", "logtest_p")
#library(plyr)
#wald_all_cov = join(sctest_p_all_cov, waldtest_p_all_cov, by = "TRANSCRIPT")
#head(wald_all_all_cov)
all_P_all_cov= cbind.data.frame(sctest_p_all_cov, waldtest_p_all_cov, logtest_p_all_cov)
head(all_P_all_cov)
#write.csv(all_P_all_cov, "ALL_cov_transcript_survival_new_df.csv")
##### Cox regression analysis without covariates:
cox_reg_NO_cov_sctest.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(Big_liver$LivingDays),Big_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  return(SCTEST_p)
}
sctest_p_NO_cov <- apply(Big_liver[8:816],2, cox_reg_NO_cov_sctest.it)
sctest_p_NO_cov = data.frame(sctest_p_NO_cov)
#head(sctest_p_NO_cov)
#colnames(sctest_p_all_cov) = c("TRANSCRIPT", "sctest_p")
cox_reg_NO_cov_wald.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(Big_liver$LivingDays),Big_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  return(WALDTEST_p)
}
waldtest_p_NO_cov <- apply(Big_liver[8:816],2, cox_reg_NO_cov_wald.it)
waldtest_p_NO_cov = data.frame(waldtest_p_NO_cov)
#head(waldtest_p_NO_cov)
#colnames(waldtest_p_all_cov) = c("TRANSCRIPT", "waldtest_p")
cox_reg_NO_cov_log.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(Big_liver$LivingDays),Big_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  #df_res_1 = as.data.frame (SCTEST_p, WALDTEST_p, LOGTEST_p)
  #return(summ_of_gene)
  #df_res = tidy(summ_of_gene)
  return(LOGTEST_p)
}
logtest_p_NO_cov <- apply(Big_liver[8:816],2, cox_reg_NO_cov_log.it)
logtest_p_NO_cov = data.frame(logtest_p_NO_cov)
#head(logtest_p_NO_cov)
#colnames(logtest_p_all_cov) = c("TRANSCRIPT", "logtest_p")
#library(plyr)
#wald_all_cov = join(sctest_p_all_cov, waldtest_p_all_cov, by = "TRANSCRIPT")
#head(wald_all_all_cov)
all_P_NO_cov= cbind.data.frame(sctest_p_NO_cov, waldtest_p_NO_cov, logtest_p_NO_cov)
head(all_P_NO_cov)
write.csv(all_P_NO_cov, "NO_cov_transcript_survival_new_df.csv")
######################### ADJUST and sort p_values:
ALL_cov_to_adjust = read.csv("all_cov_to_adjust_3p.csv", sep = ";", header = T)
head(ALL_cov_to_adjust)
#str(ALL_cov_to_adjust)
ALL_cov_to_adjust$sc_Bonferroni = p.adjust(ALL_cov_to_adjust$sctest_p_all_cov, method = "bonferroni")
ALL_cov_to_adjust$wald_Bonferroni = p.adjust(ALL_cov_to_adjust$waldtest_p_all_cov, method = "bonferroni")
ALL_cov_to_adjust$log_Bonferroni = p.adjust(ALL_cov_to_adjust$logtest_p_all_cov, method = "bonferroni")
#head(ALL_cov_to_adjust)
ALL_cov_to_adjust$sc_FDR = p.adjust(ALL_cov_to_adjust$sctest_p_all_cov, method = "fdr")
ALL_cov_to_adjust$wald_FDR = p.adjust(ALL_cov_to_adjust$waldtest_p_all_cov, method = "fdr")
ALL_cov_to_adjust$log_fdr = p.adjust(ALL_cov_to_adjust$logtest_p_all_cov, method = "fdr")
#head(ALL_cov_to_adjust)
#write.csv(ALL_cov_to_adjust, "ALL_cov_all_p_adjusted.csv")
SORTED_ALL_COV_sc_fdr_success_1 = ALL_cov_to_adjust[order(ALL_cov_to_adjust$sc_FDR),]
#head(SORTED_ALL_COV_sc_fdr_success_1 )
#write.csv(SORTED_ALL_COV_sc_fdr_success_1, "Top_transcripts_affecting_survival_all_cov_sc_FDR.csv")
SORTED_ALL_COV_wald_fdr_success_1 = ALL_cov_to_adjust[order(ALL_cov_to_adjust$wald_FDR),]
#head(SORTED_ALL_COV_wald_fdr_success_1 )
#write.csv(SORTED_ALL_COV_wald_fdr_success_1, "Top_transcripts_affecting_survival_all_cov_wald_FDR.csv")
SORTED_ALL_COV_log_fdr_success_1 = ALL_cov_to_adjust[order(ALL_cov_to_adjust$log_fdr),]
#head(SORTED_ALL_COV_log_fdr_success_1 )
TOP_sig_10 = data.frame(SORTED_ALL_COV_sc_fdr_success_1$Transcript_ID,SORTED_ALL_COV_sc_fdr_success_1$sctest_p_all_cov,  SORTED_ALL_COV_sc_fdr_success_1$sc_FDR)
TOP_20_liver = head(TOP_sig_10,20)
head(TOP_20_liver)
#write.csv(TOP_20_liver, "TOP_20_liver_sig.csv")
#write.csv(SORTED_ALL_COV_log_fdr_success_1 , "Top_transcripts_affecting_survival_all_cov_log_FDR.csv")
##### Proportional Hazards of ENSG00000010292 transcripts:
Big_liver$ENSG00000010292[Big_liver$ENSG00000010292 == "NA"] <- 0
cox_reg_residuals_sex_cov = coxph(Surv(as.numeric(Big_liver$LivingDays),Big_liver$STATUS) ~ as.numeric(Big_liver$ENSG00000010292)+ Big_liver$SEX)
hazards_sex_cov <- cox.zph(cox_reg_residuals_sex_cov)
hazards_sex_cov
plot(hazards_sex_cov)
cox_reg_residuals_age_cov = coxph(Surv(as.numeric(Big_liver$LivingDays),Big_liver$STATUS) ~ as.numeric(Big_liver$ENSG00000010292)+ Big_liver$Age)
hazards_age_cov <- cox.zph(cox_reg_residuals_age_cov)
hazards_age_cov
plot(hazards_age_cov)
########### Cox Regression analysis to determine top 15 transcripts associated with RACE:
cox_reg_10_race_summ.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(Big_liver$LivingDays),Big_liver$STATUS) ~ as.numeric(x) + Big_liver$Race)
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(summ_of_gene)
}
race_summ_p_new_survival <- apply(Big_liver[8:816],2, cox_reg_10_race_summ.it)
#race_summ_p_new_survival = as.data.frame(race_summ_p_new_survival)
#head(race_summ_p_new_survival)
cox_reg_10_race_sc.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(Big_liver$LivingDays),Big_liver$STATUS) ~ as.numeric(x) + Big_liver$Race)
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(SCTEST_p )
}
race_sc_p_new_survival <- apply(Big_liver[8:816],2, cox_reg_10_race_sc.it)
race_sc_p_new_survival = as.data.frame(race_sc_p_new_survival)
#head(race_sc_p_new_survival)
cox_reg_10_race_w.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(Big_liver$LivingDays),Big_liver$STATUS) ~ as.numeric(x) + Big_liver$Race)
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(WALDTEST_p )
}
race_w_p_new_survival <- apply(Big_liver[8:816],2, cox_reg_10_race_w.it)
race_w_p_new_survival = as.data.frame(race_w_p_new_survival)
#head(race_w_p_new_survival)
cox_reg_10_race_log.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(Big_liver$LivingDays),Big_liver$STATUS) ~ as.numeric(x) + Big_liver$Race)
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(LOGTEST_p)
}
race_log_p_new_survival <- apply(Big_liver[8:816],2, cox_reg_10_race_log.it)
race_log_p_new_survival = as.data.frame(race_log_p_new_survival)
#head(race_log_p_new_survival)
all_P_race = cbind.data.frame(race_sc_p_new_survival, race_w_p_new_survival, race_log_p_new_survival)
#head(all_P_race)
#write.csv(all_P_race, "race_transcript_survival.csv")
######################### ADJUST and sort p_values of RACE:
RACE_to_adjust = read.csv("RACE_all_p.csv", sep = ";", header = T)
head(RACE_to_adjust)
#str(RACE_to_adjust)
RACE_to_adjust$sc_Bonferroni = p.adjust(RACE_to_adjust$race_sc_p_new_survival, method = "bonferroni")
RACE_to_adjust$wald_Bonferroni = p.adjust(RACE_to_adjust$race_w_p_new_survival, method = "bonferroni")
RACE_to_adjust$log_Bonferroni = p.adjust(RACE_to_adjust$race_log_p_new_survival, method = "bonferroni")
#head(RACE_to_adjust)
RACE_to_adjust$sc_FDR = p.adjust(RACE_to_adjust$race_sc_p_new_survival, method = "fdr")
RACE_to_adjust$wald_FDR = p.adjust(RACE_to_adjust$race_w_p_new_survival, method = "fdr")
RACE_to_adjust$log_fdr = p.adjust(RACE_to_adjust$race_log_p_new_survival, method = "fdr")
#head(RACE_to_adjust)
SORTED_RACE_sc_fdr_success_1 = RACE_to_adjust[order(RACE_to_adjust$sc_FDR),]
#head(SORTED_RACE_sc_fdr_success_1, 20)
TOP_RACE = data.frame(SORTED_RACE_sc_fdr_success_1$Transcript_ID,SORTED_RACE_sc_fdr_success_1$race_sc_p_new_survival, SORTED_RACE_sc_fdr_success_1$sc_FDR)
head(TOP_RACE,20)
############ Cox Regression analysis to determine top 15 transcrpts associated with AGE:
cox_reg_10_age_summ.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(Big_liver$LivingDays),Big_liver$STATUS) ~ as.numeric(x) + Big_liver$Age)
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(summ_of_gene)
}
age_summ_p_new_survival <- apply(Big_liver[8:816],2, cox_reg_10_age_summ.it)
#age_summ_p_new_survival = as.data.frame(age_summ_p_new_survival)
#head(age_summ_p_new_survival)
cox_reg_10_age_sc.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(Big_liver$LivingDays),Big_liver$STATUS) ~ as.numeric(x) + Big_liver$Age)
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(SCTEST_p )
}
age_sc_p_new_survival <- apply(Big_liver[8:816],2, cox_reg_10_age_sc.it)
age_sc_p_new_survival = as.data.frame(age_sc_p_new_survival)
#head(age_sc_p_new_survival)
cox_reg_10_age_w.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(Big_liver$LivingDays),Big_liver$STATUS) ~ as.numeric(x) + Big_liver$Age)
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(WALDTEST_p )
}
age_w_p_new_survival <- apply(Big_liver[8:816],2, cox_reg_10_age_w.it)
age_w_p_new_survival = as.data.frame(age_w_p_new_survival)
#head(age_w_p_new_survival)
cox_reg_10_age_log.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(Big_liver$LivingDays),Big_liver$STATUS) ~ as.numeric(x) + Big_liver$Age)
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(LOGTEST_p)
}
age_log_p_new_survival <- apply(Big_liver[8:816],2, cox_reg_10_age_log.it)
age_log_p_new_survival = as.data.frame(age_log_p_new_survival)
#head(age_log_p_new_survival)
all_P_age = cbind.data.frame(age_sc_p_new_survival, age_w_p_new_survival, age_log_p_new_survival)
head(all_P_age)
write.csv(all_P_age, "age_transcript_survival.csv")
######################### ADJUST and sort p_values of AGE:
AGE_to_adjust = read.csv("AGE_to_adjust_P.csv", sep = ";", header = T)
head(AGE_to_adjust)
str(AGE_to_adjust)
AGE_to_adjust$sc_Bonferroni = p.adjust(AGE_to_adjust$age_sc_p_new_survival, method = "bonferroni")
AGE_to_adjust$wald_Bonferroni = p.adjust(AGE_to_adjust$age_w_p_new_survival, method = "bonferroni")
AGE_to_adjust$log_Bonferroni = p.adjust(AGE_to_adjust$age_log_p_new_survival, method = "bonferroni")
#head(RACE_to_adjust)
AGE_to_adjust$sc_FDR = p.adjust(AGE_to_adjust$age_sc_p_new_survival, method = "fdr")
AGE_to_adjust$wald_FDR = p.adjust(AGE_to_adjust$age_w_p_new_survival, method = "fdr")
AGE_to_adjust$log_fdr = p.adjust(AGE_to_adjust$age_log_p_new_survival, method = "fdr")
#head(RACE_to_adjust)
SORTED_AGE_sc_fdr_success_1 = AGE_to_adjust[order(AGE_to_adjust$sc_FDR),]
head(SORTED_AGE_sc_fdr_success_1, 20)
TOP_AGE = data.frame(SORTED_AGE_sc_fdr_success_1$Transcript_ID,SORTED_AGE_sc_fdr_success_1$age_sc_p_new_survival, SORTED_AGE_sc_fdr_success_1$sc_FDR)
head(TOP_AGE,20)
###### Subset Liver Tumor data based on Age:
range(Big_liver$Age, na.rm = TRUE)
Big_liver$YEARS = as.numeric(Big_liver$Age) /365
Big_liver$YEARS
range(Big_liver$YEARS, na.rm = TRUE)
youth_liver =subset(Big_liver, Big_liver$YEARS < 30)
youth_liver$AGE = ifelse(youth_liver$YEARS < 30, "Young", "OLD")
youth_liver$AGE
length(youth_liver$Gender)

adults_liver = subset(Big_liver, Big_liver$YEARS >= 30 | Big_liver$YEARS < 60)
adults_liver$AGE = ifelse(adults_liver$YEARS >= 30 | adults_liver$YEARS < 60, "Adult", "OLD")
adults_liver$AGE
length(adults_liver$Gender)
old_liver = subset(Big_liver, Big_liver$YEARS >= 60)
old_liver$AGE = ifelse(old_liver$YEARS > 60, "Old", "NO")
old_liver$AGE
length(old_liver$Gender)

AGE_ALL_LIVER = rbind (youth_liver,adults_liver,old_liver )
head(AGE_ALL_LIVER)
###### Kaplan-Meier estimate of the survival function and AGE:
fit_time_age = survfit(Surv(as.numeric(AGE_ALL_LIVER$LivingDays),AGE_ALL_LIVER$STATUS) ~ AGE_ALL_LIVER$AGE)
summary(fit_time_age)
str(fit_time_age)
median(fit_time_death$time)
plot(fit_time_age, main= "Kaplan-Meier estimate  using age with 95% confidence bounds",xlab = "time", ylab = "Survival Probability", col = c("blue", "purple", "red"))
legend(30,1,c("Youth-group", "Adult-group", "Old-group"), col = c("blue", "purple", "red"), lwd = 0.5)






###### Cox regression analysis of different age groups:
##### Youth (< 30 years):
cox_reg_10_youth_summ.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(youth_liver$LivingDays),youth_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(summ_of_gene)
}
youth_summ_p_new_survival <- apply(youth_liver[8:816],2, cox_reg_10_youth_summ.it)
#age_summ_p_new_survival = as.data.frame(age_summ_p_new_survival)
#head(age_summ_p_new_survival)
cox_reg_10_youth_sc.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(youth_liver$LivingDays),youth_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(SCTEST_p )
}
youth_sc_p_new_survival <- apply(youth_liver[8:816],2, cox_reg_10_youth_sc.it)
youth_sc_p_new_survival = as.data.frame(youth_sc_p_new_survival)
#head(youth_sc_p_new_survival)
cox_reg_10_youth_w.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(youth_liver$LivingDays),youth_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(WALDTEST_p )
}
youth_w_p_new_survival <- apply(youth_liver[8:816],2, cox_reg_10_youth_w.it)
youth_w_p_new_survival = as.data.frame(youth_w_p_new_survival)
#head(youth_w_p_new_survival)
cox_reg_10_youth_log.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(youth_liver$LivingDays),youth_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(LOGTEST_p)
}
youth_log_p_new_survival <- apply(youth_liver[8:816],2, cox_reg_10_youth_log.it)
youth_log_p_new_survival = as.data.frame(youth_log_p_new_survival)
#head(age_log_p_new_survival)
all_P_youth = cbind.data.frame(youth_sc_p_new_survival, youth_w_p_new_survival, youth_log_p_new_survival)
head(all_P_youth)
write.csv(all_P_youth, "youth_transcript_survival.csv")
######################### ADJUST and sort p_values of Youth Group:
youth_to_adjust = read.csv("youth_p_all_to_adjust.csv", sep = ";", header = T)
head(youth_to_adjust)
str(youth_to_adjust)
youth_to_adjust$sc_Bonferroni = p.adjust(youth_to_adjust$youth_sc_p, method = "bonferroni")
youth_to_adjust$wald_Bonferroni = p.adjust(youth_to_adjust$youth_w_p, method = "bonferroni")
youth_to_adjust$log_Bonferroni = p.adjust(youth_to_adjust$youth_log_p, method = "bonferroni")
#head(youth_to_adjust)
youth_to_adjust$sc_FDR = p.adjust(youth_to_adjust$youth_sc_p, method = "fdr")
youth_to_adjust$wald_FDR = p.adjust(youth_to_adjust$youth_w_p, method = "fdr")
youth_to_adjust$log_fdr = p.adjust(youth_to_adjust$youth_log_p, method = "fdr")
#head(youth_to_adjust)
SORTED_youth_sc_fdr_success_1 = youth_to_adjust[order(youth_to_adjust$sc_FDR),]
head(SORTED_youth_sc_fdr_success_1, 20)
TOP_youth = data.frame(SORTED_youth_sc_fdr_success_1$Transcript_ID,SORTED_youth_sc_fdr_success_1$youth_sc_p, SORTED_youth_sc_fdr_success_1$sc_FDR)
head(TOP_youth,20)
##### Adult group (>= 30 years < 60 years):
cox_reg_10_adults_summ.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(adults_liver$LivingDays),adults_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(summ_of_gene)
}
adults_summ_p_new_survival <- apply(adults_liver[8:816],2, cox_reg_10_adults_summ.it)
cox_reg_10_adults_sc.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(adults_liver$LivingDays),adults_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(SCTEST_p )
}
adults_sc_p_new_survival <- apply(adults_liver[8:816],2, cox_reg_10_adults_sc.it)
adults_sc_p_new_survival = as.data.frame(adults_sc_p_new_survival)
#head(adults_sc_p_new_survival)
cox_reg_10_adults_w.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(adults_liver$LivingDays),adults_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(WALDTEST_p )
}
adults_w_p_new_survival <- apply(adults_liver[8:816],2, cox_reg_10_adults_w.it)
adults_w_p_new_survival = as.data.frame(adults_w_p_new_survival)
#head(adults_w_p_new_survival)
cox_reg_10_adults_log.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(adults_liver$LivingDays),adults_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(LOGTEST_p)
}
adults_log_p_new_survival <- apply(adults_liver[8:816],2, cox_reg_10_adults_log.it)
adults_log_p_new_survival = as.data.frame(adults_log_p_new_survival)
#head(adults_log_p_new_survival)
all_P_adults = cbind.data.frame(adults_sc_p_new_survival, adults_w_p_new_survival, adults_log_p_new_survival)
head(all_P_adults)
write.csv(all_P_adults, "adults_transcript_survival.csv")
######################### ADJUST and sort p_values of adults Group:
adults_to_adjust = read.csv("adults_to_adjust.csv", sep = ";", header = T)
head(adults_to_adjust)
str(adults_to_adjust)
adults_to_adjust$sc_Bonferroni = p.adjust(adults_to_adjust$adults_sc_p, method = "bonferroni")
adults_to_adjust$wald_Bonferroni = p.adjust(adults_to_adjust$adults_w_p, method = "bonferroni")
adults_to_adjust$log_Bonferroni = p.adjust(adults_to_adjust$adults_log_p, method = "bonferroni")
#head(adults_to_adjust)
adults_to_adjust$sc_FDR = p.adjust(adults_to_adjust$adults_sc_p, method = "fdr")
adults_to_adjust$wald_FDR = p.adjust(adults_to_adjust$adults_w_p, method = "fdr")
adults_to_adjust$log_fdr = p.adjust(adults_to_adjust$adults_log_p, method = "fdr")
#head(adults_to_adjust)
SORTED_adults_sc_fdr_success_1 = adults_to_adjust[order(adults_to_adjust$sc_FDR),]
head(SORTED_adults_sc_fdr_success_1, 20)
TOP_adults = data.frame(SORTED_adults_sc_fdr_success_1$Transcript_ID,SORTED_adults_sc_fdr_success_1$adults_sc_p, SORTED_adults_sc_fdr_success_1$sc_FDR)
head(TOP_adults,20)
##### OLd group (age >= 60 years):
cox_reg_10_old_summ.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(old_liver$LivingDays),old_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(summ_of_gene)
}
old_summ_p_new_survival <- apply(old_liver[8:816],2, cox_reg_10_old_summ.it)
cox_reg_10_old_sc.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(old_liver$LivingDays),old_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(SCTEST_p )
}
old_sc_p_new_survival <- apply(old_liver[8:816],2, cox_reg_10_old_sc.it)
old_sc_p_new_survival = as.data.frame(old_sc_p_new_survival)
#head(adults_sc_p_new_survival)
cox_reg_10_old_w.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(old_liver$LivingDays),old_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(WALDTEST_p )
}
old_w_p_new_survival <- apply(old_liver[8:816],2, cox_reg_10_old_w.it)
old_w_p_new_survival = as.data.frame(old_w_p_new_survival)
#head(old_w_p_new_survival)
cox_reg_10_old_log.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(old_liver$LivingDays),old_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(LOGTEST_p)
}
old_log_p_new_survival <- apply(old_liver[8:816],2, cox_reg_10_old_log.it)
old_log_p_new_survival = as.data.frame(old_log_p_new_survival)
#head(old_log_p_new_survival)
all_P_old = cbind.data.frame(old_sc_p_new_survival, old_w_p_new_survival, old_log_p_new_survival)
head(all_P_old)
write.csv(all_P_old, "old_transcript_survival.csv")
######################### ADJUST and sort p_values of old Group:
old_to_adjust = read.csv("old_to_adjust.csv", sep = ";", header = T)
head(old_to_adjust)
str(old_to_adjust)
old_to_adjust$sc_Bonferroni = p.adjust(old_to_adjust$old_sc_p_new_survival, method = "bonferroni")
old_to_adjust$wald_Bonferroni = p.adjust(old_to_adjust$old_w_p_new_survival, method = "bonferroni")
old_to_adjust$log_Bonferroni = p.adjust(old_to_adjust$old_log_p_new_survival, method = "bonferroni")
#head(old_to_adjust)
old_to_adjust$sc_FDR = p.adjust(old_to_adjust$old_sc_p_new_survival, method = "fdr")
old_to_adjust$wald_FDR = p.adjust(old_to_adjust$old_w_p_new_survival, method = "fdr")
old_to_adjust$log_fdr = p.adjust(old_to_adjust$old_log_p_new_survival, method = "fdr")
#head(old_to_adjust)
SORTED_old_sc_fdr_success_1 = old_to_adjust[order(old_to_adjust$sc_FDR),]
head(SORTED_old_sc_fdr_success_1, 20)
TOP_old = data.frame(SORTED_old_sc_fdr_success_1$Transcript_ID,SORTED_old_sc_fdr_success_1$old_sc_p_new_survival, SORTED_old_sc_fdr_success_1$sc_FDR)
head(TOP_old,20)
################## RACE asociated transcripts:
ASIAN_liver = subset(Big_liver, Big_liver$Race == "asian")
WHITE_liver = subset(Big_liver, Big_liver$Race == "white")
AFRO_AMERICAN_liver = subset(Big_liver, Big_liver$Race == "black or african american")
ALL_RACE = rbind(ASIAN_liver, WHITE_liver, AFRO_AMERICAN_liver)
head(ALL_RACE)
summary(ALL_RACE $Race)
big_fit_survival_time_all_race = survfit(Surv(as.numeric(ALL_RACE$LivingDays),ALL_RACE$STATUS) ~ ALL_RACE$Race)
summary(big_fit_survival_time_all_race)
plot(big_fit_survival_time_all_race,main= "Kaplan-Meier estimate in different Races", xlab = "time", ylab = "Survival Probability", col = c(1:5))
legend(30,1,c( "Asian", "White","Afro_American"), col = c(1:3), lwd = 0.5)
#### Cox Regression analysis of the transcripts in ASIAN liver:
cox_reg_10_asian_summ.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(ASIAN_liver$LivingDays),ASIAN_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(summ_of_gene)
}
asian_summ_p_new_survival <- apply(ASIAN_liver[8:816],2, cox_reg_10_asian_summ.it)
cox_reg_10_asian_sc.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(ASIAN_liver$LivingDays),ASIAN_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(SCTEST_p )
}
asian_sc_p_new_survival <- apply(ASIAN_liver[8:816],2, cox_reg_10_asian_sc.it)
asian_sc_p_new_survival = as.data.frame(asian_sc_p_new_survival)
#head(adults_sc_p_new_survival)
cox_reg_10_asian_w.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(ASIAN_liver$LivingDays),ASIAN_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(WALDTEST_p )
}
asian_w_p_new_survival <- apply(ASIAN_liver[8:816],2, cox_reg_10_asian_w.it)
asian_w_p_new_survival = as.data.frame(asian_w_p_new_survival)
#head(old_w_p_new_survival)
cox_reg_10_asian_log.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(ASIAN_liver$LivingDays),ASIAN_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(LOGTEST_p)
}
asian_log_p_new_survival <- apply(ASIAN_liver[8:816],2, cox_reg_10_asian_log.it)
asian_log_p_new_survival = as.data.frame(asian_log_p_new_survival)
#head(old_log_p_new_survival)
all_P_asian = cbind.data.frame(asian_sc_p_new_survival, asian_w_p_new_survival, asian_log_p_new_survival)
head(all_P_asian)
write.csv(all_P_asian, "asian_transcript_survival.csv")
######################### ADJUST and sort p_values of ASIAN Group:
asian_to_adjust = read.csv("ASIAN_to_adjust.csv", sep = ";", header = T)
head(asian_to_adjust)
str(asian_to_adjust)
asian_to_adjust$sc_Bonferroni = p.adjust(asian_to_adjust$asian_sc_p_new_survival, method = "bonferroni")
asian_to_adjust$wald_Bonferroni = p.adjust(asian_to_adjust$asian_w_p_new_survival, method = "bonferroni")
asian_to_adjust$log_Bonferroni = p.adjust(asian_to_adjust$asian_log_p_new_survival, method = "bonferroni")
#head(old_to_adjust)
asian_to_adjust$sc_FDR = p.adjust(asian_to_adjust$asian_sc_p_new_survival, method = "fdr")
asian_to_adjust$wald_FDR = p.adjust(asian_to_adjust$asian_w_p_new_survival, method = "fdr")
asian_to_adjust$log_fdr = p.adjust(asian_to_adjust$asian_log_p_new_survival, method = "fdr")
#head(old_to_adjust)
SORTED_asian_sc_fdr_success_1 = asian_to_adjust[order(asian_to_adjust$sc_FDR),]
head(SORTED_asian_sc_fdr_success_1, 20)
TOP_asian = data.frame(SORTED_asian_sc_fdr_success_1$Transcript_ID,SORTED_asian_sc_fdr_success_1$asian_sc_p_new_survival, SORTED_asian_sc_fdr_success_1$sc_FDR)
head(TOP_asian,20)
#### Cox Regression analysis of the transcripts in White liver:
cox_reg_10_white_summ.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(WHITE_liver$LivingDays),WHITE_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(summ_of_gene)
}
white_summ_p_new_survival <- apply(WHITE_liver[8:816],2, cox_reg_10_white_summ.it)
cox_reg_10_white_sc.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(WHITE_liver$LivingDays),WHITE_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(SCTEST_p )
}
white_sc_p_new_survival <- apply(WHITE_liver[8:816],2, cox_reg_10_white_sc.it)
white_sc_p_new_survival = as.data.frame(white_sc_p_new_survival)
#head(white_sc_p_new_survival)
cox_reg_10_white_w.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(WHITE_liver$LivingDays),WHITE_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(WALDTEST_p )
}
white_w_p_new_survival <- apply(WHITE_liver[8:816],2, cox_reg_10_white_w.it)
white_w_p_new_survival = as.data.frame(white_w_p_new_survival)
#head(old_w_p_new_survival)
cox_reg_10_white_log.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(WHITE_liver$LivingDays),WHITE_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(LOGTEST_p)
}
white_log_p_new_survival <- apply(WHITE_liver[8:816],2, cox_reg_10_white_log.it)
white_log_p_new_survival = as.data.frame(white_log_p_new_survival)
#head(old_log_p_new_survival)
all_P_white = cbind.data.frame(white_sc_p_new_survival, white_w_p_new_survival, white_log_p_new_survival)
head(all_P_white)
write.csv(all_P_white, "white_transcript_survival.csv")
######################### ADJUST and sort p_values of WHITE Group:
white_to_adjust = read.csv("white_to_adjust.csv", sep = ";", header = T)
head(white_to_adjust)
str(white_to_adjust)
white_to_adjust$sc_Bonferroni = p.adjust(white_to_adjust$white_sc_p_new_survival, method = "bonferroni")
white_to_adjust$wald_Bonferroni = p.adjust(white_to_adjust$white_w_p_new_survival, method = "bonferroni")
white_to_adjust$log_Bonferroni = p.adjust(white_to_adjust$white_log_p_new_survival, method = "bonferroni")
white_to_adjust$sc_FDR = p.adjust(white_to_adjust$white_sc_p_new_survival, method = "fdr")
white_to_adjust$wald_FDR = p.adjust(white_to_adjust$white_w_p_new_survival, method = "fdr")
white_to_adjust$log_fdr = p.adjust(white_to_adjust$white_log_p_new_survival, method = "fdr")
SORTED_white_sc_fdr_success_1 = white_to_adjust[order(white_to_adjust$sc_FDR),]
head(SORTED_white_sc_fdr_success_1, 20)
TOP_white = data.frame(SORTED_white_sc_fdr_success_1$Transcript_ID,SORTED_white_sc_fdr_success_1$white_sc_p_new_survival, SORTED_white_sc_fdr_success_1$sc_FDR)
head(TOP_white,20)
#### Cox Regression analysis of the transcripts in Black liver:
cox_reg_10_AFRO_summ.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(AFRO_AMERICAN_liver$LivingDays),AFRO_AMERICAN_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(summ_of_gene)
}
AFRO_summ_p_new_survival <- apply(AFRO_AMERICAN_liver[8:816],2, cox_reg_10_AFRO_summ.it)
cox_reg_10_AFRO_sc.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(AFRO_AMERICAN_liver$LivingDays),AFRO_AMERICAN_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(SCTEST_p )
}
AFRO_sc_p_new_survival <- apply(AFRO_AMERICAN_liver[8:816],2, cox_reg_10_AFRO_sc.it)
AFRO_sc_p_new_survival = as.data.frame(AFRO_sc_p_new_survival)
cox_reg_10_AFRO_w.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(AFRO_AMERICAN_liver$LivingDays),AFRO_AMERICAN_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(WALDTEST_p )
}
AFRO_w_p_new_survival <- apply(AFRO_AMERICAN_liver[8:816],2, cox_reg_10_AFRO_w.it)
AFRO_w_p_new_survival = as.data.frame(AFRO_w_p_new_survival)
cox_reg_10_AFRO_log.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(AFRO_AMERICAN_liver$LivingDays),AFRO_AMERICAN_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(LOGTEST_p)
}
AFRO_log_p_new_survival <- apply(AFRO_AMERICAN_liver[8:816],2, cox_reg_10_AFRO_log.it)
AFRO_log_p_new_survival = as.data.frame(AFRO_log_p_new_survival)
all_P_AFRO = cbind.data.frame(AFRO_sc_p_new_survival, AFRO_w_p_new_survival, AFRO_log_p_new_survival)
head(all_P_AFRO)
write.csv(all_P_AFRO, "AFRO_transcript_survival.csv")
######################### ADJUST and sort p_values of AFRO Group:
AFRO_to_adjust = read.csv("afro_to_adjust.csv", sep = ";", header = T)
head(AFRO_to_adjust)
str(AFRO_to_adjust)
AFRO_to_adjust$sc_Bonferroni = p.adjust(AFRO_to_adjust$AFRO_sc_p_new_survival, method = "bonferroni")
AFRO_to_adjust$wald_Bonferroni = p.adjust(AFRO_to_adjust$AFRO_w_p_new_survival, method = "bonferroni")
AFRO_to_adjust$log_Bonferroni = p.adjust(AFRO_to_adjust$AFRO_log_p_new_survival, method = "bonferroni")
AFRO_to_adjust$sc_FDR = p.adjust(AFRO_to_adjust$AFRO_sc_p_new_survival, method = "fdr")
AFRO_to_adjust$wald_FDR = p.adjust(AFRO_to_adjust$AFRO_w_p_new_survival, method = "fdr")
AFRO_to_adjust$log_fdr = p.adjust(AFRO_to_adjust$AFRO_log_p_new_survival, method = "fdr")
SORTED_AFRO_sc_fdr_success_1 = AFRO_to_adjust[order(AFRO_to_adjust$sc_FDR),]
head(SORTED_AFRO_sc_fdr_success_1, 20)
TOP_AFRO = data.frame(SORTED_AFRO_sc_fdr_success_1$Transcript_ID,SORTED_AFRO_sc_fdr_success_1$AFRO_sc_p_new_survival, SORTED_AFRO_sc_fdr_success_1$sc_FDR)
head(TOP_AFRO,20)
#####################################################################################
########### Liver Tumor Stage associated transcripts:
summary(Big_liver$Stage)
STAGE_1_liver = subset(Big_liver, Big_liver$Stage == "stage i")
STAGE_2_liver = subset(Big_liver, Big_liver$Stage == "stage ii")
head(STAGE_2_liver)
STAGE_3_liver = subset(Big_liver, Big_liver$Stage == "stage iii" )
head(STAGE_3_liver)
STAGE_3a_liver = subset(Big_liver, Big_liver$Stage == "stage iiia" )
head(STAGE_3a_liver)
STAGE_3b_liver = subset(Big_liver, Big_liver$Stage == "stage iiib" )
head(STAGE_3b_liver)
STAGE_3c_liver = subset(Big_liver, Big_liver$Stage == "stage iiic" )
head(STAGE_3c_liver)
stage_ALL_3_LIVER = rbind (STAGE_3_liver,STAGE_3a_liver, STAGE_3b_liver, STAGE_3c_liver)
stage_ALL_3_LIVER$Stage
STAGE_ALL = rbind(STAGE_1_liver, STAGE_2_liver, stage_ALL_3_LIVER, stage_ALL_4_LIVER)
head(STAGE_ALL)
write.csv(STAGE_ALL, "stage_all.csv")
summary(STAGE_ALL$Stage)
Stage_all_new = read.csv("satage_all_new.csv", sep = ";", header = T)
head(Stage_all_new)
big_fit_survival_time_stage_all = survfit(Surv(as.numeric(Stage_all_new$LivingDays),Stage_all_new$STATUS) ~ Stage_all_new$Stage)
summary(big_fit_survival_time_stage_all)
plot(big_fit_survival_time_stage_all, main= "Kaplan-Meier estimate in different stages", xlab = "time", ylab = "Survival Probability", col = c(1:4))
legend(30,1,c("Stage i", "Stage ii", "Stage iii", "Stage iv"), col = c(1:4), lwd = 0.5)
STAGE_4_liver = subset(Big_liver, Big_liver$Stage == "stage iv" )
head(STAGE_4_liver)
STAGE_4a_liver = subset(Big_liver, Big_liver$Stage == "stage iva" )
head(STAGE_4a_liver)
STAGE_4b_liver = subset(Big_liver, Big_liver$Stage == "stage ivb" )
head(STAGE_4b_liver)
stage_ALL_4_LIVER = rbind (STAGE_4_liver,STAGE_4a_liver, STAGE_4b_liver)
stage_ALL_4_LIVER$Stage
#### Cox regression analysis of stage associated snps:
#### STAGE 1:
cox_reg_10_stage_1_summ.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(STAGE_1_liver$LivingDays),STAGE_1_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(summ_of_gene)
}
stage_1_summ_p_new_survival <- apply(STAGE_1_liver[8:816],2, cox_reg_10_stage_1_summ.it)
cox_reg_10_stage_1_sc.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(STAGE_1_liver$LivingDays),STAGE_1_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(SCTEST_p )
}
stage_1_sc_p_new_survival <- apply(STAGE_1_liver[8:816],2, cox_reg_10_stage_1_sc.it)
stage_1_sc_p_new_survival = as.data.frame(stage_1_sc_p_new_survival)
cox_reg_10_stage_1_w.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(STAGE_1_liver$LivingDays),STAGE_1_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(WALDTEST_p )
}
stage_1_w_p_new_survival <- apply(STAGE_1_liver[8:816],2, cox_reg_10_stage_1_w.it)
stage_1_w_p_new_survival = as.data.frame(stage_1_w_p_new_survival)
cox_reg_10_stage_1_log.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(STAGE_1_liver$LivingDays),STAGE_1_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(LOGTEST_p)
}
stage_1_log_p_new_survival <- apply(STAGE_1_liver[8:816],2, cox_reg_10_stage_1_log.it)
stage_1_log_p_new_survival = as.data.frame(stage_1_log_p_new_survival)
all_P_stage_1 = cbind.data.frame(stage_1_sc_p_new_survival, stage_1_w_p_new_survival, stage_1_log_p_new_survival)
head(all_P_stage_1)
write.csv(all_P_stage_1, "stage_1_transcript_survival.csv")
######################### ADJUST and sort p_values of STAGE_1 Group:
stage_1_to_adjust = read.csv("stage_1_to_adjust.csv", sep = ";", header = T)
head(stage_1_to_adjust)
str(stage_1_to_adjust)
stage_1_to_adjust$sc_Bonferroni = p.adjust(stage_1_to_adjust$stage_1_sc_p_new_survival, method = "bonferroni")
stage_1_to_adjust$wald_Bonferroni = p.adjust(stage_1_to_adjust$stage_1_w_p_new_survival, method = "bonferroni")
stage_1_to_adjust$log_Bonferroni = p.adjust(stage_1_to_adjust$stage_1_log_p_new_survival, method = "bonferroni")
stage_1_to_adjust$sc_FDR = p.adjust(stage_1_to_adjust$stage_1_sc_p_new_survival, method = "fdr")
stage_1_to_adjust$wald_FDR = p.adjust(stage_1_to_adjust$stage_1_w_p_new_survival, method = "fdr")
stage_1_to_adjust$log_fdr = p.adjust(stage_1_to_adjust$stage_1_log_p_new_survival, method = "fdr")
SORTED_stage_1_sc_fdr_success_1 = stage_1_to_adjust[order(stage_1_to_adjust$sc_FDR),]
head(SORTED_stage_1_sc_fdr_success_1, 20)
TOP_stage_1 = data.frame(SORTED_stage_1_sc_fdr_success_1$Trnascript_ID,SORTED_stage_1_sc_fdr_success_1$stage_1_sc_p_new_survival, SORTED_stage_1_sc_fdr_success_1$sc_FDR)
head(TOP_stage_1,20)
#### STAGE 2:
cox_reg_10_stage_2_summ.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(STAGE_2_liver$LivingDays),STAGE_2_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(summ_of_gene)
}
stage_2_summ_p_new_survival <- apply(STAGE_2_liver[8:816],2, cox_reg_10_stage_2_summ.it)
cox_reg_10_stage_2_sc.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(STAGE_2_liver$LivingDays),STAGE_2_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(SCTEST_p )
}
stage_2_sc_p_new_survival <- apply(STAGE_2_liver[8:816],2, cox_reg_10_stage_2_sc.it)
stage_2_sc_p_new_survival = as.data.frame(stage_2_sc_p_new_survival)
cox_reg_10_stage_2_w.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(STAGE_2_liver$LivingDays),STAGE_2_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(WALDTEST_p )
}
stage_2_w_p_new_survival <- apply(STAGE_2_liver[8:816],2, cox_reg_10_stage_2_w.it)
stage_2_w_p_new_survival = as.data.frame(stage_2_w_p_new_survival)
cox_reg_10_stage_2_log.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(STAGE_2_liver$LivingDays),STAGE_2_liver$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(LOGTEST_p)
}
stage_2_log_p_new_survival <- apply(STAGE_2_liver[8:816],2, cox_reg_10_stage_2_log.it)
stage_2_log_p_new_survival = as.data.frame(stage_2_log_p_new_survival)
all_P_stage_2 = cbind.data.frame(stage_2_sc_p_new_survival, stage_2_w_p_new_survival, stage_2_log_p_new_survival)
head(all_P_stage_2)
write.csv(all_P_stage_2, "stage_2_transcript_survival.csv")
######################### ADJUST and sort p_values of STAGE_2 Group:
stage_2_to_adjust = read.csv("Stage_2_to_adjust.csv", sep = ";", header = T)
head(stage_2_to_adjust)
str(stage_2_to_adjust)
stage_2_to_adjust$sc_Bonferroni = p.adjust(stage_2_to_adjust$stage_2_sc_p_new_survival, method = "bonferroni")
stage_2_to_adjust$wald_Bonferroni = p.adjust(stage_2_to_adjust$stage_2_w_p_new_survival, method = "bonferroni")
stage_2_to_adjust$log_Bonferroni = p.adjust(stage_2_to_adjust$stage_2_log_p_new_survival, method = "bonferroni")
stage_2_to_adjust$sc_FDR = p.adjust(stage_2_to_adjust$stage_2_sc_p_new_survival, method = "fdr")
stage_2_to_adjust$wald_FDR = p.adjust(stage_2_to_adjust$stage_2_w_p_new_survival, method = "fdr")
stage_2_to_adjust$log_fdr = p.adjust(stage_2_to_adjust$stage_2_log_p_new_survival, method = "fdr")
SORTED_stage_2_sc_fdr_success_1 = stage_2_to_adjust[order(stage_2_to_adjust$sc_FDR),]
head(SORTED_stage_2_sc_fdr_success_1, 20)
TOP_stage_2 = data.frame(SORTED_stage_2_sc_fdr_success_1$X,SORTED_stage_2_sc_fdr_success_1$stage_2_sc_p_new_survival, SORTED_stage_2_sc_fdr_success_1$sc_FDR)
head(TOP_stage_2,20)
#### STAGE 3:
cox_reg_10_stage_3_summ.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(stage_ALL_3_LIVER$LivingDays),stage_ALL_3_LIVER$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(summ_of_gene)
}
stage_3_summ_p_new_survival <- apply(stage_ALL_3_LIVER[8:816],2, cox_reg_10_stage_3_summ.it)
cox_reg_10_stage_3_sc.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(stage_ALL_3_LIVER$LivingDays),stage_ALL_3_LIVER$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(SCTEST_p )
}
stage_3_sc_p_new_survival <- apply(stage_ALL_3_LIVER[8:816],2, cox_reg_10_stage_3_sc.it)
stage_3_sc_p_new_survival = as.data.frame(stage_3_sc_p_new_survival)
cox_reg_10_stage_3_w.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(stage_ALL_3_LIVER$LivingDays),stage_ALL_3_LIVER$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(WALDTEST_p )
}
stage_3_w_p_new_survival <- apply(stage_ALL_3_LIVER[8:816],2, cox_reg_10_stage_3_w.it)
stage_3_w_p_new_survival = as.data.frame(stage_3_w_p_new_survival)
cox_reg_10_stage_3_log.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(stage_ALL_3_LIVER$LivingDays),stage_ALL_3_LIVER$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(LOGTEST_p)
}
stage_3_log_p_new_survival <- apply(stage_ALL_3_LIVER[8:816],2, cox_reg_10_stage_3_log.it)
stage_3_log_p_new_survival = as.data.frame(stage_3_log_p_new_survival)
all_P_stage_3 = cbind.data.frame(stage_3_sc_p_new_survival, stage_3_w_p_new_survival, stage_3_log_p_new_survival)
head(all_P_stage_3)
write.csv(all_P_stage_3, "stage_3_transcript_survival.csv")
######################### ADJUST and sort p_values of STAGE_3 Group:
stage_3_to_adjust = read.csv("Stage_3_to_adjust.csv", sep = ";", header = T)
head(stage_3_to_adjust)
str(stage_3_to_adjust)
stage_3_to_adjust$sc_Bonferroni = p.adjust(stage_3_to_adjust$stage_3_sc_p_new_survival, method = "bonferroni")
stage_3_to_adjust$wald_Bonferroni = p.adjust(stage_3_to_adjust$stage_3_w_p_new_survival, method = "bonferroni")
stage_3_to_adjust$log_Bonferroni = p.adjust(stage_3_to_adjust$stage_3_log_p_new_survival, method = "bonferroni")
stage_3_to_adjust$sc_FDR = p.adjust(stage_3_to_adjust$stage_3_sc_p_new_survival, method = "fdr")
stage_3_to_adjust$wald_FDR = p.adjust(stage_3_to_adjust$stage_3_w_p_new_survival, method = "fdr")
stage_3_to_adjust$log_fdr = p.adjust(stage_3_to_adjust$stage_3_log_p_new_survival, method = "fdr")
SORTED_stage_3_sc_fdr_success_1 = stage_3_to_adjust[order(stage_3_to_adjust$sc_FDR),]
head(SORTED_stage_3_sc_fdr_success_1, 20)
TOP_stage_3 = data.frame(SORTED_stage_3_sc_fdr_success_1$Transcript_ID,SORTED_stage_3_sc_fdr_success_1$stage_3_sc_p_new_survival, SORTED_stage_3_sc_fdr_success_1$sc_FDR)
head(TOP_stage_3,20)
#### STAGE 4:
head(stage_ALL_4_LIVER)
cox_reg_10_stage_4_summ.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(stage_ALL_4_LIVER$LivingDays),stage_ALL_4_LIVER$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(summ_of_gene)
}
stage_4_summ_p_new_survival <- apply(stage_ALL_4_LIVER[8:816],2, cox_reg_10_stage_4_summ.it)
cox_reg_10_stage_4_sc.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(stage_ALL_4_LIVER$LivingDays),stage_ALL_4_LIVER$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(SCTEST_p )
}
stage_4_sc_p_new_survival <- apply(stage_ALL_4_LIVER[8:816],2, cox_reg_10_stage_4_sc.it)
stage_4_sc_p_new_survival = as.data.frame(stage_4_sc_p_new_survival)
cox_reg_10_stage_4_w.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(stage_ALL_4_LIVER$LivingDays),stage_ALL_4_LIVER$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(WALDTEST_p )
}
stage_4_w_p_new_survival <- apply(stage_ALL_4_LIVER[8:816],2, cox_reg_10_stage_4_w.it)
stage_4_w_p_new_survival = as.data.frame(stage_4_w_p_new_survival)
cox_reg_10_stage_4_log.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(stage_ALL_4_LIVER$LivingDays),stage_ALL_4_LIVER$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(LOGTEST_p)
}
stage_4_log_p_new_survival <- apply(stage_ALL_4_LIVER[8:816],2, cox_reg_10_stage_4_log.it)
stage_4_log_p_new_survival = as.data.frame(stage_4_log_p_new_survival)
all_P_stage_4 = cbind.data.frame(stage_4_sc_p_new_survival, stage_4_w_p_new_survival, stage_4_log_p_new_survival)
head(all_P_stage_4)
write.csv(all_P_stage_4, "stage_4_transcript_survival.csv")
######################### ADJUST and sort p_values of STAGE_4 Group:
stage_4_to_adjust = read.csv("Stage_4_to_adjust.csv", sep = ";", header = T)
head(stage_4_to_adjust)
str(stage_4_to_adjust)
stage_4_to_adjust$sc_Bonferroni = p.adjust(stage_4_to_adjust$stage_4_sc_p_new_survival, method = "bonferroni")
stage_4_to_adjust$wald_Bonferroni = p.adjust(stage_4_to_adjust$stage_4_w_p_new_survival, method = "bonferroni")
stage_4_to_adjust$log_Bonferroni = p.adjust(stage_4_to_adjust$stage_4_log_p_new_survival, method = "bonferroni")
stage_4_to_adjust$sc_FDR = p.adjust(stage_4_to_adjust$stage_4_sc_p_new_survival, method = "fdr")
stage_4_to_adjust$wald_FDR = p.adjust(stage_4_to_adjust$stage_4_w_p_new_survival, method = "fdr")
stage_4_to_adjust$log_fdr = p.adjust(stage_4_to_adjust$stage_4_log_p_new_survival, method = "fdr")
SORTED_stage_4_sc_fdr_success_1 = stage_4_to_adjust[order(stage_4_to_adjust$sc_FDR),]
head(SORTED_stage_4_sc_fdr_success_1, 20)
TOP_stage_4 = data.frame(SORTED_stage_4_sc_fdr_success_1$Transcript_ID,SORTED_stage_4_sc_fdr_success_1$stage_4_sc_p_new_survival, SORTED_stage_4_sc_fdr_success_1$sc_FDR)
head(TOP_stage_4,20)

Big_liver_mean_tran = read.csv("big_liver_transcript_means .csv", sep=";", header=T)
head(Big_liver_mean_tran)
str(Big_liver_mean_tran)
transcript_express_mean = read.csv("transcript_mean_express.csv", sep = ";", header = T)
head(transcript_express_mean)
library("plyr")
TOP_100_liver = head(TOP_sig_10,100)
head(TOP_100_liver)
write.csv(TOP_100_liver, "TOP_100_liver.csv")
TOP_20_all_cov = read.csv("TOP_20_all_cov_get_express.csv", sep = ";", header = T)
head(TOP_20_all_cov)
TOP_20_liver_express= join(TOP_20_all_cov,transcript_express_mean, by = "Transcript_ID" )
TOP_20_liver_express
write.csv(TOP_20_liver_express, "table_top_all_cov.csv")
plot(TOP_20_liver_express$mean_expression,TOP_20_liver_express$sc_FDR )
TOP_100_all_cov = read.csv("top_100_need_express.csv", sep = ";", header = T)
head(TOP_100_all_cov)
TOP_100_liver_express= join(TOP_100_all_cov,transcript_express_mean, by = "Transcript_ID" )
head(TOP_100_liver_express)
plot(TOP_100_liver_express$sctest_p_all_cov,TOP_100_liver_express$sc_FDR)

TOP_100_liver_express$sctest_p_all_cov <- as.numeric(TOP_100_liver_express$sctest_p_all_cov) 
TOP_100_liver_express$sctest_all_cov_FDR<- as.numeric(TOP_100_liver_express$sctest_all_cov_FDR)
TOP_100_liver_express$mean_expression<- as.numeric(TOP_100_liver_express$mean_expression)
x <- TOP_100_liver_express$sctest_all_cov_FDR 
y <- TOP_100_liver_express$mean_expression 
plot(x, y, xlab="FDR_corrected P value", ylab="Transcript mean expression" ) 


#head(TOP_AGE)
colnames(TOP_AGE)  = c("Transcript_ID", "sc_age_P_value", "sc_age_FDR")
TOP_age_liver_express= join(TOP_AGE,transcript_express_mean, by = "Transcript_ID" )
TOP_age_liver_express
#write.csv(TOP_age_liver_express, "table_top_age.csv")
#head(TOP_RACE)
colnames(TOP_RACE)  = c("Transcript_ID", "sc_race_P_value", "sc_race_FDR")
TOP_RACE_liver_express= join(TOP_RACE,transcript_express_mean, by = "Transcript_ID" )
TOP_RACE_liver_express
#write.csv(TOP_RACE_liver_express, "table_top_age.csv")
#head(TOP_stage_1)
colnames(TOP_stage_1)  = c("Transcript_ID", "sc_stage_1_P_value", "sc_stage_1_FDR")
TOP_stage_1_liver_express= join(TOP_stage_1,transcript_express_mean, by = "Transcript_ID" )
TOP_stage_1_liver_express
#write.csv(TOP_stage_1_liver_express, "table_top_stage_1.csv")
#head(TOP_stage_2)
colnames(TOP_stage_2)  = c("Transcript_ID", "sc_stage_2_P_value", "sc_stage_2_FDR")
TOP_stage_2_liver_express= join(TOP_stage_2,transcript_express_mean, by = "Transcript_ID" )
TOP_stage_2_liver_express
#write.csv(TOP_stage_2_liver_express, "table_top_stage_2.csv")
#head(TOP_stage_3)
colnames(TOP_stage_3)  = c("Transcript_ID", "sc_stage_3_P_value", "sc_stage_2_FDR")
TOP_stage_3_liver_express= join(TOP_stage_3,transcript_express_mean, by = "Transcript_ID" )
TOP_stage_3_liver_express
#write.csv(TOP_stage_3_liver_express, "table_top_stage_3.csv")
#head(TOP_adults)
colnames(TOP_adults)  = c("Transcript_ID", "sc_adults_P_value", "sc_adults_FDR")
TOP_adults_liver_express= join(TOP_adults,transcript_express_mean, by = "Transcript_ID" )
TOP_adults_liver_express
write.csv(TOP_adults_liver_express, "table_top_stage_adults.csv")
#head(TOP_youth)
colnames(TOP_youth)  = c("Transcript_ID", "sc_youth_P_value", "sc_youth_FDR")
TOP_youth_liver_express= join(TOP_youth,transcript_express_mean, by = "Transcript_ID" )
TOP_youth_liver_express
#write.csv(TOP_youth_liver_express, "table_top_youth.csv")
#head(TOP_old)
colnames(TOP_old)  = c("Transcript_ID", "sc_old_P_value", "sc_old_FDR")
TOP_old_liver_express= join(TOP_old,transcript_express_mean, by = "Transcript_ID" )
TOP_old_liver_express
#write.csv(TOP_old_liver_express, "table_top_old.csv")
#head(TOP_asian)
colnames(TOP_asian)  = c("Transcript_ID", "sc_asian_P_value", "sc_asian_FDR")
TOP_asian_liver_express= join(TOP_asian,transcript_express_mean, by = "Transcript_ID" )
TOP_asian_liver_express
#write.csv(TOP_asian_liver_express, "table_top_asian.csv")
#head(TOP_white)
colnames(TOP_white)  = c("Transcript_ID", "sc_white_P_value", "sc_white_FDR")
TOP_white_liver_express= join(TOP_white,transcript_express_mean, by = "Transcript_ID" )
TOP_white_liver_express
#write.csv(TOP_white_liver_express, "table_top_white.csv")
#head(TOP_AFRO)
colnames(TOP_AFRO)  = c("Transcript_ID", "sc_AFRO_P_value", "sc_AFRO_FDR")
TOP_AFRO_liver_express= join(TOP_AFRO,transcript_express_mean, by = "Transcript_ID" )
TOP_AFRO_liver_express
#write.csv(TOP_AFRO_liver_express, "table_top_AFRO.csv")



plot(TOP_age_liver_express$mean_expression,TOP_age_liver_express$sc_FDR )
TOP_age_liver_express$sc_age_P_value <- as.numeric(TOP_age_liver_express$sc_age_P_value) 
TOP_age_liver_express$sc_age_FDR<- as.numeric(TOP_age_liver_express$sc_age_FDR)
TOP_age_liver_express$mean_expression<- as.numeric(TOP_age_liver_express$mean_expression)
x <- TOP_age_liver_express$sc_age_FDR 
y <- TOP_age_liver_express$mean_expression
plot(x, y, xlab="FDR_corrected P value", ylab="Transcript mean expression", main = "AGE_associated transcripts" ) 


############### SEX _associated Transcripts:
summary(Big_liver$Gender)
big_liver_FEMALES = subset(Big_liver, Big_liver$Gender== "female")
head(big_liver_FEMALES)
big_liver_MALES = subset(Big_liver, Big_liver$Gender== "male")
head(big_liver_MALES)
##### MALES:
cox_reg_10_MALES_summ.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(big_liver_MALES$LivingDays),big_liver_MALES$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(summ_of_gene)
}
MALES_summ_p_new_survival <- apply(big_liver_MALES[8:816],2, cox_reg_10_MALES_summ.it)
cox_reg_10_MALES_sc.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(big_liver_MALES$LivingDays),big_liver_MALES$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(SCTEST_p )
}
MALES_sc_p_new_survival <- apply(big_liver_MALES[8:816],2, cox_reg_10_MALES_sc.it)
MALES_sc_p_new_survival = as.data.frame(MALES_sc_p_new_survival)
cox_reg_10_MALES_w.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(big_liver_MALES$LivingDays),big_liver_MALES$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(WALDTEST_p )
}
MALES_w_p_new_survival <- apply(big_liver_MALES[8:816],2, cox_reg_10_MALES_w.it)
MALES_w_p_new_survival = as.data.frame(MALES_w_p_new_survival)
cox_reg_10_MALES_log.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(big_liver_MALES$LivingDays),big_liver_MALES$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(LOGTEST_p)
}
MALES_log_p_new_survival <- apply(big_liver_MALES[8:816],2, cox_reg_10_MALES_log.it)
MALES_log_p_new_survival = as.data.frame(MALES_log_p_new_survival)
all_P_MALES = cbind.data.frame(MALES_sc_p_new_survival, MALES_w_p_new_survival, MALES_log_p_new_survival)
head(all_P_MALES)
write.csv(all_P_MALES, "MALES_transcript_survival.csv")
##### FEMALES:
cox_reg_10_FEMALES_summ.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(big_liver_FEMALES$LivingDays),big_liver_FEMALES$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(summ_of_gene)
}
FEMALES_summ_p_new_survival <- apply(big_liver_FEMALES[8:816],2, cox_reg_10_FEMALES_summ.it)
cox_reg_10_FEMALES_sc.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(big_liver_FEMALES$LivingDays),big_liver_FEMALES$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(SCTEST_p )
}
FEMALES_sc_p_new_survival <- apply(big_liver_FEMALES[8:816],2, cox_reg_10_FEMALES_sc.it)
FEMALES_sc_p_new_survival = as.data.frame(FEMALES_sc_p_new_survival)
cox_reg_10_FEMALES_w.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(big_liver_FEMALES$LivingDays),big_liver_FEMALES$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(WALDTEST_p )
}
FEMALES_w_p_new_survival <- apply(big_liver_FEMALES[8:816],2, cox_reg_10_FEMALES_w.it)
FEMALES_w_p_new_survival = as.data.frame(FEMALES_w_p_new_survival)
cox_reg_10_FEMALES_log.it <- function(x) {
  cox_transcript = coxph(Surv(as.numeric(big_liver_FEMALES$LivingDays),big_liver_FEMALES$STATUS) ~ as.numeric(x))
  summ_of_gene <- summary(cox_transcript)
  SCTEST_p <-summ_of_gene$sctest[["pvalue"]]
  WALDTEST_p <- summ_of_gene$waldtest[["pvalue"]]
  LOGTEST_p <- summ_of_gene$logtest[["pvalue"]]
  return(LOGTEST_p)
}
FEMALES_log_p_new_survival <- apply(big_liver_FEMALES[8:816],2, cox_reg_10_FEMALES_log.it)
FEMALES_log_p_new_survival = as.data.frame(FEMALES_log_p_new_survival)
all_P_FEMALES = cbind.data.frame(FEMALES_sc_p_new_survival, FEMALES_w_p_new_survival, FEMALES_log_p_new_survival)
head(all_P_FEMALES)
write.csv(all_P_FEMALES, "FEMALES_transcript_survival.csv")
#####adjust and sort MALES:
MALES_to_adjust = read.csv("males_to_adjust.csv", sep = ";", header = T)
head(MALES_to_adjust)
str(MALES_to_adjust)
MALES_to_adjust$sc_Bonferroni = p.adjust(MALES_to_adjust$MALES_sc_p_new_survival, method = "bonferroni")
MALES_to_adjust$wald_Bonferroni = p.adjust(MALES_to_adjust$MALES_w_p_new_survival, method = "bonferroni")
MALES_to_adjust$log_Bonferroni = p.adjust(MALES_to_adjust$MALES_log_p_new_survival, method = "bonferroni")
MALES_to_adjust$sc_FDR = p.adjust(MALES_to_adjust$MALES_sc_p_new_survival, method = "fdr")
MALES_to_adjust$wald_FDR = p.adjust(MALES_to_adjust$MALES_w_p_new_survival, method = "fdr")
MALES_to_adjust$log_fdr = p.adjust(MALES_to_adjust$MALES_sc_p_new_survival, method = "fdr")
SORTED_MALES_sc_fdr_success_1 = MALES_to_adjust[order(MALES_to_adjust$MALES_sc_p_new_survival),]
head(SORTED_MALES_sc_fdr_success_1, 20)
TOP_MALES = data.frame(SORTED_MALES_sc_fdr_success_1$Transcipt_ID,SORTED_MALES_sc_fdr_success_1$MALES_sc_p_new_survival, SORTED_MALES_sc_fdr_success_1$sc_FDR)
head(TOP_MALES,20)
#####adjust and sort FEMALES:
FEMALES_to_adjust = read.csv("females_to_adjust.csv", sep = ";", header = T)
head(FEMALES_to_adjust)
str(FEMALES_to_adjust)
FEMALES_to_adjust$sc_Bonferroni = p.adjust(FEMALES_to_adjust$FEMALES_sc_p_new_survival, method = "bonferroni")
FEMALES_to_adjust$wald_Bonferroni = p.adjust(FEMALES_to_adjust$FEMALES_w_p_new_survival, method = "bonferroni")
FEMALES_to_adjust$log_Bonferroni = p.adjust(FEMALES_to_adjust$FEMALES_log_p_new_survival, method = "bonferroni")
FEMALES_to_adjust$sc_FDR = p.adjust(FEMALES_to_adjust$FEMALES_sc_p_new_survival, method = "fdr")
FEMALES_to_adjust$wald_FDR = p.adjust(FEMALES_to_adjust$FEMALES_w_p_new_survival, method = "fdr")
FEMALES_to_adjust$log_fdr = p.adjust(FEMALES_to_adjust$FEMALES_sc_p_new_survival, method = "fdr")
SORTED_FEMALES_sc_fdr_success_1 = FEMALES_to_adjust[order(FEMALES_to_adjust$FEMALES_sc_p_new_survival),]
head(SORTED_FEMALES_sc_fdr_success_1, 20)
TOP_FEMALES = data.frame(SORTED_FEMALES_sc_fdr_success_1$Transcript_ID,SORTED_FEMALES_sc_fdr_success_1$FEMALES_sc_p_new_survival, SORTED_FEMALES_sc_fdr_success_1$sc_FDR)
TOP_FEMALES
colnames(TOP_MALES)  = c("Transcript_ID", "sc_MALES_P_value", "sc_MALES_FDR")
TOP_MALES_liver_express= join(TOP_MALES,transcript_express_mean, by = "Transcript_ID" )
TOP_MALES_liver_express
write.csv(TOP_MALES_liver_express, "table_top_MALES.csv")
colnames(TOP_FEMALES)  = c("Transcript_ID", "sc_MALES_P_value", "sc_MALES_FDR")
TOP_FEMALES_liver_express= join(TOP_FEMALES,transcript_express_mean, by = "Transcript_ID" )
TOP_FEMALES_liver_express
write.csv(TOP_FEMALES_liver_express, "table_top_FEMALES.csv")
