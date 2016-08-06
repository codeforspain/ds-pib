# ds-pib
Dataset del PIB

Este dataset es parte del proyecto abierto y colaborativo CodeForSpain

Puedes obtener más información en:

https://github.com/codeforspain/datos/wiki
https://twitter.com/codeforspain

# Uso

Para generar un Dataset en JSON con los datos del PIB de España (incluyendo datos por comunidad autónoma y también a nivel nacional), ejecutar lo siguiente:

    ruby spain_regional_gdp.rb


Para generar un Dataset más detallado, que incluya datos de cada rama de actividad, utilizar el parámetro `--ramas-actividad`:

    ruby spain_regional_gdp.rb --ramas-actividad


En ambos casos, se genera un fichero en `../data/spain_regional_gdp.json`
