library(readxl)
library(dplyr)
library(ggplot2)
library(tidyr)
install.packages("compareDF")
library(compareDF)

##LOAD THE DATA
defense <- read_excel('cyclonesFootball2020.xlsx', sheet='Defensive')
str(defense)

offensive <- read_excel('cyclonesFootball2020.xlsx', sheet='Offensive')
str(offensive)

biography <- read_excel('cyclonesFootball2020.xlsx', sheet='Biography')
str(biography)

#PART ONE: CLEANING THE DATA
#1
defense1 <- defense
offensive1 <- offensive
biography1 <- biography

defense1$Name <-as.factor(defense1$Name)
defense1$Opponent_Opponent <-as.factor(defense1$Opponent_Opponent)

offensive1$Name <-as.factor(offensive1$Name)
offensive1$Opponent_Opponent <-as.factor(offensive1$Opponent_Opponent)

biography1$Name <-as.factor(biography1$Name)


#2
defense1 <- defense1 %>%
  mutate(across(Tackles_Solo:Pass_PB, as.numeric))

offensive1 <- offensive1 %>%
  mutate(across(Receiving_REC:Passing_INT, as.numeric))

biography1 <- biography1 %>%
  mutate(Weight = as.numeric(Weight))

#3
biography2 <- biography1

biography2 <- biography2 %>%
  separate(Height,c('feet', 'inches'), sep = '-', convert = TRUE, remove = FALSE) %>%
  mutate(feet = 12*feet + inches) %>%
  select(-inches)
    ##Here I used feet and inches as a unit of measurement

biography2 <- biography2 %>%
  mutate(Height = as.numeric(feet))

defClean <- defense1
offClean <- offensive1
bioClean <- biography2

str(defClean)
str(offClean)
str(bioClean)

#PART TWO: TIDYING THE DATA
#1
offClean1 <- offClean %>%
  pivot_longer(Receiving_REC:Receiving_TD, names_to='receiving_stat', values_to='score')
View(offClean1)

offClean1 <- offClean1 %>%
  pivot_longer(Rushing_ATT:Rushing_TD, names_to='rushing_stat', values_to='score1')

offClean1 <- offClean1 %>% rename(Passing_CMPATT = `Passing_CMP-ATT`)

offClean1 <- offClean1 %>%
  pivot_longer(Passing_CMPATT:Passing_INT, names_to='passing_stat', values_to='score2')

#2
ggplot(offClean1, aes(x=score)) + geom_histogram() + facet_wrap(~receiving_stat, scales='free_y')
ggplot(offClean1, aes(x=score1)) + geom_histogram() + facet_wrap(~rushing_stat, scales='free_y')
ggplot(offClean1, aes(x=score2)) + geom_histogram() + facet_wrap(~passing_stat, scales='free_y')

######3
offClean2 <- offClean1

offClean2  <- offClean2  %>%
  filter(Opponent_Opponent %in% c('Oregon') & receiving_stat == 'score')

#4
dat <- bioClean %>%
  separate(Hometown, c('City', 'State'), sep=',')
str(dat)

#5
player_state <- dat %>% count(State, sort = TRUE)
player_state


#PART THREE: JOINING DATA FRAMES
#1
ggplot(player_state, aes(x=State, y=n)) + geom_point()

#2
brock_performance <-  offensive1  %>%
  filter(Name %in% c('Purdy, Brock'))
View(brock_performance)
##QUICK GOOGLE SEARCH SHOWS US IN 2020
##ISU WON AGAINST:TCU, OKLAHOMA, TEXAS TECH, KANSAS, BAYLOR, KANSAS STATE, TEXAS, WEST VIRGINIA, OREGON #
##ISU LOST AGAINST: LOUSINA, OKLAHOMA STATE,  OKLAHOMA  so  #1, #5 and #11 for our table
 
mean(brock_performance$Passing_YDS)
#He averaged 229 passing yards in 12 game

table(brock_performance$Opponent_Opponent , brock_performance$Passing_YDS)
#We can see that he had 145yd in Lousina game, 162yd in Oklahoma State which is lower than his average- THis could be an explanation why ISU has lost


#11 which is Oklahoma game is an exception because he had 322 yards so let's look at his interception numbers because interceptions are negative for offense and huge advantage for opposite team
brock_performance$Passing_INT
mean(brock_performance$Passing_INT)
#We can see that he threw 3 interceptions that game which is higher than his average of 0.75 so that could be an explanation why they lost.
#The other time he threw 3 interceptions, ISU has won because he balanced that with 3 Passing TD and 55 Rushing yards which was his second best yardage for this season.


#3
#lets clear the data quick
defense19 <- read_excel('cyclonesFootball2019.xlsx', sheet='Defensive')
offensive19 <- read_excel('cyclonesFootball2019.xlsx', sheet='Offensive')


defense19$Name <-as.factor(defense19$Name)
defense19$Opponent_Opponent <-as.factor(defense19$Opponent_Opponent)

offensive19$Name <-as.factor(offensive19$Name)
offensive19$Opponent_Opponent <-as.factor(offensive19$Opponent_Opponent)


#now lets compare
defense20 <- defense1
offensive20 <- offensive1

comparetableof_19and20 = compare_df(offensive19, offensive20, c("Name"))
compare_offense <- comparetableof_19and20$comparison_df

comparetabledef_19and20 = compare_df(defense19, defense20, c("Name"))
compare_defense <- comparetabledef_19and20$comparison_df






