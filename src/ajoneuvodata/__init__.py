import sqlite3
import os
from contextlib import closing
from flask import Flask, jsonify, request

app = Flask(__name__)

SQLITE_PATH = os.getenv("SQLITE_PATH", 'ajoneuvodata.sqlite')

FIELD_MAP = {
    "vin":             "valmistenumero2",
    "kayttoonottopvm": "kayttoonottopvm",
    "omamassa":        "omamassa",
}

@app.route('/', methods=['POST'])
def index():
    data = request.json
    if data is None:
        return "ei onnistu"

    filters = []
    params = {}
    for key, column in FIELD_MAP.items():
        value = data.get(key)
        if value is not None:
            if key == "vin":
                value = value[0:10]
            filters.append(f"{column} = :{key}")
            params[key] = value

    base = """SELECT * FROM tieliikenne
              NATURAL JOIN kunta
              NATURAL JOIN vari
              NATURAL JOIN ajoneuvonkaytto
              NATURAL JOIN vaihteisto"""

    query = (base + " WHERE " + " AND ".join(filters) if filters else base) + " LIMIT 10"

    with closing(sqlite3.connect(SQLITE_PATH)) as conn:
        conn.row_factory = sqlite3.Row
        rows = conn.execute(query, params).fetchall()
    return jsonify([dict(row) for row in rows])

@app.route('/stats', methods=['GET'])
def stats():
    with closing(sqlite3.connect(SQLITE_PATH)) as conn:
        conn.row_factory = sqlite3.Row
        rows = conn.execute("""
            SELECT * FROM ajoneuvodata_stats;
            """).fetchall()
    return jsonify(dict(rows[0]))
