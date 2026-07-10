
library(MuMIn)
library(pROC)
library(crossval)


## 1. Data

Heart.df <- read.table("HeartData.txt", header = TRUE)
Heart.df$num     <- factor(Heart.df$num)
Heart.df$sex     <- factor(Heart.df$sex)
Heart.df$cp      <- factor(Heart.df$cp)
Heart.df$fbs     <- factor(Heart.df$fbs)
Heart.df$restecg <- factor(Heart.df$restecg)
Heart.df$exang   <- factor(Heart.df$exang)

str(Heart.df)
summary(Heart.df)

## 2. Initial model and diagnostics
Heart.glm <- glm(num ~ ., family = binomial, data = Heart.df)
summary(Heart.glm)

par(mfrow = c(2, 2))
plot(Heart.glm)
par(mfrow = c(1, 1))

## 3. Model selection with `dredge`

options(na.action = "na.fail")
all.fits <- dredge(Heart.glm)
head(all.fits)

mod1 <- get.models(all.fits, 1)[[1]]
mod2 <- get.models(all.fits, 2)[[1]]
mod3 <- get.models(all.fits, 3)[[1]]

mod1
mod2
mod3

## 4. Cross-validated comparison

predfun <- function(train.x, train.y, test.x, test.y) {
  fit1 <- glm(train.y ~ chol + cp + exang + fbs + oldpeak + sex,
              family = binomial, data = train.x)
  auc1 <- roc(response = test.y,
              predictor = predict(fit1, newdata = test.x, type = "response"))$auc
  
  fit2 <- glm(train.y ~ cp + exang + fbs + oldpeak + sex,
              family = binomial, data = train.x)
  auc2 <- roc(response = test.y,
              predictor = predict(fit2, newdata = test.x, type = "response"))$auc
  
  fit3 <- glm(train.y ~ chol + cp + exang + fbs + oldpeak + sex + thalach,
              family = binomial, data = train.x)
  auc3 <- roc(response = test.y,
              predictor = predict(fit3, newdata = test.x, type = "response"))$auc
  
  c(auc1, auc2, auc3)
}

set.seed(330)
auc.ests <- crossval(predfun, X = Heart.df[, 1:10], Y = Heart.df[, 11],
                     K = 10, B = 50, verbose = FALSE)
auc.ests$stat
auc.ests$stat.se


final.glm <- mod1
summary(final.glm)

heart.roc <- roc(response = Heart.df$num, predictor = fitted.values(final.glm))

plot(heart.roc, print.thres = "best", col = "blue",
     grid = TRUE, print.auc.cex = 0.8, print.auc = TRUE,
     auc.polygon = TRUE, max.auc.polygon = TRUE,
     auc.polygon.col = "yellow", lwd = 2.5)

