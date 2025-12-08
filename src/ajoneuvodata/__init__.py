import sqlite3
import os
from contextlib import closing
from flask import Flask, jsonify, request

app = Flask(__name__)

SQLITE_PATH = os.getenv("SQLITE_PATH", 'ajoneuvodata.sqlite')
@app.route('/', methods=['POST'])
def index():
    data = request.json
    if data is None:
        return "ei onnistu"
    filters = {
        "vin": data.get("vin")[0:10],
        "kayttoonottopvm": data.get("kayttoonottopvm"),
        "omamassa": data.get("omamassa"),
    }
    with closing(sqlite3.connect(SQLITE_PATH)) as conn:
        conn.row_factory = sqlite3.Row
        rows = conn.execute("""
            SELECT * FROM tieliikenne
            NATURAL JOIN kunta
            NATURAL JOIN vari
            NATURAL JOIN ajoneuvonkaytto
            NATURAL JOIN vaihteisto WHERE
            valmistenumero2 = :vin AND
            kayttoonottopvm = :kayttoonottopvm AND
            omamassa = :omamassa
            LIMIT 10""", filters).fetchall()
    result = [dict(row) for row in rows]
    return jsonify(result)

@app.route('/stats', methods=['GET'])
def stats():
    with closing(sqlite3.connect(SQLITE_PATH)) as conn:
        conn.row_factory = sqlite3.Row
        rows = conn.execute("""
            SELECT * FROM ajoneuvodata_stats;
            """).fetchall()
    return jsonify(dict(rows[0]))
