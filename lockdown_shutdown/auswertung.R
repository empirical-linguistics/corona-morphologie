# Zusatzpakete installieren ------------


# CRAN-Pakete:
sapply(c("data.table", "tidyverse", "googleVis"), function(x) 
  if(!is.element(x, installed.packages())) install.packages(x, dependencies = T))

# nicht-CRAN-Pakete muessen extra heruntergeladen werden.
# Das Paket "collostructions" gibt es auf https://sfla.ch
# Dieses muss dann nach den dort angegebenen Instruktionen
# installiert werden,

# Pakete laden -------------------------

library(tidyverse)
library(collostructions) 
library(googleVis)

# Daten einlesen ----------------------------------------------------------

# Frequenzdaten
ld <- read_delim("lockdown_by_date.csv", delim = "\t",
                 col_names = c("Freq", "Date"),
                 col_types = list(Freq = "i", Date = "D"))
sd <- read_delim("shutdown_by_date.csv", delim = "\t",
                 col_names = c("Freq", "Date"),
                 col_types = list(Freq = "i", Date = "D"))

# ADJ + N-Daten
ald <- read_delim("adj_lockdown.csv", delim = "\t",
           col_names = c("Freq", "Lemma", "Date"),
         col_types = list(Freq = "i", Lemma = "c", Date = "D"))
asd <- read_delim("adj_shutdown.csv", delim = "\t",
           col_names = c("Freq", "Lemma", "Date"),
           col_types = list(Freq = "i", Lemma = "c", Date = "D"))


# sd und ld kombinieren
sdld <- rbind(mutate(sd, Lemma = "Shutdown"),
      mutate(ld, Lemma = "Lockdown"))


# Frequenzplot:
ggplot(filter(sdld, Date > "2020-03-01"), 
       aes(x = Date, y = Freq, col = Lemma)) + 
  geom_line() + geom_smooth() +
  theme_bw()
ggsave("freq_shutdown_lockdown.png")


# Analyse der Adjektive: -------------------------

# ueber den Gesamtzeitraum:
asd1 <- asd %>% group_by(Lemma) %>% summarise(
  Freq = sum(Freq)
)

ald1 <- ald %>% group_by(Lemma) %>% summarise(
  Freq = sum(Freq)
)

# beide Dataframes verbinden und als Input fuer
# distinktive Kollexemanlayse verwenden:
left_join(setNames(asd1, c("Lemma", "Freq_sd")),
          setNames(ald1, c("Lemma", "Freq_ld"))) %>%
  replace_na(list(Freq_ld = 0, Freq_sd = 0)) %>% collex.dist(reverse = F)


# asd und ald verbinden:
asdld <- rbind(mutate(asd, Lemma_N = "Shutdown"),
      mutate(ald, Lemma_N = "Lockdown"))

# zu breiter Tabelle konvertieren, um Motion Chart nutzen zu koennen
asdld_wide <- asdld %>% pivot_wider(names_from = Lemma_N, values_from = Freq) %>%
  replace_na(list(Shutdown = 0, Lockdown = 0))

# motion Chart
mc <- gvisMotionChart(filter(asdld_wide, Date >= "2020-03-01" & 
                               Lemma != "lockdown"), idvar = "Lemma", 
                      timevar = "Date", 
                      sizevar = "Shutdown")

plot(mc)


# mit logFreq:
asdld_wide$Shutdown_l <- log1p(asdld_wide$Shutdown)
asdld_wide$Lockdown_l <- log1p(asdld_wide$Lockdown)


mc2 <- gvisMotionChart(filter(asdld_wide, Date >= "2020-03-01" & 
                               Lemma != "lockdown"), idvar = "Lemma", 
                      timevar = "Date", 
                      sizevar = "Shutdown_l",
                      xvar = "Shutdown_l", yvar = "Lockdown_l")

plot(mc2)



# diachrone distinktive Kollexemanalyse: 
# welche Wörter verbinden sich mit "Lockdown"?

# Aufspaltung in zwei Zeitschnitte: Maerz und April
# vs. Mai und Juni

mrz <- filter(ald, Date >= "2020-03-01" & Date <= "2020-04-30")
mai <- filter(ald, Date >= "2020-05-01" & Date <= "2020-06-30")

# Frequenzen fuer jeden Monat aufsummieren
mrz <- mrz %>% group_by(Lemma) %>% summarise(
  Freq = sum(Freq)
)

mai <- mai %>% group_by(Lemma) %>% summarise(
  Freq = sum(Freq)
)

# die beiden Dataframes verbinden und als Input
# fuer Kollexemanalyse verwendem
left_join(setNames(select(mrz, Lemma, Freq), c("Lemma", "Mrz_Apr")),
          setNames(select(mai, Lemma, Freq), c("Lemma", "Mai_Jun"))) %>%
  replace_na(list(Mrz_Apr = 0, Mai_Jun = 0)) %>% collex.dist(rev=T)
