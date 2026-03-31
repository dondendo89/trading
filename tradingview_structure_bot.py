import argparse
import os
import time
from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone
from typing import Dict, List, Optional, Tuple

import numpy as np
import pandas as pd
import requests
from dotenv import load_dotenv
from tradingview_ta import TA_Handler, Interval


@dataclass
class Candle:
    t: pd.Timestamp
    o: float
    h: float
    l: float
    c: float
    v: float


@dataclass
class SymbolState:
    candles: List[Candle] = field(default_factory=list)
    current_candle_start: Optional[pd.Timestamp] = None
    current_candle: Optional[Candle] = None
    last_pivot_time: Optional[pd.Timestamp] = None
    last_pivot_price: Optional[float] = None
    prev_hh_price: Optional[float] = None
    prev_hh_time: Optional[pd.Timestamp] = None
    prev_ll_price: Optional[float] = None
    prev_ll_time: Optional[pd.Timestamp] = None
    pending_cross_type: Optional[str] = None
    pending_cross_level: Optional[float] = None
    last_seen_close: Optional[float] = None
    next_fetch_at: float = 0.0
    backoff_seconds: int = 0


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--env-path", default="/Users/dev1/Desktop/dev/dev/trading/.env")
    p.add_argument("--interval-seconds", type=int, default=60)
    p.add_argument("--tv-interval", default="5m", choices=["1m", "5m", "15m", "1h", "4h", "1d"])
    p.add_argument("--per-asset-delay-seconds", type=int, default=8)
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
        data={"chat_id": chat_id, "text": text, "disable_web_page_preview": True},
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


def to_interval_enum(tv_interval: str) -> Interval:
    return {
        "1m": Interval.INTERVAL_1_MINUTE,
        "5m": Interval.INTERVAL_5_MINUTES,
        "15m": Interval.INTERVAL_15_MINUTES,
        "1h": Interval.INTERVAL_1_HOUR,
        "4h": Interval.INTERVAL_4_HOURS,
        "1d": Interval.INTERVAL_1_DAY,
    }[tv_interval]


def interval_minutes(tv_interval: str) -> int:
    return {"1m": 1, "5m": 5, "15m": 15, "1h": 60, "4h": 240, "1d": 1440}[tv_interval]


def floor_to_interval(ts: datetime, minutes: int) -> pd.Timestamp:
    ts = ts.replace(second=0, microsecond=0)
    if minutes >= 1440:
        floored = ts.replace(hour=0, minute=0)
    else:
        m = (ts.minute // minutes) * minutes
        floored = ts.replace(minute=m)
    return pd.Timestamp(floored.replace(tzinfo=None))


def fetch_tv_snapshot(symbol: str, exchange: str, screener: str, interval: Interval) -> Dict[str, float]:
    handler = TA_Handler(
        symbol=symbol,
        exchange=exchange,
        screener=screener,
        interval=interval,
        timeout=15,
    )
    analysis = handler.get_analysis()
    ind = analysis.indicators
    return {
        "open": float(ind["open"]),
        "high": float(ind["high"]),
        "low": float(ind["low"]),
        "close": float(ind["close"]),
        "volume": float(ind.get("volume", 0.0)),
    }


def update_candle_state(state: SymbolState, candle_start: pd.Timestamp, snap: Dict[str, float]) -> bool:
    if state.current_candle_start is None or state.current_candle is None:
        state.current_candle_start = candle_start
        state.current_candle = Candle(
            t=candle_start,
            o=snap["open"],
            h=snap["high"],
            l=snap["low"],
            c=snap["close"],
            v=snap["volume"],
        )
        return False
    if candle_start == state.current_candle_start:
        c = state.current_candle
        c.h = max(c.h, snap["high"])
        c.l = min(c.l, snap["low"])
        c.c = snap["close"]
        c.v = snap["volume"]
        return False
    if candle_start > state.current_candle_start:
        state.candles.append(state.current_candle)
        if len(state.candles) > 600:
            state.candles = state.candles[-600:]
        state.current_candle_start = candle_start
        state.current_candle = Candle(
            t=candle_start,
            o=snap["open"],
            h=snap["high"],
            l=snap["low"],
            c=snap["close"],
            v=snap["volume"],
        )
        return True
    return False


def candles_to_df(candles: List[Candle]) -> pd.DataFrame:
    if not candles:
        return pd.DataFrame()
    return pd.DataFrame(
        {
            "Open": [c.o for c in candles],
            "High": [c.h for c in candles],
            "Low": [c.l for c in candles],
            "Close": [c.c for c in candles],
            "Volume": [c.v for c in candles],
        },
        index=pd.DatetimeIndex([c.t for c in candles]),
    )


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
    title = "🟪 [TV] DOPPIO MASSIMO (HH)" if kind == "HH" else "🟪 [TV] DOPPIO MINIMO (LL)"
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
                "🟪 [TV] Cross VAH dall'alto verso il basso dopo Doppio Massimo (HH)",
                f"💎 Asset: {symbol_name}",
                f"📍 VAH: {format_price(symbol_name, level)}",
                f"📈 Close: {format_price(symbol_name, last_close)}",
                f"🔗 TradingView: {tv_link(tv_symbol)}",
            ]
        )
    return "\n".join(
        [
            "🟪 [TV] Cross VAL dal basso verso l'alto dopo Doppio Minimo (LL)",
            f"💎 Asset: {symbol_name}",
            f"📍 VAL: {format_price(symbol_name, level)}",
            f"📈 Close: {format_price(symbol_name, last_close)}",
            f"🔗 TradingView: {tv_link(tv_symbol)}",
        ]
    )


def maybe_fire_cross(
    token: str,
    chat_id: str,
    symbol_name: str,
    tv_symbol: str,
    state: SymbolState,
    last_close: float,
    dry_run: bool,
) -> None:
    if state.pending_cross_type is None or state.pending_cross_level is None:
        state.last_seen_close = last_close
        return
    prev = state.last_seen_close
    state.last_seen_close = last_close
    if prev is None:
        return
    if state.pending_cross_type == "HH":
        if prev > state.pending_cross_level and last_close <= state.pending_cross_level:
            send_telegram(token, chat_id, build_cross_message(symbol_name, "HH", state.pending_cross_level, last_close, tv_symbol), dry_run)
            state.pending_cross_type = None
            state.pending_cross_level = None
    elif state.pending_cross_type == "LL":
        if prev < state.pending_cross_level and last_close >= state.pending_cross_level:
            send_telegram(token, chat_id, build_cross_message(symbol_name, "LL", state.pending_cross_level, last_close, tv_symbol), dry_run)
            state.pending_cross_type = None
            state.pending_cross_level = None


def process_new_closed_candle(
    token: str,
    chat_id: str,
    symbol_name: str,
    tv_symbol: str,
    state: SymbolState,
    df: pd.DataFrame,
    depth: int,
    lb: int,
    lookback_bars: int,
    num_rows: int,
    value_area_percent: int,
    dry_run: bool,
) -> None:
    ph, pl = pivot_at(df, depth=depth, lb=lb)
    for pivot, is_high in [(ph, True), (pl, False)]:
        if pivot is None:
            continue
        pivot_time, pivot_price = pivot
        if state.last_pivot_time is not None and pivot_time <= state.last_pivot_time:
            continue
        label = structure_label(pivot_price, is_high, state.last_pivot_price)
        poc, vah, val = volume_profile_levels(df, lookback_bars, num_rows, value_area_percent)
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
            state.prev_ll_price = pivot_price
            state.prev_ll_time = pivot_time
        state.last_pivot_price = pivot_price
        state.last_pivot_time = pivot_time


def main() -> None:
    args = parse_args()
    token, chat_id = load_telegram_config(args.env_path)
    print("✅ tradingview_structure_bot AVVIATO")
    cfgs = {
        "XAUUSD": {"symbol": "XAUUSD", "exchange": "OANDA", "screener": "cfd", "tv": "OANDA:XAUUSD"},
        "EURUSD": {"symbol": "EURUSD", "exchange": "FX_IDC", "screener": "forex", "tv": "FX_IDC:EURUSD"},
        "GBPUSD": {"symbol": "GBPUSD", "exchange": "FX_IDC", "screener": "forex", "tv": "FX_IDC:GBPUSD"},
        "USDJPY": {"symbol": "USDJPY", "exchange": "FX_IDC", "screener": "forex", "tv": "FX_IDC:USDJPY"},
    }
    states: Dict[str, SymbolState] = {k: SymbolState() for k in cfgs}
    tv_int = to_interval_enum(args.tv_interval)
    mins = interval_minutes(args.tv_interval)
    global_next_fetch_at = 0.0
    global_backoff_seconds = 0
    while True:
        now_s = time.time()
        if global_next_fetch_at > now_s:
            wait_s = int(global_next_fetch_at - now_s)
            print(f"rate_limited_global_wait:{wait_s}s", flush=True)
            time.sleep(max(1, min(wait_s, int(args.interval_seconds))))
            continue
        now = datetime.now(timezone.utc)
        candle_start = floor_to_interval(now, mins)
        for name, cfg in cfgs.items():
            st = states[name]
            try:
                print(f"🔍 {name}...", end=" ", flush=True)
                now_s = time.time()
                if global_next_fetch_at > now_s:
                    print("rate_limited_global")
                    time.sleep(max(1, int(args.per_asset_delay_seconds)))
                    continue
                if st.next_fetch_at > now_s:
                    print("rate_limited")
                    time.sleep(max(1, int(args.per_asset_delay_seconds)))
                    continue
                snap = fetch_tv_snapshot(cfg["symbol"], cfg["exchange"], cfg["screener"], tv_int)
                st.backoff_seconds = 0
                st.next_fetch_at = 0.0
                global_backoff_seconds = 0
                global_next_fetch_at = 0.0
                maybe_fire_cross(
                    token=token,
                    chat_id=chat_id,
                    symbol_name=name,
                    tv_symbol=cfg["tv"],
                    state=st,
                    last_close=snap["close"],
                    dry_run=args.dry_run,
                )
                closed = update_candle_state(st, candle_start, snap)
                if closed:
                    df = candles_to_df(st.candles)
                    if len(df) >= (args.depth + args.lb + 5):
                        process_new_closed_candle(
                            token=token,
                            chat_id=chat_id,
                            symbol_name=name,
                            tv_symbol=cfg["tv"],
                            state=st,
                            df=df,
                            depth=args.depth,
                            lb=args.lb,
                            lookback_bars=args.lookback_bars,
                            num_rows=args.num_rows,
                            value_area_percent=args.value_area_percent,
                            dry_run=args.dry_run,
                        )
                print("ok")
            except Exception as e:
                msg = str(e)
                if "429" in msg:
                    st.backoff_seconds = 30 if st.backoff_seconds <= 0 else min(600, st.backoff_seconds * 2)
                    st.next_fetch_at = time.time() + float(st.backoff_seconds)
                    global_backoff_seconds = 60 if global_backoff_seconds <= 0 else min(900, global_backoff_seconds * 2)
                    global_next_fetch_at = time.time() + float(global_backoff_seconds)
                    print(f"rate_limited:{st.backoff_seconds}s")
                else:
                    print(f"error: {msg[:120]}")
            time.sleep(max(1, int(args.per_asset_delay_seconds)))
        if args.once:
            print("⏹️ STOP (once)")
            break
        time.sleep(max(1, int(args.interval_seconds)))


if __name__ == "__main__":
    main()
