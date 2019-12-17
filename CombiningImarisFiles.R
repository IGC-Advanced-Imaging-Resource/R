#  Script for Jono for combining exported Imaris statistics files
#  In future should clean up, maybe add some output and distribute
#  Needed currently especially due to bug in Imaris which has been reported

# Tell R where the directory of statistics is and where you want to save them
inDir <- "U:/Datastore/IGMM/millar-lab/Jono/Experiment stats/spine classification/m5/m5e1"
outDir <- "U:/Datastore/IGMM/millar-lab/Jono/Experiment stats/spine classification/m5/m5e1_combined"

# Get list of directory names. List.dirs also lists the parent directory so second line removes that first element
dirNames <- list.dirs(inDir)
dirNames <- dirNames[-1]

# Extract the final folder of the path and then remove the '_Statistics' part of the directory name to be left with the image name only to be neater. 
# This will be used to make sure the image name is included in the combined CSVs

imgNames <- vector()

for (i in 1:length(dirNames)){
  parts <- strsplit(dirNames[i],"/")
  parts <- unlist(parts)
  current <- parts[length(parts)]
  imgNames[i] <- gsub("_Statistics", "" ,current)
}

for (image in 1:length(dirNames)){
	files <- list.files(dirNames[image])
	no <- length(files)
 	cat('\n', imgNames[image] , ' has ', no, 'files in it')
}


# Similar to last part, taking the first directory of statistics files and removing the image name and stripping the extension so just left with the statistic name

statNames <- vector()

for (stat in 1:length(files)){
  parts <- strsplit(files[stat],"/|.csv")
  parts <- unlist(parts)
  currentFile <- parts[length(parts)]
  toSub <- paste0(imgNames[1], "_")
  statNames[stat] <- gsub(toSub, "", currentFile)
}

# Make an empty list to fill with the CSV paths
CSVs <- list() 

# Each list element is named the corresponding image name, inside each list element is a list of the files found in that images respective directory
for (j in 1:length(dirNames)){
  CSVs[[j]] = list.files(dirNames[j], full.names = T)
  names(CSVs)[[j]] = imgNames[j]
}

# Make an empty list to fill with the combined tables. Each list should contain one combined table for one statistic
# The tables will have an extra column with the image name the row originated from
csv_comb = list()

# Time for the real bread and butter.
# Nested for loops. Outer loops through each list elemtent (and thus statistic) and inner loops through each directory (and thus image name).
# CSV_comb will become a list of lists which is A LOT but this is the way it works. Try and go back and make it a dataframe of matrices at some point.

for(file in 1:length(files)){
  csv_comb[[file]] = list()     # Create list for the current element of CSV_comb
  
  # Initiate loop to go through folders to get the current file within each and reading the csv in
  # While doing this also create the image name column which ia filled with the current image name

  for(folder in 1:length(dirNames)){   
    tmp = read.csv(toString(CSVs[[folder]][[file]]), skip=3, header = T)
    tmp$ImageName = imgNames[folder]
    csv_comb[[file]][[folder]] = tmp
  }
  
  # Binding together the statistics for each image into the same table
  csv_comb[[file]] = do.call("rbind", csv_comb[[file]])
}

# Create write the filenames out into output directory
for (table in 1:length(files)){
  file = names(csv_comb)[table]
  fileName = paste0(outDir, "/", statNames[table],".csv")
  write.csv(csv_comb[[table]], file = fileName)
}

