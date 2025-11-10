use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Trade {
    pub symbol: String,
    pub price: f64,
    pub quantity: f64,
    pub timestamp: i64,
    pub side: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OHLC {
    pub symbol: String,
    pub open: f64,
    pub high: f64,
    pub low: f64,
    pub close: f64,
    pub volume: f64,
    pub window_start: i64,
    pub window_end: i64,
}

pub struct SlidingWindowAggregator {
    window_size_ms: i64,
    windows: std::collections::HashMap<String, Vec<Trade>>,
}

impl SlidingWindowAggregator {
    pub fn new(window_size_ms: i64) -> Self {
        Self {
            window_size_ms,
            windows: std::collections::HashMap::new(),
        }
    }

    pub fn add_trade(&mut self, trade: Trade) {
        let window_key = (trade.timestamp / self.window_size_ms) * self.window_size_ms;
        let key = format!("{}_{}", trade.symbol, window_key);
        
        self.windows
            .entry(key)
            .or_insert_with(Vec::new)
            .push(trade);
    }

    pub fn get_ohlc(&self, symbol: &str, window_start: i64) -> Option<OHLC> {
        let key = format!("{}_{}", symbol, window_start);
        let trades = self.windows.get(&key)?;

        if trades.is_empty() {
            return None;
        }

        let open = trades[0].price;
        let mut high = trades[0].price;
        let mut low = trades[0].price;
        let close = trades[trades.len() - 1].price;
        let mut volume = 0.0;

        for trade in trades {
            if trade.price > high {
                high = trade.price;
            }
            if trade.price < low {
                low = trade.price;
            }
            volume += trade.quantity;
        }

        Some(OHLC {
            symbol: symbol.to_string(),
            open,
            high,
            low,
            close,
            volume,
            window_start,
            window_end: window_start + self.window_size_ms,
        })
    }

    pub fn cleanup_old_windows(&mut self, current_time: i64, keep_windows: i64) {
        let cutoff = current_time - (self.window_size_ms * keep_windows);
        self.windows.retain(|k, _| {
            if let Some((_, ts_str)) = k.rsplit_once('_') {
                if let Ok(ts) = ts_str.parse::<i64>() {
                    return ts >= cutoff;
                }
            }
            false
        });
    }

    pub fn get_windows_keys(&self) -> Vec<String> {
        self.windows.keys().cloned().collect()
    }
}

