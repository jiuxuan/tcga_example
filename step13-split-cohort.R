## 
### ---------------
###
### Create: Jianming Zeng
### Date: 2018-08-10 17:07:49
### Email: jmzeng1314@163.com
### Blog: http://www.bio-info-trainee.com/
### Forum:  http://www.biotrainee.com/thread-1376-1-1.html
### CAFS/SUSTC/Eli Lilly/University of Macau
### Update Log: 2018-08-10  First version
###
### ---------------

### https://github.com/jmzeng1314/ML

rm(list=ls())
library(survival)
library(survminer)
load(file = 'TCGA-KIRC-miRNA-example.Rdata')
group_list=ifelse(substr(colnames(expr),14,15)=='01','tumor','normal')
table(group_list)
load(file='survival_input.Rdata')
head(phe)
exprSet[1:4,1:4]

dim(expr)
set.seed(1234567890)
k=sample(1:593,300)

t_exp=expr[,k]
v_exp=expr[,-k]

table(ifelse(substr(colnames(t_exp),14,15)=='01','tumor','normal'))
table(ifelse(substr(colnames(v_exp),14,15)=='01','tumor','normal'))

t_tumor=t_exp[,substr(colnames(t_exp),14,15)=='01']
v_tumor=t_exp[,substr(colnames(v_exp),14,15)=='01']

t_phe= phe[match(substr(colnames(t_tumor),1,12),phe$ID),]
v_phe=phe[match(substr(colnames(v_tumor),1,12),phe$ID),]

head(t_phe)
t_tumor[1:4,1:4]
library(lars) 
library(glmnet) 
x=t(log2(t_tumor+1))
y=t_phe$event 
cv_fit <- cv.glmnet(x=x, y=y, alpha = 1, nlambda = 1000)
plot.cv.glmnet(cv_fit)
# 两条虚线分别指示了两个特殊的λ值:
c(cv_fit$lambda.min,cv_fit$lambda.1se) 
model_lasso <- glmnet(x=x, y=y, alpha = 1, lambda=cv_fit$lambda.1se)
lasso.prob <- predict(cv_fit, newx=t(log2(v_tumor+1)) , s=c(cv_fit$lambda.min,cv_fit$lambda.1se) )
re=cbind(v_phe$event ,lasso.prob)

library(ROCR)
library(glmnet)
library(caret)
# calculate probabilities for TPR/FPR for predictions
pred <- prediction(re[,2], re[,1])
perf <- performance(pred,"tpr","fpr")
performance(pred,"auc") # shows calculated AUC for model
plot(perf,colorize=FALSE, col="black") # plot ROC curve
lines(c(0,1),c(0,1),col = "gray", lty = 4 )












