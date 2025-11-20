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
fi

echo "$NAME"
# traficom seems to change the version number in the filename every now and then
# so let's just rename any csv file (we expect to find only one) to avoindata.csv
# it's a hack yes
if [ -n "$NAME" ]; then
    echo "found unzip output filename: $NAME, renaming to avoindata.csv"
    mv "$NAME" avoindata.csv
else
    echo "no filename set earlier, renaming all csv files to avoindata.csv"
    # alpine unzip doesn't have the -Z1 option
    # maybe fix this later to avoid overwriting if there are multiple csv files
    find . -type f -name '*.csv' -exec mv {} avoindata.csv \;
fi

rm -f ajoneuvodata.sqlite
echo "Creating database..."
sqlite3 ajoneuvodata.sqlite < schema.sql
echo "Importing data..."
sqlite3 ajoneuvodata.sqlite '.separator ;' '.import -skip 1 avoindata.csv tieliikenne'
echo "ajoneuvodata.sqlite created successfully in $SECONDS seconds"
echo "Cleaning up..."
rm *.zip *.csv
