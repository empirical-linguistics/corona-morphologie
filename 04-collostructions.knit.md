---
title: 'Corona-Morphologie: Einfache Produktivitätsanalysen an konkreten Beispielen'
author: "Stefan Hartmann"
date: "2020-06-08"
---




# Assoziationsmuster

Wir möchten nun zusätzlich wissen, welche Lexeme überzufällig häufig als Bestimmungsglieder in *Corona-*Komposita auftreten. Dafür brauchen wir zunächst ein Referenzkorpus. Hierfür habe ich eine Frequenzliste aller als Nomen getaggten Tokens aus dem DWDS-Kernkorpus des 21. Jahrhunderts erstellt (wiederum mit Dstar), die wir nun einlesen. Wiederum konvertieren wir alle Daten in Kleinschreibung und zählen die Frequenz entsprechend aus:



```r
# einlesen
library(tidyverse)
```

```
## Warning: package 'tibble' was built under R version 3.6.2
```

```
## Warning: package 'purrr' was built under R version 3.6.2
```

```r
nouns <- read_delim("allnouns_dwds21.txt", 
                    delim = "\t", quote="",
                    col_names = c("Freq_dwds21", "word"))

# alle in Kleinschreibung
nouns$word <- tolower(nouns$word)

# neu auszählen (um groß- und kleingeschriebene Varianten zu vereinen)
nouns <- nouns %>% group_by(word) %>% summarise(
  Freq_dwds21 = sum(Freq_dwds21)
)
```

Nun verbinden wir mit Hilfe der `left_join`-Funktion die weiter oben erstellte `corona_tbl`-Tabelle mit der soeben erstellten `nouns`-Tabelle. Da nicht alle Lexeme, die in der Corona-Tabelle belegt sind, auch in der DWDS21-Tabelle belegt sind, gibt es einige fehlende Datenpunkte (in R heißen diese NA, für "Not Available"). Diese ersetzen wir mit Hilfe des `replace_na`-Befehls durch 0.















