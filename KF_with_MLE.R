# �J���}���t�B���^�ƍŖޖ@
# Logics of Blue
http://logics-of-blue.com/kalman-filter-mle/ 

# --------------------------------------------------------------------------------------
# ���C�u�������g��Ȃ��J���}���t�B���^�̎���
# �ޓx���v�Z���邽�߂̏����o�͂���悤�ɂ���
# --------------------------------------------------------------------------------------
localLevelModel_2 <- function(y, xPre, pPre, sigmaW, sigmaV) {
  
  #��Ԃ̗\��(���[�J�����x�����f���Ȃ̂ŁA�\���l�́A�O���̒l�Ɠ���)
  xForecast <- xPre
  
  # ��Ԃ̗\���덷�̕��U
  pForecast <- pPre + sigmaW
  
  # �ϑ��l�̗\���덷
  v <- y - xForecast
  
  # �ϑ��l�̗\���덷�̕��U
  F <- pForecast + sigmaV
  
  # �J���}���Q�C��
  kGain <- pForecast / (pForecast + sigmaV)
  
  # �J���}���Q�C�����g���ĕ␳���ꂽ���
  xFiltered <- xForecast + kGain * (y - xForecast)
  
  # �␳���ꂽ��Ԃ̌덷�̕��U
  pFiltered <- (1 - kGain) * pForecast
  
  # ���ʂ̊i�[
  result <- data.frame(
    xFiltered = xFiltered, 
    pFiltered = pFiltered,
    v = v,
    F = F
  )
  
  return(result)
}




# �i�C���여�ʃf�[�^�Ōv�Z
Nile

# �T���v���T�C�Y
N <- length(Nile)

# ��Ԃ̐���l
x <- numeric(N)	

# ��Ԃ̗\���덷�̕��U
P <- numeric(N)	


# �u��ԁv�̏����l��0�Ƃ��܂�
x <- c(0, x)
x

# �u��Ԃ̗\���덷�̕��U�v�̏����l��10000000�ɂ��܂�
P <- c(10000000, P)
P


# �ϑ��l�̗\���덷
v <- numeric(N)

# �ϑ��l�̗\���덷�̕��U
F <- numeric(N)


# �J���}���t�B���^�̒����v�Z���s��
for(i in 1:N) {
  kekka <- localLevelModel_2(Nile[i],x[i],P[i], sigmaW = 1000, sigmaV = 10000)
  x[i + 1] <- kekka$xFiltered
  P[i + 1] <- kekka$pFiltered
  v[i] <- kekka$v
  F[i] <- kekka$F
}


# �ϑ��l�̗\���덷�̌n��
v

# �ϑ��l�̗\���덷�̕��U�̎��n��
F


# �ΐ��ޓx�̌v�Z1
# dnorm�֐����g�����ΐ��ޓx�̌v�Z
sum(log(dnorm(v, mean = 0, sd = sqrt(F))))

# �ΐ��ޓx�̌v�Z 2
# ���ȏ��ʂ�̌v�Z�����g�����A�ΐ��ޓx�̌v�Z
-1 * (N/2) * log(2 * pi) - 1/2 * sum(log(F) + v^2 / F)

# �ΐ��ޓx�̌v�Z 3
# dlm�p�b�P�[�W�Ōv�Z�����ΐ��ޓx
1/2 * sum(log(F) + v^2 / F)


# dlm�ł̌v�Z���ʂƂ̔�r
# dlm�p�b�P�[�W�̓ǂݍ���
library(dlm)

# dlm�̃p�����^�̐ݒ�
modelDlm <- dlmModPoly(order=1, m0=0, C0=10000000,  dW = 1000,    dV = 10000)

# �J���}���t�B���^�̎��s
Filter <- dlmFilter(Nile, modelDlm)


# �ΐ��ޓx�̌v�Z
dlmLL(Nile, modelDlm)



# --------------------------------------------------------------------------------------
# �Ŗޖ@�̎��s
# --------------------------------------------------------------------------------------
calcLogLikLocalLevel <- function(sigma){
  # �p�����^�i��ԁE�ϑ��������̃m�C�Y�̕��U�j������ƁA�����ɑΐ��ޓx���v�Z���Ă����֐�
  
  # �f�[�^��A�u��ԁv�u��Ԃ̗\���덷�̕��U�v�̏����l�̐ݒ�
  data <- Nile
  x0 <- 0
  P0 <- 10000000
  
  # ���U�͕��ɂȂ�Ȃ����߁A���炩����EXP���Ƃ��Ă���
  sigmaW <- exp(sigma[1])
  sigmaV <- exp(sigma[2])
  
  # �T���v���T�C�Y
  N <- length(data)
  
  # ��Ԃ̗\���덷�̕��U
  P <- numeric(N)	
  
  # �u��Ԃ̗\���덷�̕��U�v�̏����l�̐ݒ�
  P <- c(P0, P)
  
  # ��Ԃ̐���l
  x <- numeric(N)	
  
  # �u��ԁv�̏����l�̐ݒ�
  x <- c(x0, x)
  
  # �ϑ��l�̗\���덷�̌n��
  v <- numeric(N)
  
  # �ϑ��l�̗\���덷�̕��U�̎��n��
  F <- numeric(N)
  
  # �J���}���t�B���^�̒����v�Z���s��
  for(i in 1:N) {
    kekka <- localLevelModel_2(Nile[i],x[i],P[i], sigmaW = sigmaW, sigmaV = sigmaV)
    x[i + 1] <- kekka$xFiltered
    P[i + 1] <- kekka$pFiltered
    v[i] <- kekka$v
    F[i] <- kekka$F
  }
  
  # �ΐ��ޓx��Ԃ�
  return(1/2 * sum(log(F) + v^2 / F))
  
}

# ����m�F
calcLogLikLocalLevel(sigma=c(log(1000),log(10000)))

# �Ŗޖ@�̎��s
optim(c(1,1), calcLogLikLocalLevel, method = "L-BFGS-B")


# dlm�p�b�P�[�W���g�����p�����^�̐���
buildDlm <- function(theta){
  dlmModPoly(order=1, m0=0, C0=10000000, dW=exp(theta[1]), dV=exp(theta[2]))
}
fitDlm <- dlmMLE(Nile, parm=c(1, 1), buildDlm)

# dlm�p�b�P�[�W�ł̌v�Z����
fitDlm
exp(fitDlm$par)