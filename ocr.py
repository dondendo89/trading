import yfinance as yf
import pandas as pd
import numpy as np
import requests
import time
import os
from dotenv import load_dotenv

# --- 1. CONFIGURAZIONE E DOTENV ---
load_dotenv()
TOKEN = os.getenv("TELEGRAM_TOKEN")
CHAT_ID = os.getenv("TELEGRAM_CHAT_ID")

# --- 2. TOGGLES MESSAGGI (True = Attivo, False = Silenziato) ---
SEND_STRUTTURA_HH_LL = True
SEND_SMT             = True
SEND_GRAB            = True
SEND_VOLUME_TOUCH    = True
SEND_MANIPULATION    = False 

# --- 3. ASSET CONFIG ---
ASSETS_CONFIG = {
    "GC=F": {"name": "XAUUSD", "tv": "OANDA:XAUUSD", "inv": True},
    "GBPUSD=X": {"name": "GBPUSD", "tv": "FX:GBPUSD", "inv": True},
    "EURUSD=X": {"name": "EURUSD", "tv": "FX:EURUSD", "inv": True},
    "USDJPY=X": {"name": "USDJPY", "tv": "FX:USDJPY", "inv": False},
    "BTC-USD": {"name": "BTCUSD", "tv": "BINANCE:BTCUSDT", "inv": True}
}

DXY_SYMBOL = "DX-Y.NYB"
TIMEFRAME = "5m"

# --- 4. MEMORIA E STATI ---
structure_mem = {sym: {"pPrice": [], "sPrice": [], "lastHiGrab": None, "lastLoGrab": None, "pendHi": False, "pendHiBars": 0, "pendLo": False, "pendLoBars": 0} for sym in ASSETS_CONFIG}
last_processed_time = {sym: None for sym in ASSETS_CONFIG}

def get_v_levels(df, num_rows=40, va_percent=70):
    try:
        if isinstance(df.columns, pd.MultiIndex): df.columns = df.columns.get_level_values(0)
        c, h, l = df['Close'].values, df['High'].values, df['Low'].values
        vol = df['Volume'].values if 'Volume' in df.columns else np.ones(len(c))
        bins = np.linspace(np.min(l), np.max(h), num_rows + 1)
        v_profile, _ = np.histogram(c, bins=bins, weights=vol)
        poc_idx = int(np.argmax(v_profile))
        target_v = np.sum(v_profile) * (va_percent / 100)
        acc_v, u_idx, d_idx, max_idx = v_profile[poc_idx], poc_idx, poc_idx, len(v_profile) - 1
        while acc_v < target_v:
            up_v = v_profile[u_idx + 1] if u_idx < max_idx else 0
            dn_v = v_profile[d_idx - 1] if d_idx > 0 else 0
            if up_v == 0 and dn_v == 0: break
            if up_v >= dn_v and u_idx < max_idx: u_idx += 1; acc_v += up_v
            elif d_idx > 0: d_idx -= 1; acc_v += dn_v
            else: break
        return bins[min(u_idx+1, len(bins)-1)], bins[max(d_idx, 0)], (bins[poc_idx]+bins[poc_idx+1])/2
    except: return 0, 0, 0

def send_alert(title, asset_name, direction, price, tv_sym, enabled):
    if not enabled: return
    tv_url = f"https://it.tradingview.com/chart/?symbol={tv_sym}"
    msg = (f"🚨 *{title}*\n\n💎 Asset: *{asset_name}*\n🔥 Segnale: {direction}\n💰 Prezzo: *{price:.4f}*\n\n🔗 [TradingView]({tv_url})")
    try:
        requests.post(f"https://api.telegram.org/bot{TOKEN}/sendMessage", 
                     data={'chat_id': CHAT_ID, 'text': msg, 'parse_mode': 'Markdown', 'disable_web_page_preview': True})
    except Exception as e: print(f"  [!] Errore Invio Telegram: {e}")

def process_logic(df, df_dxy, sym_key, vah, val, cfg):
    global structure_mem, last_processed_time
    mem = structure_mem[sym_key]
    h, l, c = df['High'].values, df['Low'].values, df['Close'].values
    d_h, d_l = df_dxy['High'].values, df_dxy['Low'].values
    atr = (df['High'] - df['Low']).rolling(14).mean().iloc[-1]
    buf = atr * 0.5 if not np.isnan(atr) else 0

    # --- A. STRUTTURA & SMT (Sincronizzata a T-5 candele) ---
    idx = len(df) - 6
    if idx >= 5:
        curr_time = df.index[idx]
        if last_processed_time[sym_key] != curr_time:
            is_ph = h[idx] == max(h[idx-5 : idx+6])
            is_pl = l[idx] == min(l[idx-5 : idx+6])
            if is_ph or is_pl:
                val_p = h[idx] if is_ph else l[idx]
                val_s = d_h[min(idx, len(d_h)-1)] if is_ph else d_l[min(idx, len(d_l)-1)]
                if len(mem["pPrice"]) > 0:
                    prev_p, prev_s = mem["pPrice"][0], mem["sPrice"][0]
                    if is_ph:
                        lab = "HH" if val_p > prev_p else "LH"
                        send_alert(f"STRUTTURA: {lab}", cfg['name'], "📉 MONITOR", val_p, cfg['tv'], SEND_STRUTTURA_HH_LL)
                        if val_p > prev_p and ((cfg['inv'] and val_s < prev_s) or (not cfg['inv'] and val_s > prev_s)):
                            send_alert(f"⚠️ SMT BEARISH ({lab})", cfg['name'], "📉 SELL", c[-1], cfg['tv'], SEND_SMT)
                    else:
                        lab = "LL" if val_p < prev_p else "HL"
                        send_alert(f"STRUTTURA: {lab}", cfg['name'], "📈 BUY", val_p, cfg['tv'], SEND_STRUTTURA_HH_LL)
                        if val_p < prev_p and ((cfg['inv'] and val_s > prev_s) or (not cfg['inv'] and val_s < prev_s)):
                            send_alert(f"⚠️ SMT BULLISH ({lab})", cfg['name'], "📈 BUY", c[-1], cfg['tv'], SEND_SMT)
                mem["pPrice"].insert(0, val_p); mem["sPrice"].insert(0, val_s)
                last_processed_time[sym_key] = curr_time
                if len(mem["pPrice"]) > 10: mem["pPrice"].pop()

    # --- B. VOLUME TOUCH ---
    if h[-2] > vah and l[-1] <= vah: send_alert("🎯 VAH TOUCH", cfg['name'], "📉 SELL", c[-1], cfg['tv'], SEND_VOLUME_TOUCH)
    if l[-2] < val and h[-1] >= val: send_alert("🎯 VAL TOUCH", cfg['name'], "📈 BUY", c[-1], cfg['tv'], SEND_VOLUME_TOUCH)

    # --- C. GRAB (Depth 14) ---
    idx_g = len(df) - 15
    if idx_g >= 14:
        if h[idx_g] == max(h[idx_g-14 : idx_g+15]): mem["lastHiGrab"] = h[idx_g]
        if l[idx_g] == min(l[idx_g-14 : idx_g+15]): mem["lastLoGrab"] = l[idx_g]
    if mem["lastHiGrab"] and h[-1] > (mem["lastHiGrab"] + buf) and h[-2] <= (mem["lastHiGrab"] + buf): mem["pendHi"] = True; mem["pendHiBars"] = 0
    if mem["pendHi"]:
        if c[-1] < mem["lastHiGrab"]: send_alert("🔥 GRAB ↑", cfg['name'], "📉 SELL", c[-1], cfg['tv'], SEND_GRAB); mem["pendHi"] = False
        else:
            mem["pendHiBars"] += 1
            if mem["pendHiBars"] > 3: mem["pendHi"] = False
    if mem["lastLoGrab"] and l[-1] < (mem["lastLoGrab"] - buf) and l[-2] >= (mem["lastLoGrab"] - buf): mem["pendLo"] = True; mem["pendLoBars"] = 0
    if mem["pendLo"]:
        if c[-1] > mem["lastLoGrab"]: send_alert("🔥 GRAB ↓", cfg['name'], "📈 BUY", c[-1], cfg['tv'], SEND_GRAB); mem["pendLo"] = False
        else:
            mem["pendLoBars"] += 1
            if mem["pendLoBars"] > 3: mem["pendLo"] = False

    # --- D. MANIPULATION ---
    if l[-1] < l[-2] and c[-1] > l[-2]: send_alert("🕯️ MANIPULATION BULLISH", cfg['name'], "📈 BUY", c[-1], cfg['tv'], SEND_MANIPULATION)
    if h[-1] > h[-2] and c[-1] < h[-2]: send_alert("🕯️ MANIPULATION BEARISH", cfg['name'], "📉 SELL", c[-1], cfg['tv'], SEND_MANIPULATION)

# --- 5. LOOP PRINCIPALE ---
print("🛰️ Verifica connessione Telegram...")
send_alert("AVVIO SYSTEM", "SYSTEM", "✅ Bot avviato e in ascolto dati", 0, "DXY", True)

print("\n🚀 BOT ICT SYNC IN ESECUZIONE")
print("------------------------------------------")
while True:
    try:
        t_now = time.strftime('%H:%M:%S')
        # Scarico DXY una volta per ciclo
        df_dxy = yf.download(DXY_SYMBOL, period="5d", interval=TIMEFRAME, progress=False)
        if isinstance(df_dxy.columns, pd.MultiIndex): df_dxy.columns = df_dxy.columns.get_level_values(0)

        for sym, cfg in ASSETS_CONFIG.items():
            # LOG DEL SINGOLO ASSET
            print(f"[{t_now}] Analisi in corso: {cfg['name']} ({sym})...", end="\r")
            
            df = yf.download(sym, period="5d", interval=TIMEFRAME, progress=False)
            if not df.empty and len(df) > 30:
                if isinstance(df.columns, pd.MultiIndex): df.columns = df.columns.get_level_values(0)
                vah, val, _ = get_v_levels(df)
                process_logic(df, df_dxy, sym, vah, val, cfg)
            
            time.sleep(0.5) # Pausa breve tra asset
            
        print(f"[{t_now}] Ciclo completato su tutti gli asset. In attesa...          ")
            
    except Exception as e:
        print(f"\n❌ Errore critico nel loop: {e}")
    
    time.sleep(30)