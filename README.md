---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->



# nlmixr2extra

<!-- badges: start -->
[![R-CMD-check](https://github.com/nlmixr2/nlmixr2extra/workflows/R-CMD-check/badge.svg)](https://github.com/nlmixr2/nlmixr2extra/actions)
[![Codecov test coverage](https://codecov.io/gh/nlmixr2/nlmixr2extra/branch/main/graph/badge.svg)](https://app.codecov.io/gh/nlmixr2/nlmixr2extra?branch=main)
[![CRAN version](http://www.r-pkg.org/badges/version/nlmixr2extra)](https://cran.r-project.org/package=nlmixr2extra)
[![CRAN total downloads](https://cranlogs.r-pkg.org/badges/grand-total/nlmixr2extra)](https://cran.r-project.org/package=nlmixr2extra)
[![CRAN total downloads](https://cranlogs.r-pkg.org/badges/nlmixr2extra)](https://cran.r-project.org/package=nlmixr2extra)
[![CodeFactor](https://www.codefactor.io/repository/github/nlmixr2/nlmixr2extra/badge)](https://www.codefactor.io/repository/github/nlmixr2/nlmixr2extra)
<!-- badges: end -->

The goal of nlmixr2extra is to provide the tools to help with common pharmacometric tasks with nlmixr2 models like bootstrapping, covariate selection etc.

## Installation

You can install the development version of nlmixr2extra from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("nlmixr2/nlmixr2data")
remotes::install_github("nlmixr2/lotri")
remotes::install_github("nlmixr2/rxode2")
remotes::install_github("nlmixr2/nlmixr2est")
remotes::install_github("nlmixr2/nlmixr2extra")
```

## Example of a `bootstrapFit()`

This is a basic example of bootstrapping provided by this package


```r
library(nlmixr2est)
library(nlmixr2extra)
## basic example code
## The basic model consiss of an ini block that has initial estimates
one.compartment <- function() {
  ini({
    tka <- 0.45 # Log Ka
    tcl <- 1 # Log Cl
    tv <- 3.45    # Log V
    eta.ka ~ 0.6
    eta.cl ~ 0.3
    eta.v ~ 0.1
    add.sd <- 0.7
  })
  # and a model block with the error sppecification and model specification
  model({
    ka <- exp(tka + eta.ka)
    cl <- exp(tcl + eta.cl)
    v <- exp(tv + eta.v)
    d/dt(depot) = -ka * depot
    d/dt(center) = ka * depot - cl / v * center
    cp = center / v
    cp ~ add(add.sd)
  })
}

## The fit is performed by the function nlmixr/nlmix2 specifying the model, data and estimate
fit <- nlmixr2(one.compartment, theo_sd,  est="saem", saemControl(print=0))
#>  
#>  
#> 
#> ℹ parameter labels from comments will be replaced by 'label()'
#> 
#> → loading into symengine environment...
#> → pruning branches (`if`/`else`) of saem model...
#> ✔ done
#> → finding duplicate expressions in saem model...
#> → optimizing duplicate expressions in saem model...
#> ✔ done
#> Calculating covariance matrix
#> → loading into symengine environment...
#> → pruning branches (`if`/`else`) of saem model...
#> ✔ done
#> → finding duplicate expressions in saem predOnly model 0...
#> → finding duplicate expressions in saem predOnly model 1...
#> → optimizing duplicate expressions in saem predOnly model 1...
#> → finding duplicate expressions in saem predOnly model 2...
#> ✔ done
#> 
#> → Calculating residuals/tables
#> ✔ done
#> → compress origData in nlmixr2 object, save 5952
#> → compress phiM in nlmixr2 object, save 62360
#> → compress parHist in nlmixr2 object, save 9560
#> → compress saem0 in nlmixr2 object, save 24584

fit2 <- suppressMessages(bootstrapFit(fit))
fit2
#> ── nlmixr SAEM OBJF by FOCEi approximation ──
#> 
#>  Gaussian/Laplacian Likelihoods: AIC(fit) or fit$objf etc. 
#>  FOCEi CWRES & Likelihoods: addCwres(fit) 
#> 
#> ── Time (sec fit$time): ──
#> 
#>            setup table compress    other covariance
#> elapsed 0.001151 0.024    0.017 3.042849      0.074
#> 
#> ── Population Parameters (fit$parFixed or fit$parFixedDf): ──
#> 
#>        Parameter  Est.     SE %RSE Back-transformed(95%CI) BSV(CV%) Shrink(SD)%
#> tka       Log Ka 0.454  0.207 45.7       1.57 (1.05, 2.36)     71.5   -0.0203% 
#> tcl       Log Cl  1.02 0.0771 7.59       2.76 (2.37, 3.21)     27.6      3.46% 
#> tv         Log V  3.45 0.0453 1.31       31.5 (28.8, 34.4)     13.4      9.89% 
#> add.sd           0.693                               0.693                     
#>  
#>   Covariance Type (fit$covMethod): boot200
#>     other calculated covs (setCov()): linFim
#>   No correlations in between subject variability (BSV) matrix
#>   Full BSV covariance (fit$omega) or correlation (fit$omegaR; diagonals=SDs) 
#>   Distribution stats (mean/skewness/kurtosis/p-value) available in fit$shrink 
#> 
#> ── Fit Data (object fit is a modified tibble): ──
#> # A tibble: 132 × 19
#>   ID     TIME    DV  PRED    RES IPRED   IRES  IWRES eta.ka eta.cl   eta.v    cp
#>   <fct> <dbl> <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>   <dbl> <dbl>
#> 1 1      0     0.74  0     0.74   0     0.74   1.07   0.103 -0.491 -0.0820  0   
#> 2 1      0.25  2.84  3.27 -0.426  3.87 -1.03  -1.48   0.103 -0.491 -0.0820  3.87
#> 3 1      0.57  6.57  5.85  0.723  6.82 -0.246 -0.356  0.103 -0.491 -0.0820  6.82
#> # … with 129 more rows, and 7 more variables: depot <dbl>, center <dbl>,
#> #   ka <dbl>, cl <dbl>, v <dbl>, tad <dbl>, dosenum <dbl>
```
