#-------------------------------------------------------------------------------
# Assignment - Practical Machine Learning
# Data Science Specialisation
#-------------------------------------------------------------------------------

#The goal of your project is to predict the manner in which they did the exercise. 
#This is the "classe" variable in the training set. You may use any of the other 
#variables to predict with. You should create a report describing how you built 
#your model, how you used cross validation, what you think the expected out of 
#sample error is, and why you made the choices you did. You will also use your 
#prediction model to predict 20 different test cases. 

#-------------------------------------------------------------------------------
# Load necessary R libraries
#-------------------------------------------------------------------------------

library("caret")
library("ggplot2")
library("lubridate")
library("corrplot")
library("dplyr")
library("randomForest")
library("reshape")

#-------------------------------------------------------------------------------
# Read data
#-------------------------------------------------------------------------------
url1 <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"
url2 <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"

download.file(url1, destfile = "training_set.csv", method="curl")
download.file(url2, destfile = "test_set.csv", method="curl")

train.dat <- read.csv(  "training_set.csv", 
                        na.strings= c("NA",""," "), stringsAsFactors = FALSE)

test.dat <- read.csv( "test_set.csv", 
                      na.strings= c("NA",""," "), stringsAsFactors = FALSE)

#-------------------------------------------------------------------------------
# Prepare data
#-------------------------------------------------------------------------------
train.dat$classe <- as.factor(train.dat$classe)

clean_chars <- function(df, name){
  # Function that finds "DIV/0!" characters, replaces them by Inf
  # and turns column into numeric
  div0 <- which( df[,name] == "#DIV/0!")
  df[div0, name] <- Inf
  df[, name] <- as.numeric(df[,name])
  return(df)
}

# Check for DIV0
faulty_cols <- which(apply(train.dat, 2, function(x) any(grepl("DIV/0", x))))
faulty_cols <- as.list(faulty_cols)

# Pass this to clean_chars
for(i in 1:length(faulty_cols)){
  train.dat <- clean_chars(train.dat, faulty_cols[[i]])
}

faulty_cols <- which(apply(test.dat, 2, function(x) any(grepl("DIV/0", x))))
# no faulty cols in test.dat

# Remove columns with NAs
train.dat_NAs <- apply(train.dat, 2, function(x) { sum( is.na(x) ) })
train.dat_cl <- train.dat[, which( train.dat_NAs == 0 )]

# Now we want to make sure we have same columns in test set
# and of same type
cols_train <- names(train.dat_cl)
cols_train <- cols_train[-length(train.dat_cl)] #removes classe

test.dat_cl <- test.dat[ ,cols_train]

convert.type <- function(obj,types){
  for (i in 1:length(obj)){
    FUN <- switch( types[[i]], 
                   integer = as.integer, 
                   character = as.character, 
                   numeric = as.numeric, 
                   factor = as.factor)
    obj[,i] <- FUN(obj[,i])
  }
  obj
}

# make col types of test and train sets match
types <- sapply(train.dat_cl[1,],class)
types <- as.list(types)

test.dat_cl <- convert.type(test.dat_cl, types)

# Finally parse datetime
train.dat_cl$cvtd_timestamp <- strptime(train.dat_cl$cvtd_timestamp, "%d/%m/%Y %H:%M")
train.dat_cl$cvtd_timestamp <- ymd_hms(train.dat_cl$cvtd_timestamp)

test.dat_cl$cvtd_timestamp <- strptime(test.dat_cl$cvtd_timestamp, "%d/%m/%Y %H:%M")
test.dat_cl$cvtd_timestamp <- ymd_hms(test.dat_cl$cvtd_timestamp)

# And new_window variable
train.dat_cl$new_window <- as.factor(train.dat_cl$new_window)
test.dat_cl$new_window <- as.factor(test.dat_cl$new_window)

#-------------------------------------------------------------------------------
# Prepare data for model building
#-------------------------------------------------------------------------------
summary(train.dat_cl)
unique(train.dat$user_name ) #only 6 people

# Remove identifiers
train.dat_cl_ids <- train.dat_cl[,1:7]
train.dat_cl <- train.dat_cl[, 8:length(train.dat_cl)]

# Built training set and cross-validation set
inTrain <- createDataPartition(y = train.dat_cl$classe, p = 0.7, list = FALSE)

train <- train.dat_cl[ inTrain, ]
crossval <- train.dat_cl[ -inTrain, ]

# Check for correlated factors
corrMatrix <- cor( train[, -length(train)])
corrplot(corrMatrix, order = "FPC", method = "square", type = "lower", tl.cex = 0.6,  tl.col = rgb(0, 0, 0))

#-------------------------------------------------------------------------------
# Fit Random Forest 
#-------------------------------------------------------------------------------
#modFit <- train( classe ~ ., method = 'rf', data = train, importance = TRUE)
modFit <- randomForest(classe ~ ., data = train, importance = TRUE)

# Plot Variable Importance
var_imp <- as.data.frame(varImp(modFit))
var_imp$feature <- row.names(var_imp)
var_imp <- melt(var_imp, id = "feature")
var_imp$variable <- as.factor(var_imp$variable)

var_imp <- with(var_imp, var_imp[order(variable, value),])

ggplot(data = var_imp, aes(x = factor(feature), y = value)) + geom_bar(stat = 'identity') + 
  facet_grid(variable ~ .) +  coord_flip()

# General Gini

var_importance <- data.frame( variable = setdiff( colnames(train), "classe"),
                              importance=as.vector(importance(modFit)[,7]))
var_importance <- arrange(var_importance, desc(importance))

p <- ggplot( data = var_importance, aes(x=factor(variable, 
                                        levels=unique(var_importance$variable) ), 
                                        weight=importance, fill="orange4")) + 
  geom_bar() + 
  ggtitle("Variable Importance from Random Forest") + 
  xlab("") + 
  ylab("Variable Importance (Mean Decrease in Gini Index)") + 
  scale_fill_discrete(name="Variable Name") + 
  theme_minimal() +
  coord_flip()+ theme(legend.position="none")


varImp(modFit)

# Cross Validation with cv set
predictCV <- predict(modFit, crossval)
confusionMatrix(crossval$classe, predictCV)

# Now apply model to test set

# Remove identifiers
test.dat_cl_ids <- test.dat_cl[,1:7]
test.dat_cl <- test.dat_cl[, 8:length(test.dat_cl)]

# predict the classes of the test set
predictTest <- predict(modFit, test.dat_cl)
predictTest


# Plot margin
v1 <- as.data.frame( unclass(margin(modFit,observed)))
names(v1)[1]<- "margin"
v1$tr <- train$classe


ggplot(data = v1, aes(x=factor(tr), y=margin, fill=factor(tr))) + geom_violin() + 
  geom_point(position = "jitter", alpha = 0.25, aes(color = tr)) + theme_minimal() +
  xlab("Class") + ylab("Margin")+ theme(legend.position="none")

# Other Plots
varImpPlot(modFit)

# Export answers
answers <- as.character(predictTest)

pml_write_files = function(x){
  n = length(x)
  for(i in 1:n){
    filename = paste0("problem_id_",i,".txt")
    write.table(x[i],file=filename,quote=FALSE,row.names=FALSE,col.names=FALSE)
  }
}

pml_write_files(answers)

