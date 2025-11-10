use rustler::{Env, NifResult, Error};
use rustler::resource::ResourceArc;
use std::sync::Mutex;

mod pipeline;
mod aggregation;
mod anomaly;

rustler::init!(
    "Elixir.RustProcessor",
    [
        aggregate_trades,
        detect_anomalies,
        create_aggregator,
        create_detector
    ],
    load = on_load
);

struct AggregatorResource {
    inner: Mutex<aggregation::SlidingWindowAggregator>,
}

struct DetectorResource {
    inner: Mutex<anomaly::ZScoreDetector>,
}

fn on_load(_env: Env, _info: rustler::Term) -> bool {
    rustler::resource!(AggregatorResource, _env);
    rustler::resource!(DetectorResource, _env);
    true
}

#[rustler::nif]
fn create_aggregator(window_size_ms: i64) -> NifResult<ResourceArc<AggregatorResource>> {
    let aggregator = aggregation::SlidingWindowAggregator::new(window_size_ms);
    Ok(ResourceArc::new(AggregatorResource {
        inner: Mutex::new(aggregator),
    }))
}

#[rustler::nif]
fn aggregate_trades(
    env: Env,
    resource: ResourceArc<AggregatorResource>,
    trades_json: String,
) -> NifResult<String> {
    let trades: Vec<aggregation::Trade> = match serde_json::from_str(&trades_json) {
        Ok(t) => t,
        Err(_e) => {
            return Err(Error::RaiseTerm(Box::new("invalid_json")));
        }
    };

    let mut aggregator = resource.inner.lock().unwrap();
    
    for trade in trades {
        aggregator.add_trade(trade);
    }

    let current_time = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_millis() as i64;

    aggregator.cleanup_old_windows(current_time, 10);

    let mut results = Vec::new();
    let windows_keys: Vec<String> = aggregator.get_windows_keys();
    for key in windows_keys {
        if let Some((symbol, ts_str)) = key.rsplit_once('_') {
            if let Ok(window_start) = ts_str.parse::<i64>() {
                if let Some(ohlc) = aggregator.get_ohlc(symbol, window_start) {
                    results.push(ohlc);
                }
            }
        }
    }

    match serde_json::to_string(&results) {
        Ok(json) => Ok(json),
        Err(_e) => {
            Err(Error::RaiseTerm(Box::new("serialization_error")))
        }
    }
}

#[rustler::nif]
fn create_detector(threshold: f64, max_history: usize) -> NifResult<ResourceArc<DetectorResource>> {
    let detector = anomaly::ZScoreDetector::new(threshold, max_history);
    Ok(ResourceArc::new(DetectorResource {
        inner: Mutex::new(detector),
    }))
}

#[rustler::nif]
fn detect_anomalies(
    env: Env,
    resource: ResourceArc<DetectorResource>,
    trade_json: String,
) -> NifResult<String> {
    let trade: aggregation::Trade = match serde_json::from_str(&trade_json) {
        Ok(t) => t,
        Err(_e) => {
            return Err(Error::RaiseTerm(Box::new("invalid_json")));
        }
    };

    let mut detector = resource.inner.lock().unwrap();
    let result = detector.detect(&trade);

    match serde_json::to_string(&result) {
        Ok(json) => Ok(json),
        Err(_e) => {
            Err(Error::RaiseTerm(Box::new("serialization_error")))
        }
    }
}
