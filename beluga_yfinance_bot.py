import argparse
import json
import os
import time
from dataclasses import dataclass
from typing import Any, Dict, Optional, Tuple

import numpy as np
import pandas as pd
import requests
import yfinance as yf
from dotenv import load_dotenv


@dataclass
class BelugaSignal:
    kind: str
    pivot_time: pd.Timestamp
    pivot_price: float
    confirm_time: pd.Timestamp


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--env-path", default="/Users/dev1/Desktop/dev/dev/trading/.env")
    p.add_argument("--symbol", default="XAUUSD=X")
    p.add_argument("--symbols", default="")
    p.add_argument("--display-symbol", default="XAUUSD")
    p.add_argument("--interval", default="1m", choices=["1m", "5m", "15m", "60m", "240m", "1d"])
    p.add_argument("--preset", default="Custom", choices=["Custom", "Bilanciato", "Veloce", "Conservativo"])
    p.add_argument("--length", type=int, default=50)
    p.add_argument("--poll-seconds", type=int, default=20)
    p.add_argument("--state-path", default="/Users/dev1/Desktop/dev/dev/trading/.beluga_yf_state.json")
    p.add_argument("--force", action="store_true")
    p.add_argument("--test-telegram", action="store_true")
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--once", action="store_true")
    return p.parse_args()


def load_telegram_config(env_path: str, dry_run: bool) -> Tuple[str, str]:
    load_dotenv(dotenv_path=env_path)
    token = os.getenv("TELEGRAM_TOKEN")
    chat_id = os.getenv("TELEGRAM_CHAT_ID")
    if dry_run and (not token or not chat_id):
        return "", ""
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
    try:
        data = resp.json()
        if not bool(data.get("ok", False)):
            raise RuntimeError(f"Telegram sendMessage not ok: {str(data)[:300]}")
    except ValueError:
        raise RuntimeError(f"Telegram sendMessage invalid JSON: {resp.text[:200]}")


def tv_link(tv_symbol: str) -> str:
    sym = (tv_symbol or "").strip()
    if not sym:
        return ""
    return f"https://www.tradingview.com/chart/?symbol={sym.replace(':', '%3A')}"


def preset_len(preset: str, interval: str, fallback: int) -> int:
    if preset == "Bilanciato":
        return {"1m": 50, "5m": 50, "15m": 50, "60m": 50, "240m": 50, "1d": 50}.get(interval, fallback)
    if preset == "Veloce":
        return {"1m": 30, "5m": 35, "15m": 35, "60m": 40, "240m": 50, "1d": 50}.get(interval, fallback)
    if preset == "Conservativo":
        return {"1m": 80, "5m": 70, "15m": 70, "60m": 60, "240m": 70, "1d": 70}.get(interval, fallback)
    return fallback


def choose_period(interval: str) -> str:
    if interval in {"1m", "5m", "15m"}:
        return "7d"
    if interval in {"60m", "240m"}:
        return "60d"
    return "730d"


def load_state(path: str) -> Dict[str, Any]:
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        return {}
    except Exception:
        return {}


def save_state(path: str, state: Dict[str, Any]) -> None:
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(state, f, ensure_ascii=False, indent=2)
    os.replace(tmp, path)


def _isclose(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    return np.isclose(a, b, rtol=1e-10, atol=1e-10)


def compute_latest_signal(df: pd.DataFrame, length: int) -> Optional[BelugaSignal]:
    if df is None or df.empty:
        return None
    if len(df) < max(length + 2, 5):
        return None
    d = df.copy()
    d = d[["High", "Low"]].dropna()
    if len(d) < max(length + 2, 5):
        return None

    high = d["High"].to_numpy(dtype=float)
    low = d["Low"].to_numpy(dtype=float)
    h = pd.Series(high, index=d.index).rolling(length, min_periods=length).max().to_numpy(dtype=float)
    l = pd.Series(low, index=d.index).rolling(length, min_periods=length).min().to_numpy(dtype=float)

    swing_high = _isclose(np.roll(high, 1), np.roll(h, 1)) & (high < h)
    swing_low = _isclose(np.roll(low, 1), np.roll(l, 1)) & (low > l)
    swing_high[0] = False
    swing_low[0] = False

    i = len(d) - 1
    if not (swing_high[i] or swing_low[i]):
        return None

    pivot_i = i - 1
    pivot_time = d.index[pivot_i]
    confirm_time = d.index[i]
    if swing_high[i]:
        return BelugaSignal("BB SWING HIGH", pivot_time, float(high[pivot_i]), confirm_time)
    return BelugaSignal("BB SWING LOW", pivot_time, float(low[pivot_i]), confirm_time)


def compute_last_signal(df: pd.DataFrame, length: int, lookback_bars: int = 500) -> Optional[BelugaSignal]:
    if df is None or df.empty:
        return None
    d = df.copy()
    d = d[["High", "Low"]].dropna()
    if d.empty:
        return None
    if lookback_bars > 0 and len(d) > lookback_bars:
        d = d.tail(lookback_bars).copy()
    if len(d) < max(length + 2, 5):
        return None

    high = d["High"].to_numpy(dtype=float)
    low = d["Low"].to_numpy(dtype=float)
    h = pd.Series(high, index=d.index).rolling(length, min_periods=length).max().to_numpy(dtype=float)
    l = pd.Series(low, index=d.index).rolling(length, min_periods=length).min().to_numpy(dtype=float)

    swing_high = _isclose(np.roll(high, 1), np.roll(h, 1)) & (high < h)
    swing_low = _isclose(np.roll(low, 1), np.roll(l, 1)) & (low > l)
    swing_high[0] = False
    swing_low[0] = False

    idxs = np.where(swing_high | swing_low)[0]
    if idxs.size == 0:
        return None
    i = int(idxs[-1])
    if i - 1 < 0:
        return None
    pivot_i = i - 1
    pivot_time = d.index[pivot_i]
    confirm_time = d.index[i]
    if bool(swing_high[i]):
        return BelugaSignal("BB SWING HIGH", pivot_time, float(high[pivot_i]), confirm_time)
    return BelugaSignal("BB SWING LOW", pivot_time, float(low[pivot_i]), confirm_time)


def format_price(symbol_name: str, price: float) -> str:
    if symbol_name.upper() == "XAUUSD":
        return f"{price:.2f}"
    return f"{price:.5f}"


def format_ts_italy(ts: pd.Timestamp) -> str:
    try:
        t = ts.tz_convert("Europe/Rome")
    except Exception:
        t = ts.tz_localize("UTC").tz_convert("Europe/Rome") if ts.tzinfo is None else ts
    return t.strftime("%Y-%m-%d %H:%M:%S")


def main() -> None:
    args = parse_args()
    token, chat_id = load_telegram_config(args.env_path, args.dry_run)

    length = preset_len(args.preset, args.interval, args.length)
    period = choose_period(args.interval)

    tv_symbol = os.getenv("TV_SYMBOL", "").strip()
    if not tv_symbol and args.display_symbol.strip():
        tv_symbol = f"OANDA:{args.display_symbol.strip().upper()}"
    tv_url = tv_link(tv_symbol)

    state = load_state(args.state_path)
    last_high = state.get("last_swing_high_time")
    last_low = state.get("last_swing_low_time")
    bad_symbols = set(state.get("bad_symbols", []))

    if args.test_telegram:
        msg = f"Beluga bot online ({args.display_symbol}) interval={args.interval} preset={args.preset} len={length}"
        if tv_url:
            msg += f"\nTV: {tv_url}"
        send_telegram(token, chat_id, msg, args.dry_run)
        if not args.dry_run:
            print("Telegram OK: test-telegram inviato")
        if args.once:
            return

    if args.symbols.strip():
        candidates = [s.strip() for s in args.symbols.split(",") if s.strip()]
    else:
        candidates = [args.symbol]
        if args.display_symbol.upper() == "XAUUSD" and args.symbol == "XAUUSD=X":
            candidates = ["GC=F", "XAUUSD=X", "XAU=X"]

    candidates = [s for s in candidates if s not in bad_symbols]
    if not candidates:
        candidates = [args.symbol]

    while True:
        try:
            df = None
            used_symbol = None
            last_error: Optional[Exception] = None

            for sym in candidates:
                try:
                    df_try = yf.download(
                        tickers=sym,
                        period=period,
                        interval=args.interval,
                        progress=False,
                        auto_adjust=False,
                        group_by="column",
                        threads=False,
                    )
                    if df_try is None or df_try.empty:
                        if sym.endswith("=X"):
                            bad_symbols.add(sym)
                            continue
                        try:
                            df_try = yf.Ticker(sym).history(period=period, interval=args.interval, auto_adjust=False)
                        except Exception:
                            df_try = None
                        if df_try is None or df_try.empty:
                            bad_symbols.add(sym)
                            continue
                    if isinstance(df_try.columns, pd.MultiIndex):
                        df_try.columns = [c[0] for c in df_try.columns]
                    df_try.index = pd.to_datetime(df_try.index)
                    if not {"High", "Low"}.issubset(set(df_try.columns)):
                        bad_symbols.add(sym)
                        continue
                    df = df_try
                    used_symbol = sym
                    break
                except Exception as e:
                    last_error = e
                    bad_symbols.add(sym)
                    continue

            if df is None or used_symbol is None:
                if last_error is not None:
                    raise last_error
                raise RuntimeError(f"Nessun dato disponibile da Yahoo per: {', '.join(candidates)}")

            if bad_symbols != set(state.get("bad_symbols", [])):
                state["bad_symbols"] = sorted(bad_symbols)
                save_state(args.state_path, state)

            if args.dry_run:
                try:
                    last_ts = pd.to_datetime(df.index[-1])
                    print(f"Yahoo:{used_symbol} interval={args.interval} bars={len(df)} last={last_ts}")
                except Exception:
                    print(f"Yahoo:{used_symbol} interval={args.interval} bars={len(df)}")

            sig = compute_last_signal(df, length)
            if sig is not None:
                pivot_key = str(sig.pivot_time)
                if sig.kind == "BB SWING HIGH":
                    is_new = (pivot_key != last_high)
                    if args.dry_run:
                        print(f"Ultimo segnale: {sig.kind} pivot={sig.pivot_time} confirm={sig.confirm_time} new={is_new}")
                    if args.force or is_new:
                        msg = (
                            f"{sig.kind} {args.display_symbol} (Yahoo:{used_symbol} {args.interval}, len={length})\n"
                            f"Pivot: {format_ts_italy(sig.pivot_time)} @ {format_price(args.display_symbol, sig.pivot_price)}\n"
                            f"Conferma: {format_ts_italy(sig.confirm_time)}"
                        )
                        if tv_url:
                            msg += f"\nTV: {tv_url}"
                        send_telegram(token, chat_id, msg, args.dry_run)
                        last_high = pivot_key
                        state["last_swing_high_time"] = last_high
                        save_state(args.state_path, state)
                else:
                    is_new = (pivot_key != last_low)
                    if args.dry_run:
                        print(f"Ultimo segnale: {sig.kind} pivot={sig.pivot_time} confirm={sig.confirm_time} new={is_new}")
                    if args.force or is_new:
                        msg = (
                            f"{sig.kind} {args.display_symbol} (Yahoo:{used_symbol} {args.interval}, len={length})\n"
                            f"Pivot: {format_ts_italy(sig.pivot_time)} @ {format_price(args.display_symbol, sig.pivot_price)}\n"
                            f"Conferma: {format_ts_italy(sig.confirm_time)}"
                        )
                        if tv_url:
                            msg += f"\nTV: {tv_url}"
                        send_telegram(token, chat_id, msg, args.dry_run)
                        last_low = pivot_key
                        state["last_swing_low_time"] = last_low
                        save_state(args.state_path, state)
            else:
                if args.dry_run:
                    print("Nessun segnale Beluga trovato nel lookback.")
        except Exception as e:
            err = f"Beluga yfinance error: {type(e).__name__}: {e}"
            send_telegram(token, chat_id, err, dry_run=args.dry_run)

        if args.once:
            return
        time.sleep(max(5, args.poll_seconds))


if __name__ == "__main__":
    main()
