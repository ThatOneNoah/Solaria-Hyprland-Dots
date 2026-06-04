#!/usr/bin/env python3
import json
import os
from http.server import HTTPServer, BaseHTTPRequestHandler
from pathlib import Path

WAL_COLORS = Path(os.environ.get("PYWAL_CACHE", Path.home() / ".cache/wal/colors.json"))

def load_palette():
  with WAL_COLORS.open() as f:
    data = json.load(f)

  colors = data["colors"]
  special = data.get("special", {})

  # crude mapping: adjust to taste
  palette = {
    "crust":   special.get("background", colors["color0"]),
    "mantle":  colors["color0"],
    "base":    colors["color1"],
    "text":    special.get("foreground", colors["color15"]),
    "subtext": colors["color7"],
    "accent1": colors["color4"],
    "accent2": colors["color5"]
  }
  return palette

class Handler(BaseHTTPRequestHandler):
  def do_GET(self):
    if self.path != "/palette":
      self.send_response(404)
      self.end_headers()
      return

    try:
      palette = load_palette()
    except Exception as e:
      self.send_response(500)
      self.end_headers()
      self.wfile.write(str(e).encode())
      return

    body = json.dumps(palette).encode()
    self.send_response(200)
    self.send_header("Content-Type", "application/json")
    self.send_header("Access-Control-Allow-Origin", "*")
    self.send_header("Content-Length", str(len(body)))
    self.end_headers()
    self.wfile.write(body)

if __name__ == "__main__":
  server = HTTPServer(("127.0.0.1", 21337), Handler)
  print("wal server on http://127.0.0.1:21337/palette")
  server.serve_forever()
