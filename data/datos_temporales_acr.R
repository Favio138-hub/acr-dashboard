# ========================================
# DATOS TEMPORALES REALES POR ACR
# Archivo: data/datos_temporales_acr.R
# ========================================

library(dplyr)

# CUSCO - Choquequirao
cusco_chq <- tribble(
  ~Region, ~ACR, ~Anio, ~Deforestacion_ha,
  "Cusco", "Choquequirao", 2001, 103.234286,
  "Cusco", "Choquequirao", 2002, 45.130636,
  "Cusco", "Choquequirao", 2003, 14.58,
  "Cusco", "Choquequirao", 2004, 12.239998,
  "Cusco", "Choquequirao", 2005, 50.143587,
  "Cusco", "Choquequirao", 2006, 6.17752,
  "Cusco", "Choquequirao", 2007, 37.167397,
  "Cusco", "Choquequirao", 2008, 28.529998,
  "Cusco", "Choquequirao", 2009, 23.228277,
  "Cusco", "Choquequirao", 2010, 35.718775,
  "Cusco", "Choquequirao", 2011, 43.907946,
  "Cusco", "Choquequirao", 2012, 10.8,
  "Cusco", "Choquequirao", 2013, 30.240001,
  "Cusco", "Choquequirao", 2014, 37.156434,
  "Cusco", "Choquequirao", 2015, 18.274455,
  "Cusco", "Choquequirao", 2016, 35.438905,
  "Cusco", "Choquequirao", 2017, 51.791943,
  "Cusco", "Choquequirao", 2018, 12.444602,
  "Cusco", "Choquequirao", 2019, 11.28026,
  "Cusco", "Choquequirao", 2020, 32.538327,
  "Cusco", "Choquequirao", 2021, 13.167394,
  "Cusco", "Choquequirao", 2022, 5.4,
  "Cusco", "Choquequirao", 2023, 28.130017,
  "Cusco", "Choquequirao", 2024, 9.540001
)

# CUSCO - Chuyapi Urusayhua
cusco_chu <- tribble(
  ~Region, ~ACR, ~Anio, ~Deforestacion_ha,
  "Cusco", "Chuyapi Urusayhua", 2001, 47.714599,
  "Cusco", "Chuyapi Urusayhua", 2002, 26.729997,
  "Cusco", "Chuyapi Urusayhua", 2003, 35.980205,
  "Cusco", "Chuyapi Urusayhua", 2004, 35.966987,
  "Cusco", "Chuyapi Urusayhua", 2005, 16.980804,
  "Cusco", "Chuyapi Urusayhua", 2006, 22.616954,
  "Cusco", "Chuyapi Urusayhua", 2007, 23.379968,
  "Cusco", "Chuyapi Urusayhua", 2008, 6.12,
  "Cusco", "Chuyapi Urusayhua", 2009, 26.91672,
  "Cusco", "Chuyapi Urusayhua", 2010, 27.307155,
  "Cusco", "Chuyapi Urusayhua", 2011, 24.841897,
  "Cusco", "Chuyapi Urusayhua", 2012, 10.985956,
  "Cusco", "Chuyapi Urusayhua", 2013, 9.093487,
  "Cusco", "Chuyapi Urusayhua", 2014, 7.110001,
  "Cusco", "Chuyapi Urusayhua", 2015, 33.070067,
  "Cusco", "Chuyapi Urusayhua", 2016, 30.926455,
  "Cusco", "Chuyapi Urusayhua", 2017, 132.025086,
  "Cusco", "Chuyapi Urusayhua", 2018, 92.717643,
  "Cusco", "Chuyapi Urusayhua", 2019, 44.515127,
  "Cusco", "Chuyapi Urusayhua", 2020, 130.46548,
  "Cusco", "Chuyapi Urusayhua", 2021, 51.829305,
  "Cusco", "Chuyapi Urusayhua", 2022, 24.097296,
  "Cusco", "Chuyapi Urusayhua", 2023, 30.897646,
  "Cusco", "Chuyapi Urusayhua", 2024, 9.539998
)

# CUSCO - Q'eros Kosñipata
cusco_qk <- tribble(
  ~Region, ~ACR, ~Anio, ~Deforestacion_ha,
  "Cusco", "Q'eros Kosñipata", 2001, 26.80698620364,
  "Cusco", "Q'eros Kosñipata", 2002, 36.45650011184,
  "Cusco", "Q'eros Kosñipata", 2003, 53.30276872259,
  "Cusco", "Q'eros Kosñipata", 2004, 10.14384571214,
  "Cusco", "Q'eros Kosñipata", 2005, 26.03538516531,
  "Cusco", "Q'eros Kosñipata", 2006, 63.09860030619,
  "Cusco", "Q'eros Kosñipata", 2007, 56.10853887732,
  "Cusco", "Q'eros Kosñipata", 2008, 14.38933333937,
  "Cusco", "Q'eros Kosñipata", 2009, 7.11429802968,
  "Cusco", "Q'eros Kosñipata", 2010, 35.80451961323,
  "Cusco", "Q'eros Kosñipata", 2011, 29.21208121511,
  "Cusco", "Q'eros Kosñipata", 2012, 2.5199991,
  "Cusco", "Q'eros Kosñipata", 2013, 2.1599997,
  "Cusco", "Q'eros Kosñipata", 2014, 13.85999788922,
  "Cusco", "Q'eros Kosñipata", 2015, 7.82999952515,
  "Cusco", "Q'eros Kosñipata", 2016, 12.0600002704,
  "Cusco", "Q'eros Kosñipata", 2017, 95.17447907798,
  "Cusco", "Q'eros Kosñipata", 2018, 59.37535773846,
  "Cusco", "Q'eros Kosñipata", 2019, 0.9000009,
  "Cusco", "Q'eros Kosñipata", 2020, 15.57996100536,
  "Cusco", "Q'eros Kosñipata", 2021, 7.19999772878,
  "Cusco", "Q'eros Kosñipata", 2022, 24.5866294471,
  "Cusco", "Q'eros Kosñipata", 2023, 1.6199994,
  "Cusco", "Q'eros Kosñipata", 2024, 0.54000062928
)

# SAN MARTÍN - Cordillera Escalera
sm_ce <- tribble(
  ~Region, ~ACR, ~Anio, ~Deforestacion_ha,
  "San Martín", "Cordillera Escalera", 2001, 82.75,
  "San Martín", "Cordillera Escalera", 2002, 86.06,
  "San Martín", "Cordillera Escalera", 2003, 86.34,
  "San Martín", "Cordillera Escalera", 2004, 138.53,
  "San Martín", "Cordillera Escalera", 2005, 204.57,
  "San Martín", "Cordillera Escalera", 2006, 107.03,
  "San Martín", "Cordillera Escalera", 2007, 294.79,
  "San Martín", "Cordillera Escalera", 2008, 161.14,
  "San Martín", "Cordillera Escalera", 2009, 150.49,
  "San Martín", "Cordillera Escalera", 2010, 196.23,
  "San Martín", "Cordillera Escalera", 2011, 57.85,
  "San Martín", "Cordillera Escalera", 2012, 96.67,
  "San Martín", "Cordillera Escalera", 2013, 72.72,
  "San Martín", "Cordillera Escalera", 2014, 93.69,
  "San Martín", "Cordillera Escalera", 2015, 55.76,
  "San Martín", "Cordillera Escalera", 2016, 58.09,
  "San Martín", "Cordillera Escalera", 2017, 18.52,
  "San Martín", "Cordillera Escalera", 2018, 51.38,
  "San Martín", "Cordillera Escalera", 2019, 52.63,
  "San Martín", "Cordillera Escalera", 2020, 160.15,
  "San Martín", "Cordillera Escalera", 2021, 61.98,
  "San Martín", "Cordillera Escalera", 2022, 71.42,
  "San Martín", "Cordillera Escalera", 2023, 73.28,
  "San Martín", "Cordillera Escalera", 2024, 86.37
)

# SAN MARTÍN - Bosques de Shunté y Mishollo
sm_bsm <- tribble(
  ~Region, ~ACR, ~Anio, ~Deforestacion_ha,
  "San Martín", "Bosques de Shunté y Mishollo", 2001, 5.98,
  "San Martín", "Bosques de Shunté y Mishollo", 2002, 1.26,
  "San Martín", "Bosques de Shunté y Mishollo", 2003, 3.74,
  "San Martín", "Bosques de Shunté y Mishollo", 2004, 15.41,
  "San Martín", "Bosques de Shunté y Mishollo", 2005, 8.94,
  "San Martín", "Bosques de Shunté y Mishollo", 2006, 5.49,
  "San Martín", "Bosques de Shunté y Mishollo", 2007, 15.22,
  "San Martín", "Bosques de Shunté y Mishollo", 2008, 3.87,
  "San Martín", "Bosques de Shunté y Mishollo", 2009, 6.30,
  "San Martín", "Bosques de Shunté y Mishollo", 2010, 11.07,
  "San Martín", "Bosques de Shunté y Mishollo", 2011, 12.31,
  "San Martín", "Bosques de Shunté y Mishollo", 2012, 36.79,
  "San Martín", "Bosques de Shunté y Mishollo", 2013, 23.24,
  "San Martín", "Bosques de Shunté y Mishollo", 2014, 40.16,
  "San Martín", "Bosques de Shunté y Mishollo", 2015, 34.43,
  "San Martín", "Bosques de Shunté y Mishollo", 2016, 15.48,
  "San Martín", "Bosques de Shunté y Mishollo", 2017, 40.59,
  "San Martín", "Bosques de Shunté y Mishollo", 2018, 68.80,
  "San Martín", "Bosques de Shunté y Mishollo", 2019, 5.54,
  "San Martín", "Bosques de Shunté y Mishollo", 2020, 9.21,
  "San Martín", "Bosques de Shunté y Mishollo", 2021, 4.17,
  "San Martín", "Bosques de Shunté y Mishollo", 2022, 17.73,
  "San Martín", "Bosques de Shunté y Mishollo", 2023, 52.42,
  "San Martín", "Bosques de Shunté y Mishollo", 2024, 309.66
)

# LORETO - Ampiyacu Apayacu
loreto_aa <- tribble(
  ~Region, ~ACR, ~Anio, ~Deforestacion_ha,
  "Loreto", "Ampiyacu Apayacu", 2001, 1.437634849,
  "Loreto", "Ampiyacu Apayacu", 2002, 7.904807454,
  "Loreto", "Ampiyacu Apayacu", 2003, 0.629212208,
  "Loreto", "Ampiyacu Apayacu", 2004, 17.33612495,
  "Loreto", "Ampiyacu Apayacu", 2005, 8.446377231,
  "Loreto", "Ampiyacu Apayacu", 2006, 5.099322676,
  "Loreto", "Ampiyacu Apayacu", 2007, 0.628749754,
  "Loreto", "Ampiyacu Apayacu", 2008, 3.506013208,
  "Loreto", "Ampiyacu Apayacu", 2009, 5.007417616,
  "Loreto", "Ampiyacu Apayacu", 2010, 7.371823438,
  "Loreto", "Ampiyacu Apayacu", 2011, 7.461454891,
  "Loreto", "Ampiyacu Apayacu", 2012, 2.966764329,
  "Loreto", "Ampiyacu Apayacu", 2013, 7.347874566,
  "Loreto", "Ampiyacu Apayacu", 2014, 93.73659939,
  "Loreto", "Ampiyacu Apayacu", 2015, 4.04364431,
  "Loreto", "Ampiyacu Apayacu", 2016, 176.1721218,
  "Loreto", "Ampiyacu Apayacu", 2017, 1.356599107,
  "Loreto", "Ampiyacu Apayacu", 2018, 25.97520638,
  "Loreto", "Ampiyacu Apayacu", 2019, 7.193963916,
  "Loreto", "Ampiyacu Apayacu", 2020, 147.2085378,
  "Loreto", "Ampiyacu Apayacu", 2021, 1.849475092,
  "Loreto", "Ampiyacu Apayacu", 2022, 0.872474989,
  "Loreto", "Ampiyacu Apayacu", 2023, 0.359638861,
  "Loreto", "Ampiyacu Apayacu", 2024, 23.87093358
)

# LORETO - Alto Nanay Pintuyacu Chambira
loreto_anpch <- tribble(
  ~Region, ~ACR, ~Anio, ~Deforestacion_ha,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2001, 9.546797801,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2002, 43.32262865,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2003, 22.23378088,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2004, 14.32042205,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2005, 14.41084988,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2006, 71.87670287,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2007, 4.052813907,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2008, 21.97610131,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2009, 39.45092132,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2010, 112.2646934,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2011, 26.5480678,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2012, 49.80508639,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2013, 149.226255,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2014, 48.00261407,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2015, 36.11324686,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2016, 15.85172733,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2017, 203.1698555,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2018, 13.41950452,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2019, 5.224035201,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2020, 5.140661336,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2021, 23.9078403,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2022, 0.270177779,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2023, 14.76044411,
  "Loreto", "Alto Nanay Pintuyacu Chambira", 2024, 0.788552079
)

# LORETO - Comunal Tamshiyacu Tahuayo
loreto_ctt <- tribble(
  ~Region, ~ACR, ~Anio, ~Deforestacion_ha,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2001, 4.57411822,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2002, 1.439717583,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2003, 4.229383635,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2004, 2.544458415,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2005, 13.30600558,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2006, 14.10608475,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2007, 5.489033144,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2008, 3.239371272,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2009, 4.228888636,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2010, 3.965143166,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2011, 9.163370541,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2012, 2.069644462,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2013, 4.048701719,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2014, 17.99295218,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2015, 7.058387259,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2016, 7.769203395,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2017, 15.09690413,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2018, 5.130023316,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2019, 4.94990206,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2020, 4.410207518,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2021, 1.259618446,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2022, 7.476903644,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2023, 15.38786354,
  "Loreto", "Comunal Tamshiyacu Tahuayo", 2024, 1.979505919
)

# LORETO - Maijuna Kichwa
loreto_mk <- tribble(
  ~Region, ~ACR, ~Anio, ~Deforestacion_ha,
  "Loreto", "Maijuna Kichwa", 2001, 10.07883213,
  "Loreto", "Maijuna Kichwa", 2002, 4.949100198,
  "Loreto", "Maijuna Kichwa", 2003, 4.769167891,
  "Loreto", "Maijuna Kichwa", 2004, 5.668812942,
  "Loreto", "Maijuna Kichwa", 2005, 9.808112123,
  "Loreto", "Maijuna Kichwa", 2006, 3.868971382,
  "Loreto", "Maijuna Kichwa", 2007, 1.259722586,
  "Loreto", "Maijuna Kichwa", 2008, 43.81911205,
  "Loreto", "Maijuna Kichwa", 2009, 4.40908788,
  "Loreto", "Maijuna Kichwa", 2010, 5.398469211,
  "Loreto", "Maijuna Kichwa", 2011, 3.328812959,
  "Loreto", "Maijuna Kichwa", 2012, 153.7653247,
  "Loreto", "Maijuna Kichwa", 2013, 62.59180771,
  "Loreto", "Maijuna Kichwa", 2014, 25.38066091,
  "Loreto", "Maijuna Kichwa", 2015, 16.27794482,
  "Loreto", "Maijuna Kichwa", 2016, 26.17225475,
  "Loreto", "Maijuna Kichwa", 2017, 4.857350356,
  "Loreto", "Maijuna Kichwa", 2018, 8.456656338,
  "Loreto", "Maijuna Kichwa", 2019, 1.979506116,
  "Loreto", "Maijuna Kichwa", 2020, 6.367074222,
  "Loreto", "Maijuna Kichwa", 2021, 9.797357646,
  "Loreto", "Maijuna Kichwa", 2022, 60.99394764,
  "Loreto", "Maijuna Kichwa", 2023, 2.755235246,
  "Loreto", "Maijuna Kichwa", 2024, 3.426514298
)

# ========================================
# CONSOLIDAR TODO EN UNA LISTA
# ========================================
library(dplyr)

datos_temporales_reales <- bind_rows(
  cusco_chq,
  cusco_chu,
  cusco_qk,
  sm_ce,
  sm_bsm,
  loreto_aa,
  loreto_anpch,
  loreto_ctt,
  loreto_mk
)

# Mapeo de códigos ACR
datos_temporales_reales <- datos_temporales_reales %>%
  mutate(
    ACR_codigo = case_when(
      ACR == "Choquequirao" ~ "ACR_CHQ",
      ACR == "Chuyapi Urusayhua" ~ "ACR_CHU",
      ACR == "Q'eros Kosñipata" ~ "ACR_QK",
      ACR == "Cordillera Escalera" ~ "ACR_CE",
      ACR == "Bosques de Shunté y Mishollo" ~ "ACR_BSM",
      ACR == "Ampiyacu Apayacu" ~ "ACR_AA",
      ACR == "Alto Nanay Pintuyacu Chambira" ~ "ACR_ANPCH",
      ACR == "Comunal Tamshiyacu Tahuayo" ~ "ACR_CTT",
      ACR == "Maijuna Kichwa" ~ "ACR_MK",
      TRUE ~ ACR
    )
  )

cat("✅ Datos temporales reales cargados exitosamente\n")
cat(sprintf("   Total de registros: %d\n", nrow(datos_temporales_reales)))
cat(sprintf("   ACRs únicas: %d\n", length(unique(datos_temporales_reales$ACR_codigo))))
