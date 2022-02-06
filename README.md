# What this is
This is a silly proof of concept "API" for searching specific cars from [Traficom Avoin data](https://www.traficom.fi/fi/ajankohtaista/avoin-data). The data is provided as a csv with 5308037 rows so it's not fun to parse by hand. The Vehicle Identification Numbers have been redacted but if you know enough of the car identity already.

# How do I run it
Build the Docker container as specified in the Dockerfile

# How do I use it
HTTP POST to /.
