import argparse
import io
import os
import time
from dataclasses import dataclass
from typing import Dict, List, Optional, Tuple, Union

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import requests
import yfinance as yf
from dotenv import load_dotenv

try:
    import mplfinance as mpf

    _HAVE_MPF = True
except Exception:
    _HAVE_MPF = False


@dataclass
class SymbolState:
    last_pivot_time: Optional[pd.Timestamp] = None
    last_pivot_notify_time: Optional[pd.Timestamp] = None
    last_high_pivot_price: Optional[float] = None
    last_low_pivot_price: Optional[float] = None
    seen_pivot_keys: List[Tuple[pd.Timestamp, str]] = None
    cisd_top_price: Optional[float] = None
    cisd_bottom_price: Optional[float] = None
    cisd_is_bullish: bool = False
    cisd_is_bullish_pullback: bool = False
    cisd_is_bearish_pullback: bool = False
    cisd_potential_top_price: Optional[float] = None
    cisd_potential_bottom_price: Optional[float] = None
    cisd_bullish_break_pos: Optional[int] = None
    cisd_bearish_break_pos: Optional[int] = None
    cisd_level_bu_price: Optional[float] = None
    cisd_level_bu_pos: Optional[int] = None
    cisd_level_bu_completed: bool = False
    cisd_level_be_price: Optional[float] = None
    cisd_level_be_pos: Optional[int] = None
    cisd_level_be_completed: bool = False
    cisd_last_processed_time: Optional[pd.Timestamp] = None
    prev_hh_price: Optional[float] = None
    prev_hh_time: Optional[pd.Timestamp] = None
    prev_ll_price: Optional[float] = None
    prev_ll_time: Optional[pd.Timestamp] = None
    pending_cross_type: Optional[str] = None
    pending_cross_level: Optional[float] = None
    pending_cross_created_at: Optional[pd.Timestamp] = None
    last_touch_vah_bar_time: Optional[pd.Timestamp] = None
    last_touch_val_bar_time: Optional[pd.Timestamp] = None
    piv_times: List[pd.Timestamp] = None
    piv_prices: List[float] = None
    piv_labels: List[str] = None
    last_qm_m_time: Optional[pd.Timestamp] = None
    last_qm_w_time: Optional[pd.Timestamp] = None
    session_last_processed_time: Optional[pd.Timestamp] = None
    asia_session_day: Optional[pd.Timestamp] = None
    asia_high: Optional[float] = None
    asia_low: Optional[float] = None
    london_break_high_sent: bool = False
    london_break_low_sent: bool = False


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--env-path", default="/Users/dev1/Desktop/dev/dev/trading/.env")
    p.add_argument("--interval-seconds", type=int, default=60)
    p.add_argument("--yf-interval", default="1h")
    p.add_argument("--yf-period", default="60d")

    p.add_argument("--depth", type=int, default=10)
    p.add_argument("--lb", type=int, default=40)
    p.add_argument("--lookback-bars", type=int, default=100)
    p.add_argument("--num-rows", type=int, default=30)
    p.add_argument("--value-area-percent", type=int, default=70)

    p.add_argument("--notify-hh-ll", action="store_true", default=True)
    p.add_argument("--no-notify-hh-ll", dest="notify_hh_ll", action="store_false")
    p.add_argument("--notify-touch", action="store_true", default=True)
    p.add_argument("--no-notify-touch", dest="notify_touch", action="store_false")
    p.add_argument("--notify-cross", action="store_true", default=True)
    p.add_argument("--no-notify-cross", dest="notify_cross", action="store_false")
    p.add_argument("--notify-qm", action="store_true", default=True)
    p.add_argument("--no-notify-qm", dest="notify_qm", action="store_false")
    p.add_argument("--notify-cisd", action="store_true", default=True)
    p.add_argument("--no-notify-cisd", dest="notify_cisd", action="store_false")
    p.add_argument("--respect-market-hours", action="store_true", default=True)
    p.add_argument("--no-respect-market-hours", dest="respect_market_hours", action="store_false")
    p.add_argument("--notify-london-break", action="store_true", default=True)
    p.add_argument("--no-notify-london-break", dest="notify_london_break", action="store_false")
    p.add_argument("--session-tz-offset-hours", type=int, default=0)
    p.add_argument("--asia-start-hour", type=int, default=0)
    p.add_argument("--asia-end-hour", type=int, default=7)
    p.add_argument("--london-start-hour", type=int, default=7)
    p.add_argument("--london-end-hour", type=int, default=12)

    p.add_argument("--send-images", action="store_true", default=True)
    p.add_argument("--no-send-images", dest="send_images", action="store_false")

    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--once", action="store_true")
    return p.parse_args()


def load_telegram_config(env_path: str) -> Tuple[str, str]:
    load_dotenv(dotenv_path=env_path)
    token = os.getenv("TELEGRAM_TOKEN")
    chat_id = os.getenv("TELEGRAM_CHAT_ID") or os.getenv("CHAT_ID")
    if not token or not chat_id:
        raise RuntimeError("TELEGRAM_TOKEN/TELEGRAM_CHAT_ID (o CHAT_ID) non trovati nel file .env")
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


def send_telegram_photo(token: str, chat_id: str, caption: str, png_bytes: bytes, dry_run: bool) -> None:
    if dry_run:
        print(caption)
        print("[image: chart.png]")
        print("-" * 80)
        return
    url = f"https://api.telegram.org/bot{token}/sendPhoto"
    resp = requests.post(
        url,
        data={"chat_id": chat_id, "caption": caption, "disable_web_page_preview": True},
        files={"photo": ("chart.png", png_bytes, "image/png")},
        timeout=30,
    )
    if resp.status_code >= 400:
        raise RuntimeError(f"Telegram sendPhoto failed: {resp.status_code} {resp.text[:300]}")


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

def _is_crypto(symbol_name: str) -> bool:
    return symbol_name.upper() in {"BTCUSD", "ETHUSD"}


def _is_fx_or_metal(symbol_name: str) -> bool:
    return symbol_name.upper() in {"EURUSD", "GBPUSD", "USDJPY", "XAUUSD"}


def is_market_open(symbol_name: str, bar_time: pd.Timestamp) -> bool:
    if _is_crypto(symbol_name):
        return True
    if not _is_fx_or_metal(symbol_name):
        return True
    if bar_time is None:
        return True
    ts = pd.Timestamp(bar_time)
    wd = int(ts.weekday())
    hour = int(ts.hour)
    if wd == 5:
        return False
    if wd == 6:
        return hour >= 21
    if wd == 4:
        return hour < 21
    return True


def _in_hour_range(ts: pd.Timestamp, start_hour: int, end_hour: int) -> bool:
    h = int(ts.hour)
    if start_hour == end_hour:
        return True
    if start_hour < end_hour:
        return start_hour <= h < end_hour
    return h >= start_hour or h < end_hour


def _session_local_time(ts: pd.Timestamp, offset_hours: int) -> pd.Timestamp:
    if offset_hours == 0:
        return ts
    return ts + pd.Timedelta(hours=int(offset_hours))


def build_london_break_message(
    symbol_name: str,
    side: str,
    asia_high: float,
    asia_low: float,
    break_time: pd.Timestamp,
    last_close: float,
    tv_symbol: str,
) -> str:
    title = "🟩 [YF] London rompe Asia High" if side == "HIGH" else "🟥 [YF] London rompe Asia Low"
    return "\n".join(
        [
            title,
            f"💎 Asset: {symbol_name}",
            f"🕒 Break: {break_time.isoformat(sep=' ', timespec='minutes')}",
            f"📍 Asia High: {format_price(symbol_name, asia_high)}",
            f"📍 Asia Low: {format_price(symbol_name, asia_low)}",
            f"📈 Close: {format_price(symbol_name, last_close)}",
            f"🔗 TradingView: {tv_link(tv_symbol)}",
        ]
    )


def process_asia_london_break(
    state: SymbolState,
    df: pd.DataFrame,
    session_tz_offset_hours: int,
    asia_start_hour: int,
    asia_end_hour: int,
    london_start_hour: int,
    london_end_hour: int,
) -> List[Tuple[str, pd.Timestamp, float, float]]:
    if df is None or df.empty or len(df) < 10:
        return []

    emit_events = state.session_last_processed_time is not None
    if state.session_last_processed_time is not None:
        try:
            start_pos = int(df.index.get_loc(state.session_last_processed_time))
        except Exception:
            start_pos = max(0, len(df) - 400)
        start_pos = max(0, start_pos - 2)
    else:
        start_pos = max(0, len(df) - 400)

    events: List[Tuple[str, pd.Timestamp, float, float]] = []
    for i in range(start_pos, len(df)):
        t = pd.Timestamp(df.index[i])
        local_t = _session_local_time(t, session_tz_offset_hours)
        day = pd.Timestamp(local_t).normalize()

        if state.asia_session_day is None or day != state.asia_session_day:
            state.asia_session_day = day
            state.asia_high = None
            state.asia_low = None
            state.london_break_high_sent = False
            state.london_break_low_sent = False

        high = float(df["High"].iloc[i])
        low = float(df["Low"].iloc[i])

        if _in_hour_range(local_t, asia_start_hour, asia_end_hour):
            if np.isfinite(high):
                state.asia_high = high if state.asia_high is None else max(float(state.asia_high), high)
            if np.isfinite(low):
                state.asia_low = low if state.asia_low is None else min(float(state.asia_low), low)

        if _in_hour_range(local_t, london_start_hour, london_end_hour):
            if state.asia_high is not None and state.asia_low is not None:
                if (not state.london_break_high_sent) and np.isfinite(high) and high > float(state.asia_high):
                    state.london_break_high_sent = True
                    if emit_events:
                        events.append(("HIGH", t, float(state.asia_high), float(state.asia_low)))
                if (not state.london_break_low_sent) and np.isfinite(low) and low < float(state.asia_low):
                    state.london_break_low_sent = True
                    if emit_events:
                        events.append(("LOW", t, float(state.asia_high), float(state.asia_low)))

        state.session_last_processed_time = t

    return events


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


def structure_label_high(current_pivot_price: float, last_high_pivot_price: Optional[float]) -> str:
    if last_high_pivot_price is None:
        return "HH"
    return "HH" if current_pivot_price > last_high_pivot_price else "LH"


def structure_label_low(current_pivot_price: float, last_low_pivot_price: Optional[float]) -> str:
    if last_low_pivot_price is None:
        return "LL"
    return "LL" if current_pivot_price < last_low_pivot_price else "HL"


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


def _ensure_pivot_arrays(state: SymbolState) -> None:
    if state.piv_times is None:
        state.piv_times = []
    if state.piv_prices is None:
        state.piv_prices = []
    if state.piv_labels is None:
        state.piv_labels = []


def _append_pivot(state: SymbolState, t: pd.Timestamp, price: float, label: str) -> None:
    _ensure_pivot_arrays(state)
    state.piv_times.append(t)
    state.piv_prices.append(float(price))
    state.piv_labels.append(label)
    if len(state.piv_times) > 100:
        state.piv_times = state.piv_times[-100:]
        state.piv_prices = state.piv_prices[-100:]
        state.piv_labels = state.piv_labels[-100:]


def detect_qm_pattern(state: SymbolState) -> Optional[Tuple[str, List[Tuple[pd.Timestamp, float, str]]]]:
    _ensure_pivot_arrays(state)
    n = len(state.piv_labels)
    if n < 4:
        return None

    start = max(0, n - 14)
    labels = state.piv_labels[start:]
    prices = state.piv_prices[start:]
    times = state.piv_times[start:]

    for i in range(len(labels) - 4, -1, -1):
        seg_lbl = labels[i : i + 4]
        seg_px = prices[i : i + 4]
        seg_ts = times[i : i + 4]
        if len(seg_lbl) < 4:
            continue

        if seg_lbl == ["HH", "HL", "HH", "LL"]:
            hh1 = float(seg_px[0])
            hl = float(seg_px[1])
            hh2 = float(seg_px[2])
            ll = float(seg_px[3])
            if np.isfinite(hh1) and np.isfinite(hl) and np.isfinite(hh2) and np.isfinite(ll) and hh2 >= hh1 and ll < hl:
                return "M", list(zip(seg_ts, seg_px, seg_lbl))

        if seg_lbl == ["LL", "LH", "LL", "HH"]:
            ll1 = float(seg_px[0])
            lh = float(seg_px[1])
            ll2 = float(seg_px[2])
            hh = float(seg_px[3])
            if np.isfinite(ll1) and np.isfinite(lh) and np.isfinite(ll2) and np.isfinite(hh) and ll2 <= ll1 and hh > lh:
                return "W", list(zip(seg_ts, seg_px, seg_lbl))

    return None


def build_hh_ll_message(
    symbol_name: str,
    structure: str,
    pivot_price: float,
    pivot_time: pd.Timestamp,
    last_close: float,
    tv_symbol: str,
) -> str:
    return "\n".join(
        [
            f"🟦 [YF] {structure}",
            f"💎 Asset: {symbol_name}",
            f"🕒 Pivot: {pivot_time.isoformat(sep=' ', timespec='minutes')}",
            f"💰 Pivot: {format_price(symbol_name, pivot_price)}",
            f"📈 Close: {format_price(symbol_name, last_close)}",
            f"🔗 TradingView: {tv_link(tv_symbol)}",
        ]
    )


def build_qm_message(symbol_name: str, kind: str, last_close: float, tv_symbol: str) -> str:
    title = "🟪 [YF] QM W (Bullish)" if kind == "W" else "🟪 [YF] QM M (Bearish)"
    return "\n".join(
        [
            title,
            f"💎 Asset: {symbol_name}",
            f"📈 Close: {format_price(symbol_name, last_close)}",
            f"🔗 TradingView: {tv_link(tv_symbol)}",
        ]
    )

def build_cisd_message(symbol_name: str, kind: str, level: float, last_close: float, tv_symbol: str) -> str:
    title = "🟧 [YF] Bullish CISD Formed" if kind == "BULL" else "🟧 [YF] Bearish CISD Formed"
    level_name = "+CISD" if kind == "BULL" else "-CISD"
    return "\n".join(
        [
            title,
            f"💎 Asset: {symbol_name}",
            f"📍 {level_name}: {format_price(symbol_name, level)}",
            f"📈 Close: {format_price(symbol_name, last_close)}",
            f"🔗 TradingView: {tv_link(tv_symbol)}",
        ]
    )


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


def render_signal_chart_png(
    symbol_name: str,
    df: pd.DataFrame,
    title: str,
    markers: List[Tuple[pd.Timestamp, float, str, str]],
    polyline: Optional[Tuple[List[Tuple[pd.Timestamp, float]], str]] = None,
    poc: Optional[float] = None,
    vah: Optional[float] = None,
    val: Optional[float] = None,
    levels: Optional[List[Tuple[str, float, str]]] = None,
) -> Optional[bytes]:
    if df is None or df.empty:
        return None
    tail = df.tail(220).copy()
    if tail.empty:
        return None

    start = tail.index[0]
    end = tail.index[-1]
    filt_markers = [(t, p, txt, col) for (t, p, txt, col) in markers if t is not None and t >= start and t <= end and np.isfinite(p)]

    filt_polyline: Optional[Tuple[List[Tuple[pd.Timestamp, float]], str]] = None
    if polyline is not None:
        pts, col = polyline
        pts2 = [(t, p) for (t, p) in pts if t is not None and t >= start and t <= end and np.isfinite(p)]
        if len(pts2) >= 2:
            filt_polyline = (pts2, col)

    fig = None
    ax = None
    if _HAVE_MPF:
        style = mpf.make_mpf_style(base_mpf_style="yahoo", gridstyle=":", gridcolor="#000000", rc={"font.size": 8})
        fig, axes = mpf.plot(
            tail,
            type="candle",
            volume=False,
            style=style,
            figsize=(7.2, 3.9),
            title=title,
            returnfig=True,
            tight_layout=True,
        )
        ax = axes[0] if isinstance(axes, (list, tuple)) else axes
    else:
        x = tail.index.to_pydatetime()
        close = tail["Close"].to_numpy(dtype=float)
        fig, ax = plt.subplots(figsize=(7.2, 3.9), dpi=150)
        ax.plot(x, close, color="#2c2c2c", linewidth=1)
        ax.set_title(title)
        ax.grid(alpha=0.15)

    if fig is None or ax is None:
        return None

    if poc is not None and np.isfinite(poc):
        ax.axhline(float(poc), color="#1f77b4", linewidth=1, alpha=0.6)
    if vah is not None and np.isfinite(vah):
        ax.axhline(float(vah), color="#9c27b0", linewidth=1, alpha=0.6)
    if val is not None and np.isfinite(val):
        ax.axhline(float(val), color="#ff9800", linewidth=1, alpha=0.6)
    if levels:
        for name, level, col in levels:
            if level is None or not np.isfinite(level):
                continue
            ax.axhline(float(level), color=col, linewidth=1.2, alpha=0.85)
            ax.text(tail.index[-1].to_pydatetime(), float(level), f" {name}", fontsize=8, va="center", ha="left")

    if filt_polyline is not None:
        pts2, col = filt_polyline
        ax.plot([t.to_pydatetime() for (t, _) in pts2], [p for (_, p) in pts2], color=col, linewidth=2)

    for t, p, txt, col in filt_markers:
        ax.scatter([t.to_pydatetime()], [float(p)], s=30, color=col, zorder=5)
        if txt:
            ax.annotate(txt, xy=(t.to_pydatetime(), float(p)), xytext=(4, 4), textcoords="offset points", fontsize=9, ha="left", va="bottom")

    buf = io.BytesIO()
    fig.savefig(buf, format="png", dpi=150)
    plt.close(fig)
    return buf.getvalue()


def render_qm_chart_png(symbol_name: str, df: pd.DataFrame, kind: str, points: List[Tuple[pd.Timestamp, float, str]], poc: Optional[float], vah: Optional[float], val: Optional[float]) -> Optional[bytes]:
    line_color = "#ff9800" if kind == "M" else "#4caf50"
    markers = []
    for t, p, lbl in points:
        col = "#d32f2f" if lbl in ("HH", "LH") else "#388e3c"
        markers.append((t, float(p), lbl, col))
    return render_signal_chart_png(
        symbol_name=symbol_name,
        df=df,
        title=f"{symbol_name} QM {kind}",
        markers=markers,
        polyline=([(t, float(p)) for (t, p, _) in points], line_color),
        poc=poc,
        vah=vah,
        val=val,
    )

def _cisd_pos_from_time(df: pd.DataFrame, t: pd.Timestamp) -> Optional[int]:
    if df is None or df.empty or t is None:
        return None
    idx = df.index
    try:
        loc = idx.get_loc(t)
        if isinstance(loc, slice):
            return int(loc.start)
        if isinstance(loc, (np.ndarray, list)):
            return int(loc[0]) if len(loc) else None
        return int(loc)
    except Exception:
        return None


def process_cisd(
    state: SymbolState,
    df: pd.DataFrame,
) -> List[Tuple[str, pd.Timestamp, float, float]]:
    if df is None or df.empty or len(df) < 10:
        return []

    emit_events = state.cisd_last_processed_time is not None
    if state.cisd_last_processed_time is not None:
        start_pos = _cisd_pos_from_time(df, state.cisd_last_processed_time)
        if start_pos is None:
            start_pos = max(0, len(df) - 400)
        else:
            start_pos = max(0, start_pos - 2)
    else:
        start_pos = max(0, len(df) - 400)

    events: List[Tuple[str, pd.Timestamp, float, float]] = []
    for i in range(start_pos, len(df)):
        event_fired = False
        t = df.index[i]
        o = float(df["Open"].iloc[i])
        h = float(df["High"].iloc[i])
        l = float(df["Low"].iloc[i])
        c = float(df["Close"].iloc[i])

        if state.cisd_top_price is None or state.cisd_bottom_price is None:
            state.cisd_top_price = float(h)
            state.cisd_bottom_price = float(l)
            state.cisd_last_processed_time = t
            continue

        if i >= 1:
            prev_o = float(df["Open"].iloc[i - 1])
            prev_c = float(df["Close"].iloc[i - 1])
            bearish_pullback_detected = prev_c > prev_o
            bullish_pullback_detected = prev_c < prev_o

            if bearish_pullback_detected and not state.cisd_is_bearish_pullback:
                state.cisd_is_bearish_pullback = True
                state.cisd_potential_top_price = float(prev_o)
                state.cisd_bullish_break_pos = i - 1

            if bullish_pullback_detected and not state.cisd_is_bullish_pullback:
                state.cisd_is_bullish_pullback = True
                state.cisd_potential_bottom_price = float(prev_o)
                state.cisd_bearish_break_pos = i - 1

        if state.cisd_is_bullish_pullback and np.isfinite(o):
            if state.cisd_potential_bottom_price is None or o < state.cisd_potential_bottom_price:
                state.cisd_potential_bottom_price = float(o)
                state.cisd_bearish_break_pos = i
            if np.isfinite(c) and c < o and (state.cisd_potential_bottom_price is not None and o > state.cisd_potential_bottom_price):
                state.cisd_potential_bottom_price = float(o)
                state.cisd_bearish_break_pos = i

        if state.cisd_is_bearish_pullback and np.isfinite(o):
            if state.cisd_potential_top_price is None or o > state.cisd_potential_top_price:
                state.cisd_potential_top_price = float(o)
                state.cisd_bullish_break_pos = i
            if np.isfinite(c) and c > o and (state.cisd_potential_top_price is not None and o < state.cisd_potential_top_price):
                state.cisd_potential_top_price = float(o)
                state.cisd_bullish_break_pos = i

        if np.isfinite(l) and state.cisd_bottom_price is not None and l < state.cisd_bottom_price:
            state.cisd_bottom_price = float(l)
            state.cisd_is_bullish = False

            created = False
            if state.cisd_is_bearish_pullback and state.cisd_bullish_break_pos is not None and (i - state.cisd_bullish_break_pos) != 0:
                bp = state.cisd_bullish_break_pos
                if bp + 1 < len(df):
                    state.cisd_top_price = float(max(df["High"].iloc[bp], df["High"].iloc[bp + 1]))
                state.cisd_is_bearish_pullback = False
                if state.cisd_potential_top_price is not None and np.isfinite(state.cisd_potential_top_price):
                    state.cisd_level_be_price = float(state.cisd_potential_top_price)
                    state.cisd_level_be_pos = i
                    state.cisd_level_be_completed = False
                    created = True
            elif i >= 1 and float(df["Close"].iloc[i - 1]) > float(df["Open"].iloc[i - 1]) and c < o:
                state.cisd_top_price = float(df["High"].iloc[i - 1])
                state.cisd_is_bearish_pullback = False
                if state.cisd_potential_top_price is not None and np.isfinite(state.cisd_potential_top_price):
                    state.cisd_level_be_price = float(state.cisd_potential_top_price)
                    state.cisd_level_be_pos = i
                    state.cisd_level_be_completed = False
                    created = True
            if created:
                pass

        if np.isfinite(h) and state.cisd_top_price is not None and h > state.cisd_top_price:
            state.cisd_is_bullish = True
            state.cisd_top_price = float(h)

            created = False
            if state.cisd_is_bullish_pullback and state.cisd_bearish_break_pos is not None and (i - state.cisd_bearish_break_pos) != 0:
                bp = state.cisd_bearish_break_pos
                if bp + 1 < len(df):
                    state.cisd_bottom_price = float(min(df["Low"].iloc[bp], df["Low"].iloc[bp + 1]))
                state.cisd_is_bullish_pullback = False
                if state.cisd_potential_bottom_price is not None and np.isfinite(state.cisd_potential_bottom_price):
                    state.cisd_level_bu_price = float(state.cisd_potential_bottom_price)
                    state.cisd_level_bu_pos = i
                    state.cisd_level_bu_completed = False
                    created = True
            elif i >= 1 and float(df["Close"].iloc[i - 1]) < float(df["Open"].iloc[i - 1]) and c > o:
                state.cisd_bottom_price = float(df["Low"].iloc[i - 1])
                state.cisd_is_bullish_pullback = False
                if state.cisd_potential_bottom_price is not None and np.isfinite(state.cisd_potential_bottom_price):
                    state.cisd_level_bu_price = float(state.cisd_potential_bottom_price)
                    state.cisd_level_bu_pos = i
                    state.cisd_level_bu_completed = False
                    created = True
            if created:
                pass

        if state.cisd_level_bu_price is not None and not state.cisd_level_bu_completed and np.isfinite(c) and c < state.cisd_level_bu_price:
            state.cisd_level_bu_completed = True
            if emit_events:
                events.append(("BEAR", t, float(state.cisd_level_bu_price), float(c)))
            if state.cisd_potential_top_price is not None and np.isfinite(state.cisd_potential_top_price):
                state.cisd_level_be_price = float(state.cisd_potential_top_price)
                state.cisd_level_be_pos = i
                state.cisd_level_be_completed = False
            state.cisd_is_bullish = False
            event_fired = True

        if (not event_fired) and state.cisd_level_be_price is not None and not state.cisd_level_be_completed and np.isfinite(c) and c > state.cisd_level_be_price:
            state.cisd_level_be_completed = True
            if emit_events:
                events.append(("BULL", t, float(state.cisd_level_be_price), float(c)))
            if state.cisd_potential_bottom_price is not None and np.isfinite(state.cisd_potential_bottom_price):
                state.cisd_level_bu_price = float(state.cisd_potential_bottom_price)
                state.cisd_level_bu_pos = i
                state.cisd_level_bu_completed = False
            state.cisd_is_bullish = True
            event_fired = True

        state.cisd_last_processed_time = t

    return events


def render_chart_png(
    symbol_name: str,
    df: pd.DataFrame,
    title: str,
    marker_time: pd.Timestamp,
    marker_price: float,
    marker_text: str,
    marker_color: str,
    poc: Optional[float],
    vah: Optional[float],
    val: Optional[float],
) -> Optional[bytes]:
    if df is None or df.empty:
        return None
    tail = df.tail(220).copy()
    if tail.empty:
        return None

    start = tail.index[0]
    end = tail.index[-1]
    if marker_time is None or marker_time < start or marker_time > end or not np.isfinite(marker_price):
        marker_time = tail.index[-1]
        marker_price = float(tail["Close"].iloc[-1])

    fig = None
    ax = None
    if _HAVE_MPF:
        style = mpf.make_mpf_style(base_mpf_style="yahoo", gridstyle=":", gridcolor="#000000", rc={"font.size": 8})
        fig, axes = mpf.plot(
            tail,
            type="candle",
            volume=False,
            style=style,
            figsize=(7.2, 3.9),
            title=title,
            returnfig=True,
            tight_layout=True,
        )
        ax = axes[0] if isinstance(axes, (list, tuple)) else axes
    else:
        x = tail.index.to_pydatetime()
        close = tail["Close"].to_numpy(dtype=float)
        fig, ax = plt.subplots(figsize=(7.2, 3.9), dpi=150)
        ax.plot(x, close, color="#2c2c2c", linewidth=1)
        ax.set_title(title)
        ax.grid(alpha=0.15)

    if fig is None or ax is None:
        return None

    if poc is not None and np.isfinite(poc):
        ax.axhline(float(poc), color="#1f77b4", linewidth=1, alpha=0.6)
    if vah is not None and np.isfinite(vah):
        ax.axhline(float(vah), color="#9c27b0", linewidth=1, alpha=0.6)
    if val is not None and np.isfinite(val):
        ax.axhline(float(val), color="#ff9800", linewidth=1, alpha=0.6)

    ax.scatter([marker_time.to_pydatetime()], [float(marker_price)], s=30, color=marker_color, zorder=5)
    if marker_text:
        ax.annotate(marker_text, xy=(marker_time.to_pydatetime(), float(marker_price)), xytext=(4, 4), textcoords="offset points", fontsize=9, ha="left", va="bottom")

    buf = io.BytesIO()
    fig.savefig(buf, format="png", dpi=150)
    plt.close(fig)
    return buf.getvalue()


def maybe_send(token: str, chat_id: str, caption: str, png: Optional[bytes], dry_run: bool) -> None:
    if png is not None:
        send_telegram_photo(token, chat_id, caption, png, dry_run)
    else:
        send_telegram(token, chat_id, caption, dry_run)


def process_symbol(
    token: str,
    chat_id: str,
    symbol_name: str,
    yf_ticker: Union[str, List[str]],
    tv_symbol: str,
    state: SymbolState,
    dry_run: bool,
    send_images: bool,
    notify_hh_ll: bool,
    notify_touch: bool,
    notify_cross: bool,
    notify_qm: bool,
    notify_cisd: bool,
    notify_london_break: bool,
    respect_market_hours: bool,
    session_tz_offset_hours: int,
    asia_start_hour: int,
    asia_end_hour: int,
    london_start_hour: int,
    london_end_hour: int,
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

    if respect_market_hours and not is_market_open(symbol_name, last_bar_time):
        return

    if notify_london_break and _is_fx_or_metal(symbol_name):
        breaks = process_asia_london_break(
            state=state,
            df=df,
            session_tz_offset_hours=session_tz_offset_hours,
            asia_start_hour=asia_start_hour,
            asia_end_hour=asia_end_hour,
            london_start_hour=london_start_hour,
            london_end_hour=london_end_hour,
        )
        for side, break_time, asia_high, asia_low in breaks:
            caption = build_london_break_message(
                symbol_name=symbol_name,
                side=side,
                asia_high=float(asia_high),
                asia_low=float(asia_low),
                break_time=break_time,
                last_close=last_close,
                tv_symbol=tv_symbol,
            )
            if send_images:
                label = "London→AsiaH" if side == "HIGH" else "London→AsiaL"
                marker_price = float(asia_high) if side == "HIGH" else float(asia_low)
                color = "#388e3c" if side == "HIGH" else "#d32f2f"
                png = render_signal_chart_png(
                    symbol_name=symbol_name,
                    df=df,
                    title=f"{symbol_name} London/Asia Break",
                    markers=[(break_time, marker_price, label, color)],
                    poc=poc,
                    vah=vah,
                    val=val,
                    levels=[("Asia High", float(asia_high), "#d32f2f"), ("Asia Low", float(asia_low), "#388e3c")],
                )
            else:
                png = None
            maybe_send(token, chat_id, caption, png, dry_run)

    if notify_cisd:
        cisd_events = process_cisd(state, df)
        for kind, event_time, level, _ in cisd_events:
            caption = build_cisd_message(symbol_name, kind, float(level), last_close, tv_symbol)
            if send_images:
                label = "+CISD" if kind == "BULL" else "-CISD"
                color = "#388e3c" if kind == "BULL" else "#d32f2f"
                png = render_signal_chart_png(
                    symbol_name=symbol_name,
                    df=df,
                    title=f"{symbol_name} CISD",
                    markers=[(event_time, float(level), label, color)],
                    poc=poc,
                    vah=vah,
                    val=val,
                    levels=[(label, float(level), color)],
                )
            else:
                png = None
            maybe_send(token, chat_id, caption, png, dry_run)

    if notify_touch and vah is not None and np.isfinite(vah):
        if state.last_touch_vah_bar_time != last_bar_time and np.isfinite(prev_close) and np.isfinite(last_low):
            if prev_close > vah and last_low <= vah:
                caption = build_touch_message(symbol_name, "SELL", "VAH", float(vah), last_close, tv_symbol)
                png = render_chart_png(symbol_name, df, f"{symbol_name} Touch VAH", last_bar_time, float(vah), "Touch", "#9c27b0", poc, vah, val) if send_images else None
                maybe_send(token, chat_id, caption, png, dry_run)
                state.last_touch_vah_bar_time = last_bar_time

    if notify_touch and val is not None and np.isfinite(val):
        if state.last_touch_val_bar_time != last_bar_time and np.isfinite(prev_close) and np.isfinite(last_high):
            if prev_close < val and last_high >= val:
                caption = build_touch_message(symbol_name, "BUY", "VAL", float(val), last_close, tv_symbol)
                png = render_chart_png(symbol_name, df, f"{symbol_name} Touch VAL", last_bar_time, float(val), "Touch", "#ff9800", poc, vah, val) if send_images else None
                maybe_send(token, chat_id, caption, png, dry_run)
                state.last_touch_val_bar_time = last_bar_time

    if notify_cross and state.pending_cross_type and state.pending_cross_level is not None:
        if state.pending_cross_type == "HH":
            if np.isfinite(prev_close) and np.isfinite(last_close) and prev_close > state.pending_cross_level and last_close <= state.pending_cross_level:
                caption = build_cross_message(symbol_name, "HH", state.pending_cross_level, last_close, tv_symbol)
                png = render_chart_png(symbol_name, df, f"{symbol_name} Cross VAH", last_bar_time, float(state.pending_cross_level), "Cross", "#9c27b0", poc, vah, val) if send_images else None
                maybe_send(token, chat_id, caption, png, dry_run)
                state.pending_cross_type = None
                state.pending_cross_level = None
                state.pending_cross_created_at = None
        elif state.pending_cross_type == "LL":
            if np.isfinite(prev_close) and np.isfinite(last_close) and prev_close < state.pending_cross_level and last_close >= state.pending_cross_level:
                caption = build_cross_message(symbol_name, "LL", state.pending_cross_level, last_close, tv_symbol)
                png = render_chart_png(symbol_name, df, f"{symbol_name} Cross VAL", last_bar_time, float(state.pending_cross_level), "Cross", "#ff9800", poc, vah, val) if send_images else None
                maybe_send(token, chat_id, caption, png, dry_run)
                state.pending_cross_type = None
                state.pending_cross_level = None
                state.pending_cross_created_at = None

    ph, pl = pivot_at(df, depth=depth, lb=lb)
    for pivot, is_high in [(ph, True), (pl, False)]:
        if pivot is None:
            continue
        pivot_time, pivot_price = pivot
        kind = "H" if is_high else "L"
        if state.seen_pivot_keys is None:
            state.seen_pivot_keys = []
        pivot_key = (pivot_time, kind)
        if pivot_key in state.seen_pivot_keys:
            continue

        label = structure_label_high(pivot_price, state.last_high_pivot_price) if is_high else structure_label_low(pivot_price, state.last_low_pivot_price)
        _append_pivot(state, pivot_time, float(pivot_price), label)
        state.seen_pivot_keys.append(pivot_key)
        if len(state.seen_pivot_keys) > 40:
            state.seen_pivot_keys = state.seen_pivot_keys[-40:]

        qm = detect_qm_pattern(state)
        if notify_qm and qm is not None:
            qm_kind, qm_points = qm
            qm_last_time = qm_points[-1][0] if qm_points else pivot_time
            if qm_kind == "M":
                if state.last_qm_m_time is None or qm_last_time > state.last_qm_m_time:
                    caption = build_qm_message(symbol_name, "M", last_close, tv_symbol)
                    png = render_qm_chart_png(symbol_name, df, "M", qm_points, poc, vah, val) if send_images else None
                    maybe_send(token, chat_id, caption, png, dry_run)
                    state.last_qm_m_time = qm_last_time
            else:
                if state.last_qm_w_time is None or qm_last_time > state.last_qm_w_time:
                    caption = build_qm_message(symbol_name, "W", last_close, tv_symbol)
                    png = render_qm_chart_png(symbol_name, df, "W", qm_points, poc, vah, val) if send_images else None
                    maybe_send(token, chat_id, caption, png, dry_run)
                    state.last_qm_w_time = qm_last_time

        if notify_hh_ll and label in ("HH", "LL") and (state.last_pivot_notify_time is None or pivot_time > state.last_pivot_notify_time):
            caption = build_hh_ll_message(symbol_name, label, float(pivot_price), pivot_time, last_close, tv_symbol)
            color = "#d32f2f" if label == "HH" else "#388e3c"
            png = render_chart_png(symbol_name, df, f"{symbol_name} {label}", pivot_time, float(pivot_price), label, color, poc, vah, val) if send_images else None
            maybe_send(token, chat_id, caption, png, dry_run)
            state.last_pivot_notify_time = pivot_time

        if is_high and label == "HH":
            if state.prev_hh_price is not None and state.prev_hh_time is not None and pivot_price > state.prev_hh_price:
                if vah is not None and np.isfinite(vah):
                    state.pending_cross_type = "HH"
                    state.pending_cross_level = float(vah)
                    state.pending_cross_created_at = pivot_time
            state.prev_hh_price = pivot_price
            state.prev_hh_time = pivot_time

        if (not is_high) and label == "LL":
            if state.prev_ll_price is not None and state.prev_ll_time is not None and pivot_price < state.prev_ll_price:
                if val is not None and np.isfinite(val):
                    state.pending_cross_type = "LL"
                    state.pending_cross_level = float(val)
                    state.pending_cross_created_at = pivot_time
            state.prev_ll_price = pivot_price
            state.prev_ll_time = pivot_time

        if is_high:
            state.last_high_pivot_price = pivot_price
        else:
            state.last_low_pivot_price = pivot_price
        state.last_pivot_time = pivot_time


def main() -> None:
    args = parse_args()
    token, chat_id = load_telegram_config(args.env_path)
    print("✅ yfinance_structure_bot_telegram_images AVVIATO")

    assets: Dict[str, Dict[str, Union[str, List[str]]]] = {
        "XAUUSD": {"yf": ["GC=F", "XAUUSD=X"], "tv": "OANDA:XAUUSD"},
        "EURUSD": {"yf": "EURUSD=X", "tv": "OANDA:EURUSD"},
        "GBPUSD": {"yf": "GBPUSD=X", "tv": "OANDA:GBPUSD"},
        "USDJPY": {"yf": "JPY=X", "tv": "OANDA:USDJPY"},
        "BTCUSD": {"yf": "BTC-USD", "tv": "COINBASE:BTCUSD"},
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
                    send_images=args.send_images,
                    notify_hh_ll=args.notify_hh_ll,
                    notify_touch=args.notify_touch,
                    notify_cross=args.notify_cross,
                    notify_qm=args.notify_qm,
                    notify_cisd=args.notify_cisd,
                    notify_london_break=args.notify_london_break,
                    respect_market_hours=args.respect_market_hours,
                    session_tz_offset_hours=args.session_tz_offset_hours,
                    asia_start_hour=args.asia_start_hour,
                    asia_end_hour=args.asia_end_hour,
                    london_start_hour=args.london_start_hour,
                    london_end_hour=args.london_end_hour,
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
