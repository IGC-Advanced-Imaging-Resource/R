data <- read.csv("Image.csv", header=T)
Nuclei_Count<-tapply(data$Count_Nuclei, data$FileName_EBFP2, sum, na.rm = T)
PositiveNuclei_Count<-tapply(data$Count_PositiveNuclei, data$FileName_EBFP2, sum, na.rm = T)
Images <- aggregate(cbind(Count_Nuclei = !is.na(Count_Nuclei))~FileName_EBFP2, data, sum)
Flagged_images <- aggregate(cbind(Count_Nuclei = is.na(Count_Nuclei))~FileName_EBFP2, data, sum)

table <- cbind(Images, Flagged_images[,2], Nuclei_Count, PositiveNuclei_Count)
names(table) <- c("Filename", "Analysed Images", "Flagged images", "Nuclei", "PositiveNuclei")

write.csv(table, file = "CountsPerPlate.csv")

