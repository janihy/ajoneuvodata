#!/bin/env bash
if [ ! -f Ajoneuvorekisteri.zip ]; then
    wget --progress=dot:mega https://opendata.traficom.fi/Content/Ajoneuvorekisteri.zip
fi

# we expect the file to contain only one file, maybe bail out if it doesn't
NAME=$(unzip -Z1 Ajoneuvorekisteri.zip)
if [ -f "$NAME" ]; then
    echo "Skipping unzip as output csv file already exists"
else
    unzip Ajoneuvorekisteri.zip
    # remove heading as we already have the schema in import.sql
    sed -i 1d $NAME
fi

rm -f ajoneuvodata.sqlite
echo "Creating database..."
sqlite3 ajoneuvodata.sqlite < schema.sql
echo "Importing data..."
sqlite3 ajoneuvodata.sqlite '.separator ;' '.import Ajoneuvojen_avoin_data_5_28.csv tieliikenne'
echo "ajoneuvodata.sqlite created successfully in $SECONDS seconds"
echo "Cleaning up..."
rm *.zip *.csv
