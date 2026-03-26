import yfinance as yf
import pandas as pd
import numpy as np
import requests
import time
import matplotlib.pyplot as plt
import os
from dotenv import load_dotenv

# --- CARICAMENTO CONFIGURAZIONE ---
load_dotenv()
TOKEN = os.getenv("TELEGRAM_TOKEN")
CHAT_ID = os.getenv("TELEGRAM_CHAT_ID")

# Configurazione Asset: YahooSymbol -> {Nome, TV_Symbol, MT5_Symbol, Inverso_DXY}
ASSETS_CONFIG = {
    "GC=F": {"name": "GOLD", "tv": "COMEX:GC1!", "mt5": "GOLD", "inv": True},
    "EURUSD=X": {"name": "EURUSD", "tv": "FX:EURUSD", "mt5": "EURUSD", "inv": True},
    "GBPUSD=X": {"name": "GBPUSD", "tv": "FX:GBPUSD", "mt5": "GBPUSD", "inv": True},
    "USDJPY=X": {"name": "USDJPY", "tv": "FX:USDJPY", "mt5": "USDJPY", "inv": False},
    "BTC-USD": {"name": "BTCUSD", "tv": "BINANCE:BTCUSDT", "mt5": "BTCUSD", "inv": True}
}

DXY_SYMBOL = "DX-Y.NYB"
TIMEFRAME = "5m"
tracker = {asset: {"last_alert": 0} for asset in ASSETS_CONFIG}

def send_telegram(text, image_path=None):
    url = f"https://api.telegram.org/bot{TOKEN}/"
    try:
        if image_path and os.path.exists(image_path):
            with open(image_path, 'rb') as photo:
                requests.post(url + "sendPhoto", data={'chat_id': CHAT_ID, 'caption': text, 'parse_mode': 'Markdown'}, files={'photo': photo})
        else:
            requests.post(url + "sendMessage", json={"chat_id": CHAT_ID, "text": text, "parse_mode": "Markdown", "disable_web_page_preview": True})
    except Exception as e:
        print(f"Errore Telegram: {e}")

def detect_smt(df_main, df_corr, inv=True):
    """Rileva divergenza SMT tra asset e DXY (gestisce errore Series Ambiguous)"""
    if len(df_main) < 15 or len(df_corr) < 15: return None, None
    
    try:
        # Prezzi Asset (Main)
        m_l1, m_l2 = float(df_main['Low'].iloc[-10]), float(df_main['Low'].iloc[-1])
        m_h1, m_h2 = float(df_main['High'].iloc[-10]), float(df_main['High'].iloc[-1])
        
        # Prezzi DXY (Correlato)
        c_l1, c_l2 = float(df_corr['Low'].iloc[-10]), float(df_corr['Low'].iloc[-1])
        c_h1, c_h2 = float(df_corr['High'].iloc[-10]), float(df_corr['High'].iloc[-1])

        # SMT BULLISH (Asset fa Lower Low, DXY NON fa Higher High)
        if m_l2 < m_l1:
            if inv and c_h2 < c_h1: return "BULLISH", (m_l1, m_l2)
            if not inv and c_l2 > c_l1: return "BULLISH", (m_l1, m_l2)

        # SMT BEARISH (Asset fa Higher High, DXY NON fa Lower Low)
        if m_h2 > m_h1:
            if inv and c_l2 > c_l1: return "BEARISH", (m_h1, m_h2)
            if not inv and c_h2 < c_h1: return "BEARISH", (m_h1, m_h2)
            
    except: return None, None
    return None, None

def generate_chart(df, symbol, smt_type, coords):
    plt.figure(figsize=(12, 6))
    plt.style.use('dark_background')
    plt.plot(df.index, df['Close'], color='white', lw=1, alpha=0.4)
    
    # Disegna la linea SMT come nello screenshot
    if smt_type and coords:
        color = '#00ff44' if smt_type == "BULLISH" else '#ff4444'
        x_points = [df.index[-10], df.index[-1]]
        plt.plot(x_points, coords, color=color, lw=2, marker='o', markersize=8)
        plt.text(x_points[0], (coords[0]+coords[1])/2, f" + SMT {smt_type}", color=color, fontweight='bold', fontsize=12)

    plt.title(f"SMT DIVERGENCE ANALYSIS: {symbol}", color='yellow')
    plt.grid(alpha=0.1)
    path = f"smt_{symbol}.png"
    plt.savefig(path, facecolor='#121212')
    plt.close()
    return path

# --- LOOP PRINCIPALE ---
print(f"🚀 Bot Multi-Asset SMT avviato su {list(ASSETS_CONFIG.keys())}")

while True:
    try:
        # Scarica DXY una volta per ciclo
        df_dxy = yf.download(DXY_SYMBOL, period="1d", interval=TIMEFRAME, progress=False)
        
        for sym, cfg in ASSETS_CONFIG.items():
            df = yf.download(sym, period="1d", interval=TIMEFRAME, progress=False)
            if df.empty or df_dxy.empty: continue
            
            # Pulisci colonne MultiIndex se presenti
            if isinstance(df.columns, pd.MultiIndex): df.columns = df.columns.get_level_values(0)
            if isinstance(df_dxy.columns, pd.MultiIndex): df_dxy.columns = df_dxy.columns.get_level_values(0)

            smt_type, coords = detect_smt(df, df_dxy, inv=cfg['inv'])
            
            if smt_type:
                now = time.time()
                if now - tracker[sym]["last_alert"] > 900: # Cooldown 15 min
                    price = float(df['Close'].iloc[-1])
                    chart = generate_chart(df, cfg['name'], smt_type, coords)
                    
                    # Link
                    tv_url = f"https://it.tradingview.com/chart/?symbol={cfg['tv']}"
                    mt5_url = f"mt5://chart?symbol={cfg['mt5']}"
                    
                    emoji = "📈 BUY" if smt_type == "BULLISH" else "📉 SELL"
                    msg = (
                        f"🚨 *SMT {smt_type} DETECTED*\n"
                        f"💎 Asset: {cfg['name']}\n"
                        f"🔥 Segnale: {emoji}\n"
                        f"💰 Prezzo: {price:.4f}\n\n"
                        f"🔗 [Grafico TradingView]({tv_url})\n"
                        f"📲 [Apri MetaTrader 5]({mt5_url})"
                    )
                    send_telegram(msg, chart)
                    tracker[sym]["last_alert"] = now
            
            print(f"🕒 {time.strftime('%H:%M:%S')} | Monitorando {cfg['name']}...", end="\r")
            time.sleep(1) # Rispetto API Yahoo

    except Exception as e:
        print(f"\n❌ Errore generale: {e}")
    
    time.sleep(30)