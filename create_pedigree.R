#This function will create a pedigree from the flastall2 table in the cloud version of the krsp database.  The pedigree will be called 'krsp_pedigree'.  flastall2 contains all squirrels born in the study (including those not tagged).
#The data can be further filtered as needed.

# Since the pedigree is very large the pedigree summary statistics can take a VERY long time to calculate.  These steps are only needed to provide summary data on the pedigree.  
# They are currently commented out to avoid running accidentally.  They can be un-commented as needed.

# Install packages as needed
# install.packages("tidyverse")
# install.packages("pedantics")

# Install krsp package from GitHub
# install.packages("devtools")
# library (devtools)
# devtools::install_github("KluaneRedSquirrelProject/krsp")

library (tidyverse)
library (krsp)
library (pedantics)
select = dplyr::select # necessary as MASS also has a select function

# Connecting to the cloud database
con <- krsp_connect (host = "krsp.cepb5cjvqban.us-east-2.rds.amazonaws.com",
                     dbname ="krsp",
                     username = Sys.getenv("krsp_user"),
                     password = Sys.getenv("krsp_password")
)



# Create pedigree from flastall2
krsp_pedigree<-tbl(con, "flastall2") %>% 
  select(id=squirrel_id, dam=dam_id, sire=sire_id) %>% 
  filter(!(is.na(id))) %>% 
  group_by(id) %>% 
  collect() %>% 
  filter(row_number() == 1) %>% 
  ungroup()



#  There were 4 errors discovered in January 2019 when McAdam wrote this code to bring in the cross-foster data.  These will be fixed manually here, 
#  but will be corrected within the juvenile table once the annual data cleanup is done for the 2019 season.  These juveniles did not survive the summer
#  so these errors in dam assignment have not had large issues for previous pedigree analyses
krsp_pedigree <- krsp_pedigree %>% 
  mutate (dam = ifelse(id==4367, 4608, dam),
          dam = ifelse(id==3934, 4682, dam),
          dam = ifelse(id==4249, 4425, dam),
          dam = ifelse(id==4034, 4125, dam))

 krsp_pedigree = fixPedigree(krsp_pedigree)
# NOTE that fixPedigree does not change the id's it just changes the order of the records
# so that maternal records occur before the first records of their offspring.


#Summaries:

# krspPedigreeSummary<-pedigreeStats(krsp_pedigree, graphicalReport="n")
# pedStatSummary(krspPedigreeSummary)

#drawPedigree(krsp_pedigree)