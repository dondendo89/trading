import pandas as pd
import numpy as np
import requests
import time
import os
from tradingview_ta import TA_Handler, Interval
from dotenv import load_dotenv

# --- CONFIGURAZIONE ---
load_dotenv()
TOKEN = os.getenv("TELEGRAM_TOKEN")
CHAT_ID = os.getenv("TELEGRAM_CHAT_ID")

# Se False, le Manipulation appaiono solo nel terminale come 'ok'
show_manip_msg = False  

# Configurazione Assets con Exchange primari e secondari
ASSETS = {
    "XAUUSD": {"symbol": "XAUUSD", "exch": "OANDA", "scr": "forex"},
    "GBPUSD": {"symbol": "GBPUSD", "exch": "FX_IDC", "scr": "forex"},
    "EURUSD": {"symbol": "EURUSD", "exch": "FX_IDC", "scr": "forex"},
    "USDJPY": {"symbol": "USDJPY", "exch": "FX_IDC", "scr": "forex"},
    "BTCUSD": {"symbol": "BTCUSDT", "exch": "BINANCE", "scr": "crypto"}
}

tracker = {}
history = {sym: {"h": [], "l": [], "c": []} for sym in ASSETS}
structure_mem = {sym: {
    "lastHiGrab": None, "lastLoGrab": None,
    "pendHi": False, "pendHiBars": 0,
    "pendLo": False, "pendLoBars": 0
} for sym in ASSETS}

def get_tv_data(symbol, exchange, screener):
    """Tenta il recupero dati con timeout esteso"""
    try:
        handler = TA_Handler(
            symbol=symbol,
            exchange=exchange,
            screener=screener,
            interval=Interval.INTERVAL_5_MINUTES,
            timeout=15
        )
        analysis = handler.get_analysis()
        return analysis.indicators
    except Exception:
        return None

def detect_logic(sym, ind):
    global history, structure_mem
    mem = structure_mem[sym]
    
    # Aggiorna memoria
    history[sym]["h"].append(ind["high"])
    history[sym]["l"].append(ind["low"])
    history[sym]["c"].append(ind["close"])
    
    # Mantieni le ultime 30 candele
    if len(history[sym]["h"]) > 30:
        for k in history[sym]: history[sym][k].pop(0)
    
    # Servono almeno 5 candele per iniziare l'analisi pivot
    if len(history[sym]["h"]) < 5: 
        return "INIT" 

    h_list = history[sym]["h"]
    l_list = history[sym]["l"]
    curr_c = ind["close"]
    prev_h = h_list[-2]
    prev_l = l_list[-2]

    # --- 1. PIVOT GRAB (Depth dinamica basata su history) ---
    lookback = min(len(h_list) - 1, 14)
    if h_list[-2] == max(h_list[-lookback-1:-1]): mem["lastHiGrab"] = h_list[-2]
    if l_list[-2] == min(l_list[-lookback-1:-1]): mem["lastLoGrab"] = l_list[-2]

    # --- 2. LOGICA LIQUIDITY GRAB ---
    # Buffer calcolato sulla volatilità recente
    buf = (max(h_list[-5:]) - min(l_list[-5:])) * 0.1

    # Bearish Grab
    if mem["lastHiGrab"]:
        if ind["high"] > (mem["lastHiGrab"] + buf) and prev_h <= (mem["lastHiGrab"] + buf):
            if curr_c < mem["lastHiGrab"]:
                mem["lastHiGrab"] = None
                return "🔥 LIQUIDITY GRAB BEARISH"
            else:
                mem["pendHi"], mem["pendHiBars"] = True, 0
    
    if mem["pendHi"]:
        if curr_c < mem["lastHiGrab"]:
            mem["pendHi"], mem["lastHiGrab"] = False, None
            return "🔥 LIQUIDITY GRAB BEARISH"
        else:
            mem["pendHiBars"] += 1
            if mem["pendHiBars"] > 3: mem["pendHi"] = False

    # Bullish Grab
    if mem["lastLoGrab"]:
        if ind["low"] < (mem["lastLoGrab"] - buf) and prev_l >= (mem["lastLoGrab"] - buf):
            if curr_c > mem["lastLoGrab"]:
                mem["lastLoGrab"] = None
                return "🔥 LIQUIDITY GRAB BULLISH"
            else:
                mem["pendLo"], mem["pendLoBars"] = True, 0

    if mem["pendLo"]:
        if curr_c > mem["lastLoGrab"]:
            mem["pendLo"], mem["lastLoGrab"] = False, None
            return "🔥 LIQUIDITY GRAB BULLISH"
        else:
            mem["pendLoBars"] += 1
            if mem["pendLoBars"] > 3: mem["pendLo"] = False

    # --- 3. MANIPULATION ---
    if ind["low"] < prev_l and curr_c > prev_l: return "🔥 MANIPULATION BULLISH"
    if ind["high"] > prev_h and curr_c < prev_h: return "🔥 MANIPULATION BEARISH"

    return None

print("🚀 BOT ICT (TV-TA) AVVIATO - RESILIENT MODE")

while True:
    for name, cfg in ASSETS.items():
        print(f"🔍 {name}...", end=" ", flush=True)
        data = get_tv_data(cfg["symbol"], cfg["exch"], cfg["scr"])
        
        if data:
            signal = detect_logic(name, data)
            
            if signal == "INIT":
                print(f"Caricamento memoria ({len(history[name]['h'])}/5)")
                continue

            if signal and (time.time() - tracker.get(name+signal, 0) > 900):
                # Filtro Manipulation per Telegram
                if "MANIPULATION" in signal and not show_manip_msg:
                    print(f"ok (Silenced: {signal})")
                    continue
                
                msg = (f"🚨 *{signal}*\n\n💎 Asset: *{name}*\n💰 Prezzo: *{data['close']}*\n"
                       f"📊 RSI: *{data['RSI']:.2f}*")
                
                try:
                    requests.post(f"https://api.telegram.org/bot{TOKEN}/sendMessage", 
                                 data={'chat_id': CHAT_ID, 'text': msg, 'parse_mode': 'Markdown'})
                    tracker[name+signal] = time.time()
                    print(f"🎯 {signal} SENT!")
                except:
                    print("Telegram Error")
            else:
                print("ok")
        else:
            print("Conn Error")
        
        # Pausa tra asset per evitare ban IP
        time.sleep(2)
            
    time.sleep(30)