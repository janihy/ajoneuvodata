# What this is
This is a silly proof of concept "API" for searching specific cars from [Traficom Avoin data](https://www.traficom.fi/fi/ajankohtaista/avoin-data). The data is provided as a csv with 5 million rows so it's not fun to parse by hand. The VINs have been redacted but if you know enough of the car identity already, you might be able to find the correct one.

# How do I run it
Build will take a while as there is some data to import. Use the following to build and run:
```
$ podman build -t ajoneuvodata https://github.com/janihy/ajoneuvodata.git
$ podman run -p127.0.0.1:8000:8000/tcp --rm --name ajoneuvodata -it ajoneuvodata
```

# How do I use it
HTTP POST to /. Send application/json with the following parameters (all are required): vin, kayttoonottopvm, omamassa:
```
$ http http://localhost:8000 vin="WDD2120571A155186" kayttoonottopvm="20100812" omamassa=1735
HTTP/1.1 200 OK
Connection: close
Content-Length: 934
Content-Type: application/json
Date: Sun, 06 Feb 2022 17:41:24 GMT
Server: gunicorn

[
    {
        "Co2": "205",
        "ahdin": "false",
        "ajonKokPituus": "4881",
        "ajonKorkeus": "1485",
        "ajonLeveys": "1872",
        "ajoneuvoluokka": "M1",
        "ajoneuvonkaytto": "01",
        "ajoneuvoryhma": "",
        "ensirekisterointipvm": "2020-04-29",
        "iskutilavuus": "3498",
        "istumapaikkojenLkm": "5",
        "jarnro": "5064624",
        "kaupallinenNimi": "E 350 CGI",
        "kayttoonottopvm": "20100812",
        "kayttovoima": "01",
        "korityyppi": "AA",
        "kunta": "167",
        "mallimerkinta": "E 350 CGI Sedan (AA) 4ov 3498cm3 A",
        "matkamittarilukema": "133945",
        "merkkiSelvakielinen": "Mercedes-Benz",
        "ohjaamotyyppi": "",
        "omamassa": "1735",
        "ovienLukumaara": "4",
        "sahkohybridi": "false",
        "sahkohybridinluokka": "",
        "suurinNettoteho": "215",
        "sylintereidenLkm": "6",
        "teknSuurSallKokmassa": "2280",
        "tieliikSuurSallKokmassa": "2280",
        "tyyppihyvaksyntanro": "e1*2001/116*0501*04",
        "vaihteidenLkm": "7",
        "vaihteisto": "2",
        "valmistenumero2": "WDD2120571",
        "vari": "8",
        "variantti": "J057M0",
        "versio": "NZAAA502",
        "voimanvalJaTehostamistapa": "05",
        "yksittaisKayttovoima": "01"
    }
]
```
