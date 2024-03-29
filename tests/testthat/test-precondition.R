test_that("precondition tests", {

  one.compartment <- function() {
    ini({
      tka <- 0.45 ; label("Log Ka")
      tcl <- 1 ; label("Log Cl")
      tv <- 3.45 ; label("Log V")
      eta.ka ~ 0.6
      eta.cl ~ 0.3
      eta.v ~ 0.1
      add.sd <- 0.7
    })
    model({
      ka <- exp(tka + eta.ka)
      cl <- exp(tcl + eta.cl)
      v <- exp(tv + eta.v)
      d / dt(depot) <- -ka * depot
      d / dt(center) <- ka * depot - cl / v * center
      cp <- center / v
      cp ~ add(add.sd)
    })
  }

  fit2 <-
    suppressMessages(suppressWarnings(
      nlmixr(
        one.compartment, nlmixr2data::theo_sd,
        est = "focei",
        control = list(print = 0)
      )
    ))

  df1 <- fit2$parFixedDf
  cov1 <- fit2$cov

  ## Simply re-evaluate with no estimation (including inner estimation)
  suppressWarnings(preconditionFit(fit2, estType = "none"))

  df2 <- fit2$parFixedDf
  cov2 <- fit2$cov

  ## In this case there isn't a theta/omega estimate so these should be the same
  expect_equal(df1$Estimate, df2$Estimate)
  expect_equal(df1$`Back-transformed`, df2$`Back-transformed`)
  expect_equal(df1$`BSV(CV%)`, df2$`BSV(CV%)`)
  expect_equal(df1$`Shrink(SD)%`, df2$`Shrink(SD)%`)

  expect_false(isTRUE(all.equal(df1$SE, df2$SE)))
  expect_false(isTRUE(all.equal(df1$`%RSE`, df2$`%RSE`)))
  expect_false(isTRUE(all.equal(df1$`CI Lower`, df2$`CI Lower`)))
  expect_false(isTRUE(all.equal(df1$`%RSE`, df2$`%RSE`)))
  expect_false(isTRUE(all.equal(cov1, cov2)))

  skip_if_not(any(names(fit2$covList) == "r,s"))

  setCov(fit2, "r,s")

  df3 <- fit2$parFixedDf
  cov3 <- fit2$cov

  expect_equal(df1$Estimate, df3$Estimate)
  expect_equal(df1$`Back-transformed`, df3$`Back-transformed`)
  expect_equal(df1$`BSV(CV%)`, df3$`BSV(CV%)`)
  expect_equal(df1$`Shrink(SD)%`, df3$`Shrink(SD)%`)

  expect_equal(df1$SE, df3$SE)
  expect_equal(df1$`%RSE`, df3$`%RSE`)
  expect_equal(df1$`CI Lower`, df3$`CI Lower`)
  expect_equal(df1$`%RSE`, df3$`%RSE`)
  expect_equal(cov1, cov3)

  setCov(fit2, "precondition")
  df4 <- fit2$parFixedDf
  cov4 <- fit2$cov

  expect_equal(df2$Estimate, df4$Estimate)
  expect_equal(df2$`Back-transformed`, df4$`Back-transformed`)
  expect_equal(df2$`BSV(CV%)`, df4$`BSV(CV%)`)
  expect_equal(df2$`Shrink(SD)%`, df4$`Shrink(SD)%`)

  expect_equal(df2$SE, df4$SE)
  expect_equal(df2$`%RSE`, df4$`%RSE`)
  expect_equal(df2$`CI Lower`, df4$`CI Lower`)
  expect_equal(df2$`%RSE`, df4$`%RSE`)
  expect_equal(cov2, cov4)
})
