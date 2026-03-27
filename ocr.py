import yfinance as yf
import pandas as pd
import numpy as np
import requests
import time
import matplotlib.pyplot as plt
import mplfinance as mpf
import os
from datetime import datetime
from dotenv import load_dotenv

# --- CONFIGURAZIONE ---
load_dotenv()
TOKEN = os.getenv("TELEGRAM_TOKEN")
CHAT_ID = os.getenv("TELEGRAM_CHAT_ID")

ASSETS_CONFIG = {
    "GC=F": {"name": "XAUUSD", "tv": "OANDA:XAUUSD", "inv": True},
    "GBPUSD=X": {"name": "GBPUSD", "tv": "FX:GBPUSD", "inv": False},
    "EURUSD=X": {"name": "EURUSD", "tv": "FX:EURUSD", "inv": False},
    "USDJPY=X": {"name": "USDJPY", "tv": "FX:USDJPY", "inv": True},
    "BTC-USD": {"name": "BTCUSD", "tv": "BINANCE:BTCUSDT", "inv": True}
}

DXY_SYMBOL = "DX-Y.NYB"
TIMEFRAME = "5m"
WBR_THRESHOLD = 0.3  # Rapporto minimo Ombra/Corpo per il Liquidity Grab
tracker = {} 

# Memoria Pivot Globale
structure_mem = {sym: {"pPrice": [], "sPrice": []} for sym in ASSETS_CONFIG}

def get_v_levels(df):
    try:
        if isinstance(df.columns, pd.MultiIndex): df.columns = df.columns.get_level_values(0)
        prices = df['Close'].values
        volumes = df['Volume'].values if 'Volume' in df.columns else np.ones(len(prices))
        bins = np.linspace(np.min(prices), np.max(prices), 40)
        v_profile, _ = np.histogram(prices, bins=bins, weights=volumes)
        poc = bins[np.argmax(v_profile)]
        vah, val = np.percentile(prices, 85), np.percentile(prices, 15)
        return vah, val, poc
    except: return 0,0,0

# --- LOGICA INTEGRATA CON LIQUIDITY GRAB ---
def detect_va_reversal_early(df, df_dxy, vah, val, poc, symbol_key):
    global structure_mem
    if len(df) < 20 or vah == 0: return None
    
    h, l, c, o = df['High'].values, df['Low'].values, df['Close'].values, df['Open'].values
    curr = df.iloc[-1]
    prev = df.iloc[-2]
    
    d, lb = 10, 2
    idx = len(df) - 1 - lb
    
    # 1. RILEVAZIONE PIVOT (STRUTTURA)
    detected_val = None
    p_type = None
    if h[idx] == max(h[idx-d : idx+lb+1]):
        detected_val, p_type = h[idx], "H"
    elif l[idx] == min(l[idx-d : idx+lb+1]):
        detected_val, p_type = l[idx], "L"
        
    mem = structure_mem[symbol_key]
    if detected_val:
        label = ""
        if p_type == "H":
            label = ("HH" if mem["pPrice"] and detected_val > mem["pPrice"][0] else "LH") if mem["pPrice"] else "H"
        else:
            label = ("LL" if mem["pPrice"] and detected_val < mem["pPrice"][0] else "HL") if mem["pPrice"] else "L"
        
        mem["pPrice"].insert(0, detected_val)
        
        if df_dxy is not None and len(df_dxy) >= len(df):
            dxy_val = df_dxy['High'].values[idx] if p_type == "H" else df_dxy['Low'].values[idx]
            mem["sPrice"].insert(0, dxy_val)
            if len(mem["pPrice"]) >= 3 and len(mem["sPrice"]) >= 2:
                currP, prevP = mem["pPrice"][0], mem["pPrice"][1]
                currS, prevS = mem["sPrice"][0], mem["sPrice"][1]
                if p_type == "H" and currP > prevP and currS < prevS:
                    return f"⚠️ SMT BEARISH ({label})"
                if p_type == "L" and currP < prevP and currS > prevS:
                    return f"⚠️ SMT BULLISH ({label})"

    # 2. LOGICA LIQUIDITY GRAB (NEW)
    if len(mem["pPrice"]) > 1:
        last_high = max(mem["pPrice"][:5]) if any(p > vah for p in mem["pPrice"][:5]) else max(mem["pPrice"][:5])
        last_low = min(mem["pPrice"][:5])
        
        body = abs(curr['Close'] - curr['Open'])
        body = body if body > 0 else 0.00001
        
        # Grab Bearish (sopra i massimi)
        if curr['High'] > last_high and curr['Close'] < last_high:
            wick_top = curr['High'] - max(curr['Close'], curr['Open'])
            if (wick_top / body) > WBR_THRESHOLD:
                return "🔥 LIQUIDITY GRAB BEARISH"

        # Grab Bullish (sotto i minimi)
        if curr['Low'] < last_low and curr['Close'] > last_low:
            wick_bot = min(curr['Close'], curr['Open']) - curr['Low']
            if (wick_bot / body) > WBR_THRESHOLD:
                return "🔥 LIQUIDITY GRAB BULLISH"

    # 3. MANIPULATION (Classic)
    tolerance = prev['High'] * 0.0001 
    if curr['Low'] < (prev['Low'] - tolerance) and curr['Close'] > prev['Low']: 
        return "🔥 MANIPULATION BULLISH"
    if curr['High'] > (prev['High'] + tolerance) and curr['Close'] < prev['High']: 
        return "🔥 MANIPULATION BEARISH"

    # 4. NOTIFICA TOUCH VAH/VAL
    if mem["pPrice"]:
        last_p = mem["pPrice"][0]
        if last_p > vah and curr['Low'] <= vah and curr['Close'] >= (vah * 0.999):
            return "🎯 VAH TOUCH (Entry Zone)"
        if last_p < val and curr['High'] >= val and curr['Close'] <= (val * 1.001):
            return "🎯 VAL TOUCH (Entry Zone)"
            
    return None

def generate_pro_chart(df, symbol, vah, val, poc, label_info=None):
    try:
        plot_df = df.tail(60).copy()
        prices_f = df['Close'].values
        bins = np.linspace(np.min(prices_f), np.max(prices_f), 40)
        v_hist, _ = np.histogram(prices_f, bins=bins, weights=df['Volume'].values if 'Volume' in df.columns else None)
        v_hist_norm = v_hist / (np.max(v_hist) if np.max(v_hist)>0 else 1) * 15 
        mc = mpf.make_marketcolors(up='#26a69a', down='#ef5350', wick='inherit', edge='inherit')
        s = mpf.make_mpf_style(base_mpl_style='dark_background', marketcolors=mc, facecolor='#101010')
        fig = mpf.figure(style=s, figsize=(12, 7), facecolor='#101010')
        ax = fig.add_subplot(1, 1, 1)
        ax.set_facecolor('#101010')
        if vah > 0:
            ax.fill_between(range(len(plot_df)), val, vah, color='#9370db', alpha=0.1, zorder=0)
            ax.axhline(vah, color='#9370db', ls='--', lw=1)
            ax.axhline(val, color='#ff9800', ls='--', lw=1)
            ax.axhline(poc, color='#2196f3', ls='-', lw=1.5)
        mpf.plot(plot_df, type='candle', ax=ax, style=s, datetime_format='%H:%M')
        bin_centers = (bins[:-1] + bins[1:]) / 2
        for i in range(len(v_hist)):
            v_color = '#26a69a' if i % 2 == 0 else '#ef5350'
            ax.barh(bin_centers[i], v_hist_norm[i], height=(bins[1]-bins[0])*0.8, 
                    left=len(plot_df) - v_hist_norm[i], color=v_color, alpha=0.3)
        if label_info:
            text, direction = label_info
            color = '#00ff44' if direction == "Long" else '#ff4444'
            ax.text(len(plot_df)//2, plot_df['High'].max() * 1.001, f" {text} ", color='white', 
                    fontweight='bold', fontsize=10, ha='center', bbox=dict(facecolor=color, alpha=0.8))
        path = f"chart_{symbol}.png"
        fig.savefig(path, facecolor='#101010', bbox_inches='tight')
        plt.close(fig)
        return path
    except: return None

# --- LOOP PRINCIPALE ---
print("🚀 BOT ICT AVVIATO - LOGICA LIQUIDITY GRAB ATTIVA")

while True:
    try:
        df_dxy = yf.download(DXY_SYMBOL, period="2d", interval=TIMEFRAME, progress=False, timeout=10)
        if not df_dxy.empty and isinstance(df_dxy.columns, pd.MultiIndex): 
            df_dxy.columns = df_dxy.columns.get_level_values(0)
        
        for sym, cfg in ASSETS_CONFIG.items():
            print(f"🔍 Analisi {cfg['name']}...", end=" ", flush=True)
            df = yf.download(sym, period="2d", interval=TIMEFRAME, progress=False, timeout=10)
            if df.empty: 
                print("Dati mancanti")
                continue
            if isinstance(df.columns, pd.MultiIndex): df.columns = df.columns.get_level_values(0)
            
            vah, val, poc = get_v_levels(df)
            signal = detect_va_reversal_early(df, df_dxy, vah, val, poc, sym)
            
            if signal and (time.time() - tracker.get(sym+signal, 0) > 900):
                direction = "Short" if any(x in signal for x in ["SELL", "BEARISH", "VAH"]) else "Long"
                chart = generate_pro_chart(df, cfg['name'], vah, val, poc, (signal, direction))
                msg = (f"🚨 *{signal}*\n\n💎 Asset: *{cfg['name']}*\n🔥 Segnale: *{'📈 BUY' if direction=='Long' else '📉 SELL'}*\n"
                       f"💰 Prezzo: *{df['Close'].iloc[-1]:.4f}*\n\n🔗 [TradingView](https://it.tradingview.com/chart/?symbol={cfg['tv']})")
                
                if chart and os.path.exists(chart):
                    with open(chart, 'rb') as f:
                        requests.post(f"https://api.telegram.org/bot{TOKEN}/sendPhoto", 
                                     data={'chat_id': CHAT_ID, 'caption': msg, 'parse_mode': 'Markdown'}, 
                                     files={'photo': f})
                tracker[sym+signal] = time.time()
                print(f"🎯 {signal} SENT!")
            else:
                print("ok")
    except Exception as e:
        print(f"\nErrore: {e}")
    time.sleep(30)