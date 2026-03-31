import argparse
import os
import time
from dataclasses import dataclass
from typing import Dict, List, Optional, Tuple, Union

import numpy as np
import pandas as pd
import requests
import yfinance as yf
from dotenv import load_dotenv


@dataclass
class SymbolState:
    last_pivot_time: Optional[pd.Timestamp] = None
    last_pivot_price: Optional[float] = None
    prev_hh_price: Optional[float] = None
    prev_hh_time: Optional[pd.Timestamp] = None
    prev_ll_price: Optional[float] = None
    prev_ll_time: Optional[pd.Timestamp] = None
    pending_cross_type: Optional[str] = None
    pending_cross_level: Optional[float] = None
    pending_cross_created_at: Optional[pd.Timestamp] = None
    last_touch_vah_bar_time: Optional[pd.Timestamp] = None
    last_touch_val_bar_time: Optional[pd.Timestamp] = None


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--env-path", default="/Users/dev1/Desktop/dev/dev/trading/.env")
    p.add_argument("--interval-seconds", type=int, default=30)
    p.add_argument("--yf-interval", default="5m")
    p.add_argument("--yf-period", default="5d")
    p.add_argument("--depth", type=int, default=10)
    p.add_argument("--lb", type=int, default=2)
    p.add_argument("--lookback-bars", type=int, default=100)
    p.add_argument("--num-rows", type=int, default=30)
    p.add_argument("--value-area-percent", type=int, default=70)
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--once", action="store_true")
    return p.parse_args()


def load_telegram_config(env_path: str) -> Tuple[str, str]:
    load_dotenv(dotenv_path=env_path)
    token = os.getenv("TELEGRAM_TOKEN")
    chat_id = os.getenv("TELEGRAM_CHAT_ID")
    if not token or not chat_id:
        raise RuntimeError("TELEGRAM_TOKEN/TELEGRAM_CHAT_ID non trovati nel file .env")
    return token, chat_id


def send_telegram(token: str, chat_id: str, text: str, dry_run: bool) -> None:
    if dry_run:
        print(text)
        print("-" * 80)
        return
    url = f"https://api.telegram.org/bot{token}/sendMessage"
    resp = requests.post(
        url,
        data={
            "chat_id": chat_id,
            "text": text,
            "disable_web_page_preview": True,
        },
        timeout=20,
    )
    if resp.status_code >= 400:
        raise RuntimeError(f"Telegram sendMessage failed: {resp.status_code} {resp.text[:300]}")


def tv_link(tv_symbol: str) -> str:
    return f"https://www.tradingview.com/chart/?symbol={tv_symbol.replace(':', '%3A')}"


def format_price(symbol_name: str, price: float) -> str:
    if symbol_name.upper() == "XAUUSD":
        return f"{price:.2f}"
    if symbol_name.upper() == "USDJPY":
        return f"{price:.3f}"
    return f"{price:.5f}"


def _ensure_ohlcv(df: pd.DataFrame) -> pd.DataFrame:
    if df is None or df.empty:
        return pd.DataFrame()
    if isinstance(df.columns, pd.MultiIndex):
        df = df.copy()
        df.columns = [c[0] for c in df.columns]
    needed = ["Open", "High", "Low", "Close", "Volume"]
    for c in needed:
        if c not in df.columns:
            df[c] = np.nan
    df = df[needed].copy()
    df = df.dropna(subset=["High", "Low", "Close"])
    df["Volume"] = pd.to_numeric(df["Volume"], errors="coerce").fillna(0.0)
    if float(df["Volume"].sum()) <= 0.0:
        df["Volume"] = 1.0
    return df


def get_yf_ohlcv(yf_ticker: str, period: str, interval: str) -> pd.DataFrame:
    df = yf.download(
        yf_ticker,
        period=period,
        interval=interval,
        auto_adjust=False,
        progress=False,
        threads=False,
    )
    df = _ensure_ohlcv(df)
    if not df.empty and df.index.tz is not None:
        df.index = df.index.tz_convert(None)
    return df


def get_yf_ohlcv_with_fallback(yf_tickers: Union[str, List[str]], period: str, interval: str) -> pd.DataFrame:
    tickers = [yf_tickers] if isinstance(yf_tickers, str) else list(yf_tickers)
    for t in tickers:
        df = get_yf_ohlcv(t, period=period, interval=interval)
        if not df.empty:
            return df
    return pd.DataFrame()


def pivot_at(df: pd.DataFrame, depth: int, lb: int) -> Tuple[Optional[Tuple[pd.Timestamp, float]], Optional[Tuple[pd.Timestamp, float]]]:
    if df is None or df.empty:
        return None, None
    n = len(df)
    pivot_idx = n - 1 - lb
    if pivot_idx - depth < 0 or pivot_idx + lb >= n:
        return None, None
    highs = df["High"].to_numpy(dtype=float)
    lows = df["Low"].to_numpy(dtype=float)
    h_window = highs[pivot_idx - depth : pivot_idx + lb + 1]
    l_window = lows[pivot_idx - depth : pivot_idx + lb + 1]
    ts = df.index[pivot_idx]
    ph = (ts, float(highs[pivot_idx])) if float(highs[pivot_idx]) == float(np.nanmax(h_window)) else None
    pl = (ts, float(lows[pivot_idx])) if float(lows[pivot_idx]) == float(np.nanmin(l_window)) else None
    return ph, pl


def structure_label(current_pivot_price: float, is_high: bool, last_pivot_price: Optional[float]) -> str:
    if last_pivot_price is None:
        return "HH" if is_high else "LL"
    if is_high:
        return "HH" if current_pivot_price > last_pivot_price else "LH"
    return "LL" if current_pivot_price < last_pivot_price else "HL"


def volume_profile_levels(
    df: pd.DataFrame,
    lookback_bars: int,
    num_rows: int,
    value_area_percent: int,
) -> Tuple[Optional[float], Optional[float], Optional[float]]:
    if df is None or df.empty:
        return None, None, None
    if lookback_bars <= 0 or num_rows < 10:
        return None, None, None
    s = df.tail(lookback_bars).copy()
    if len(s) < 10:
        return None, None, None
    highest_price = float(s["High"].max())
    lowest_price = float(s["Low"].min())
    price_range = highest_price - lowest_price
    if not np.isfinite(price_range) or price_range <= 0:
        return None, None, None
    row_height = price_range / float(num_rows)
    level_prices = lowest_price + (np.arange(num_rows, dtype=float) + 0.5) * row_height
    level_total_volume = np.zeros(num_rows, dtype=float)
    highs = s["High"].to_numpy(dtype=float)
    lows = s["Low"].to_numpy(dtype=float)
    vols = s["Volume"].to_numpy(dtype=float)
    for bar_high, bar_low, bar_vol in zip(highs, lows, vols):
        if not np.isfinite(bar_high) or not np.isfinite(bar_low) or not np.isfinite(bar_vol):
            continue
        start_level = int(np.floor((bar_low - lowest_price) / row_height))
        end_level = int(np.floor((bar_high - lowest_price) / row_height))
        start_level = max(0, start_level)
        end_level = min(num_rows - 1, end_level)
        levels_in_bar = end_level - start_level + 1
        if levels_in_bar <= 0:
            continue
        vol_per_level = float(bar_vol) / float(levels_in_bar)
        level_total_volume[start_level : end_level + 1] += vol_per_level
    total_volume = float(level_total_volume.sum())
    if total_volume <= 0:
        return None, None, None
    poc_index = int(np.argmax(level_total_volume))
    poc_price = float(level_prices[poc_index])
    target_va_volume = total_volume * float(value_area_percent) / 100.0
    accumulated = float(level_total_volume[poc_index])
    vah_index = poc_index
    val_index = poc_index
    while accumulated < target_va_volume:
        can_expand_up = vah_index < num_rows - 1
        can_expand_down = val_index > 0
        up_vol = float(level_total_volume[vah_index + 1]) if can_expand_up else 0.0
        down_vol = float(level_total_volume[val_index - 1]) if can_expand_down else 0.0
        if can_expand_up and (not can_expand_down or up_vol >= down_vol):
            accumulated += up_vol
            vah_index += 1
        elif can_expand_down:
            accumulated += down_vol
            val_index -= 1
        else:
            break
    vah = float(level_prices[vah_index] + row_height / 2.0)
    val = float(level_prices[val_index] - row_height / 2.0)
    return poc_price, vah, val


def build_structure_message(
    symbol_name: str,
    structure: str,
    pivot_price: float,
    pivot_time: pd.Timestamp,
    last_close: float,
    poc: Optional[float],
    vah: Optional[float],
    val: Optional[float],
    tv_symbol: str,
) -> str:
    parts = [
        f"📌 Struttura: {structure}",
        f"💎 Asset: {symbol_name}",
        f"🕒 Pivot: {pivot_time.isoformat(sep=' ', timespec='minutes')}",
        f"💰 Prezzo pivot: {format_price(symbol_name, pivot_price)}",
        f"📈 Close attuale: {format_price(symbol_name, last_close)}",
    ]
    if poc is not None and vah is not None and val is not None:
        parts.append(f"📊 POC: {format_price(symbol_name, poc)} | VAH: {format_price(symbol_name, vah)} | VAL: {format_price(symbol_name, val)}")
    parts.append(f"🔗 TradingView: {tv_link(tv_symbol)}")
    return "\n".join(parts)


def build_double_message(
    symbol_name: str,
    kind: str,
    first_price: float,
    first_time: pd.Timestamp,
    second_price: float,
    second_time: pd.Timestamp,
    poc: Optional[float],
    vah: Optional[float],
    val: Optional[float],
    tv_symbol: str,
) -> str:
    title = "🟦 [YF] DOPPIO MASSIMO (HH)" if kind == "HH" else "🟦 [YF] DOPPIO MINIMO (LL)"
    parts = [
        title,
        f"💎 Asset: {symbol_name}",
        f"1️⃣ {format_price(symbol_name, first_price)} @ {first_time.isoformat(sep=' ', timespec='minutes')}",
        f"2️⃣ {format_price(symbol_name, second_price)} @ {second_time.isoformat(sep=' ', timespec='minutes')}",
    ]
    if poc is not None and vah is not None and val is not None:
        parts.append(f"📊 POC: {format_price(symbol_name, poc)} | VAH: {format_price(symbol_name, vah)} | VAL: {format_price(symbol_name, val)}")
    parts.append(f"🔗 TradingView: {tv_link(tv_symbol)}")
    return "\n".join(parts)


def build_cross_message(symbol_name: str, kind: str, level: float, last_close: float, tv_symbol: str) -> str:
    if kind == "HH":
        return "\n".join(
            [
                "🟦 [YF] Cross VAH dall'alto verso il basso dopo Doppio Massimo (HH)",
                f"💎 Asset: {symbol_name}",
                f"📍 VAH: {format_price(symbol_name, level)}",
                f"📈 Close: {format_price(symbol_name, last_close)}",
                f"🔗 TradingView: {tv_link(tv_symbol)}",
            ]
        )
    return "\n".join(
        [
            "🟦 [YF] Cross VAL dal basso verso l'alto dopo Doppio Minimo (LL)",
            f"💎 Asset: {symbol_name}",
            f"📍 VAL: {format_price(symbol_name, level)}",
            f"📈 Close: {format_price(symbol_name, last_close)}",
            f"🔗 TradingView: {tv_link(tv_symbol)}",
        ]
    )

def build_touch_message(symbol_name: str, side: str, level_name: str, level: float, last_close: float, tv_symbol: str) -> str:
    title = f"🟦 [YF] {side} - Touch {level_name}"
    direction = "alto→basso" if level_name == "VAH" else "basso→alto"
    return "\n".join(
        [
            f"{title} ({direction})",
            f"💎 Asset: {symbol_name}",
            f"📍 {level_name}: {format_price(symbol_name, level)}",
            f"📈 Close: {format_price(symbol_name, last_close)}",
            f"🔗 TradingView: {tv_link(tv_symbol)}",
        ]
    )


def process_symbol(
    token: str,
    chat_id: str,
    symbol_name: str,
    yf_ticker: Union[str, List[str]],
    tv_symbol: str,
    state: SymbolState,
    dry_run: bool,
    depth: int,
    lb: int,
    lookback_bars: int,
    num_rows: int,
    value_area_percent: int,
    period: str,
    interval: str,
) -> None:
    df = get_yf_ohlcv_with_fallback(yf_ticker, period=period, interval=interval)
    if df.empty or len(df) < (depth + lb + 5):
        return
    last_close = float(df["Close"].iloc[-1])
    prev_close = float(df["Close"].iloc[-2])
    last_bar_time = df.index[-1]
    last_high = float(df["High"].iloc[-1])
    last_low = float(df["Low"].iloc[-1])
    poc, vah, val = volume_profile_levels(df, lookback_bars, num_rows, value_area_percent)
    if vah is not None and np.isfinite(vah):
        if state.last_touch_vah_bar_time != last_bar_time and np.isfinite(prev_close) and np.isfinite(last_low):
            if prev_close > vah and last_low <= vah:
                send_telegram(token, chat_id, build_touch_message(symbol_name, "SELL", "VAH", float(vah), last_close, tv_symbol), dry_run)
                state.last_touch_vah_bar_time = last_bar_time
    if val is not None and np.isfinite(val):
        if state.last_touch_val_bar_time != last_bar_time and np.isfinite(prev_close) and np.isfinite(last_high):
            if prev_close < val and last_high >= val:
                send_telegram(token, chat_id, build_touch_message(symbol_name, "BUY", "VAL", float(val), last_close, tv_symbol), dry_run)
                state.last_touch_val_bar_time = last_bar_time
    if state.pending_cross_type and state.pending_cross_level is not None:
        if state.pending_cross_type == "HH":
            if np.isfinite(prev_close) and np.isfinite(last_close) and prev_close > state.pending_cross_level and last_close <= state.pending_cross_level:
                send_telegram(token, chat_id, build_cross_message(symbol_name, "HH", state.pending_cross_level, last_close, tv_symbol), dry_run)
                state.pending_cross_type = None
                state.pending_cross_level = None
                state.pending_cross_created_at = None
        elif state.pending_cross_type == "LL":
            if np.isfinite(prev_close) and np.isfinite(last_close) and prev_close < state.pending_cross_level and last_close >= state.pending_cross_level:
                send_telegram(token, chat_id, build_cross_message(symbol_name, "LL", state.pending_cross_level, last_close, tv_symbol), dry_run)
                state.pending_cross_type = None
                state.pending_cross_level = None
                state.pending_cross_created_at = None
    ph, pl = pivot_at(df, depth=depth, lb=lb)
    for pivot, is_high in [(ph, True), (pl, False)]:
        if pivot is None:
            continue
        pivot_time, pivot_price = pivot
        if state.last_pivot_time is not None and pivot_time <= state.last_pivot_time:
            continue
        label = structure_label(pivot_price, is_high, state.last_pivot_price)
        # Invio SOLO quando si formano 2 HH (doppio massimo) o 2 LL (doppio minimo)
        if is_high and label == "HH":
            if state.prev_hh_price is not None and state.prev_hh_time is not None and pivot_price > state.prev_hh_price:
                send_telegram(
                    token,
                    chat_id,
                    build_double_message(
                        symbol_name=symbol_name,
                        kind="HH",
                        first_price=state.prev_hh_price,
                        first_time=state.prev_hh_time,
                        second_price=pivot_price,
                        second_time=pivot_time,
                        poc=poc,
                        vah=vah,
                        val=val,
                        tv_symbol=tv_symbol,
                    ),
                    dry_run,
                )
                if vah is not None and np.isfinite(vah):
                    state.pending_cross_type = "HH"
                    state.pending_cross_level = float(vah)
                    state.pending_cross_created_at = pivot_time
            state.prev_hh_price = pivot_price
            state.prev_hh_time = pivot_time
        if (not is_high) and label == "LL":
            if state.prev_ll_price is not None and state.prev_ll_time is not None and pivot_price < state.prev_ll_price:
                send_telegram(
                    token,
                    chat_id,
                    build_double_message(
                        symbol_name=symbol_name,
                        kind="LL",
                        first_price=state.prev_ll_price,
                        first_time=state.prev_ll_time,
                        second_price=pivot_price,
                        second_time=pivot_time,
                        poc=poc,
                        vah=vah,
                        val=val,
                        tv_symbol=tv_symbol,
                    ),
                    dry_run,
                )
                if val is not None and np.isfinite(val):
                    state.pending_cross_type = "LL"
                    state.pending_cross_level = float(val)
                    state.pending_cross_created_at = pivot_time
            state.prev_ll_price = pivot_price
            state.prev_ll_time = pivot_time
        state.last_pivot_price = pivot_price
        state.last_pivot_time = pivot_time


def main() -> None:
    args = parse_args()
    token, chat_id = load_telegram_config(args.env_path)
    print("✅ yfinance_structure_bot AVVIATO")
    assets: Dict[str, Dict[str, Union[str, List[str]]]] = {
        "XAUUSD": {"yf": ["GC=F", "XAUUSD=X"], "tv": "OANDA:XAUUSD"},
        "EURUSD": {"yf": "EURUSD=X", "tv": "OANDA:EURUSD"},
        "GBPUSD": {"yf": "GBPUSD=X", "tv": "OANDA:GBPUSD"},
        "USDJPY": {"yf": "JPY=X", "tv": "OANDA:USDJPY"},
    }
    states: Dict[str, SymbolState] = {k: SymbolState() for k in assets}
    while True:
        for symbol_name, cfg in assets.items():
            try:
                print(f"🔍 {symbol_name}...", end=" ", flush=True)
                process_symbol(
                    token=token,
                    chat_id=chat_id,
                    symbol_name=symbol_name,
                    yf_ticker=cfg["yf"],
                    tv_symbol=cfg["tv"],
                    state=states[symbol_name],
                    dry_run=args.dry_run,
                    depth=args.depth,
                    lb=args.lb,
                    lookback_bars=args.lookback_bars,
                    num_rows=args.num_rows,
                    value_area_percent=args.value_area_percent,
                    period=args.yf_period,
                    interval=args.yf_interval,
                )
                print("ok")
            except Exception:
                print("error")
            time.sleep(2)
        if args.once:
            print("⏹️ STOP (once)")
            break
        time.sleep(max(1, int(args.interval_seconds)))


if __name__ == "__main__":
    main()
