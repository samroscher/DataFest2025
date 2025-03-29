library(stringr)
library(dplyr)
library(ggplot2)
library(corrplot)
library(gridExtra)

municipal_orig <- read.csv("C:/Users/yanchuzhang/Desktop/datafest 2025/working data/raw/municipal.csv", encoding = "UTF-8")

set.seed(2025)
municipal <- municipal_orig[,c(2,4,5,6,9,10,11,12,13,16,20,24,28,32,36,41,42,51,52,54,63,69,70,73,74,89,78,81,83,84,85,86)]
attach(municipal)
municipal <- na.omit(municipal)
municipal$GEN <- as.factor(municipal$GEN)
municipal$lan_name <- as.factor(municipal$lan_name)
municipal$east_west <- as.factor(municipal$east_west)
municipal$AGS <- str_pad(as.character(municipal$AGS), width = 8, pad = "0")
str(municipal)
summary(municipal)
# write.csv(municipal, "C:/Users/yanchuzhang/Desktop/datafest 2025/working data/raw/municipal_clean.csv", row.names = FALSE, fileEncoding = "UTF-8")

#----------------------------------

party_orig <- read.csv2("C:/Users/yanchuzhang/Desktop/datafest 2025/working data/raw/political result.csv")
party <- party_orig[,c(2:dim(party_orig)[2])]
party <- na.omit(party)
party <- party[party$Sieger != "#N/A",]

party$CDU.CSU <- as.numeric(gsub(",", ".", party$CDU.CSU))
party$SPD <- as.numeric(gsub(",", ".", party$SPD))
party$AFD <- as.numeric(gsub(",", ".", party$AFD))
party$FDP <- as.numeric(gsub(",", ".", party$FDP))
party$DIE.LINKE <- as.numeric(gsub(",", ".", party$DIE.LINKE))
party$GRÜNE <- as.numeric(gsub(",", ".", party$GRÜNE))
party$Sieger <- as.factor(party$Sieger)

party$Landname <- as.factor(party$Landname)
party$Gemeindename <- as.factor(party$Gemeindename)
party$AGS <- str_pad(as.character(party$AGS), width = 8, pad = "0")
party$AGS <- as.factor(party$AGS)

str(party)
summary(party)

#----------------------------------------

party_result <- merge(municipal, party, by = "AGS", all.x = TRUE)
party_result <- party_result %>%
  filter(!is.na(Sieger)) %>%
  mutate(right_extremism = ifelse(Sieger == "AFD", 1, 0))

party_result$right_extremism <- as.factor(party_result$right_extremism) 

str(party_result)

attach(party_result)

#-------------------------------------

party_result_for_plot <- party_result
party_result_for_plot$right_extremism <- ifelse(right_extremism == "1", 1, 0)
party_result_for_plot$east_west <- ifelse(east_west == "East", 1, 0)

cor_matrix <- cor(party_result_for_plot[,c(27:32,42)])

corrplot(cor_matrix, method = "color", type = "upper", tl.cex = 0.7)


#-----------------------

plz_matching_orig <- read.csv("C:/Users/yanchuzhang/Desktop/datafest 2025/working data/raw/zuordnung_plz_ort.csv")
plz_matching <- plz_matching_orig[,c(2,4)]
colnames(plz_matching)[colnames(plz_matching) == "ags"] <- "AGS"
plz_matching$AGS <- str_pad(as.character(plz_matching$AGS), width = 8, pad = "0")
plz_matching$plz <- str_pad(as.character(plz_matching$plz), width = 5, pad = "0")


#-------------------

merged <- party_result
merged <- merge(merged, plz_matching, by = "AGS", all.x = TRUE)
merged <- merged %>% relocate(plz, .after = AGS)

#----------------------------
cross_HK <- read.csv("C:/Users/yanchuzhang/Desktop/datafest 2025/working data/raw/cross_section/CampusFile_HK_2023.csv")
cross_WK <- read.csv("C:/Users/yanchuzhang/Desktop/datafest 2025/working data/raw/cross_section/CampusFile_WK_2023.csv")
cross_WM <- read.csv("C:/Users/yanchuzhang/Desktop/datafest 2025/working data/raw/cross_section/CampusFile_WM_2023.csv")

cross_HK_reduced <- cross_HK[,c(1:17, 25:39, 70)]
cross_WK_reduced <- cross_WK[,c(1:3,5:18,26:40,71)]
cross_WM_reduced <- cross_WM[,c(1:17, 24:38,69)]

cross_HK_reduced <- cross_HK_reduced[cross_HK_reduced$plz != "Other missing",]
cross_WK_reduced <- cross_WK_reduced[cross_WK_reduced$plz != "Other missing",]
cross_WM_reduced <- cross_WM_reduced[cross_WM_reduced$plz != "Other missing",]

cross_HK_reduced$plz <- str_pad(as.character(cross_HK_reduced$plz), width = 5, pad = "0")
cross_WK_reduced$plz <- str_pad(as.character(cross_WK_reduced$plz), width = 5, pad = "0")
cross_WM_reduced$plz <- str_pad(as.character(cross_WM_reduced$plz), width = 5, pad = "0")

merged_muni_cross_HK_temp <- merge(cross_HK_reduced, merged, by = "plz", all.x = TRUE)
merged_muni_cross_WK_temp <- merge(cross_WK_reduced, merged, by = "plz", all.x = TRUE)
merged_muni_cross_WM_temp <- merge(cross_WM_reduced, merged, by = "plz", all.x = TRUE)

merged_muni_cross_HK <- merged_muni_cross_HK_temp[is.na(merged_muni_cross_HK$AGS)==FALSE,]
merged_muni_cross_WK <- merged_muni_cross_WK_temp[is.na(merged_muni_cross_WK$AGS)==FALSE,]
merged_muni_cross_WM <- merged_muni_cross_WM_temp[is.na(merged_muni_cross_WM$AGS)==FALSE,]

write.csv(merged_muni_cross_HK, "C:/Users/yanchuzhang/Desktop/datafest 2025/working data/raw/merged_muni_cross_HK.csv", row.names = FALSE, fileEncoding = "UTF-8")
write.csv(merged_muni_cross_WK, "C:/Users/yanchuzhang/Desktop/datafest 2025/working data/raw/merged_muni_cross_WK.csv", row.names = FALSE, fileEncoding = "UTF-8")
write.csv(merged_muni_cross_WM, "C:/Users/yanchuzhang/Desktop/datafest 2025/working data/raw/merged_muni_cross_WM.csv", row.names = FALSE, fileEncoding = "UTF-8")

