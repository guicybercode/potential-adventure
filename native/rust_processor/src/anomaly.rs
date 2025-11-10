use super::aggregation::Trade;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AnomalyResult {
    pub is_anomaly: bool,
    pub z_score: f64,
    pub threshold: f64,
}

pub struct ZScoreDetector {
    threshold: f64,
    price_history: std::collections::VecDeque<f64>,
    max_history: usize,
}

impl ZScoreDetector {
    pub fn new(threshold: f64, max_history: usize) -> Self {
        Self {
            threshold,
            price_history: std::collections::VecDeque::with_capacity(max_history),
            max_history,
        }
    }

    pub fn detect(&mut self, trade: &Trade) -> AnomalyResult {
        if self.price_history.len() < 10 {
            self.price_history.push_back(trade.price);
            return AnomalyResult {
                is_anomaly: false,
                z_score: 0.0,
                threshold: self.threshold,
            };
        }

        let mean = self.price_history.iter().sum::<f64>() / self.price_history.len() as f64;
        let variance = self.price_history
            .iter()
            .map(|p| (p - mean).powi(2))
            .sum::<f64>()
            / self.price_history.len() as f64;
        let std_dev = variance.sqrt();

        if std_dev == 0.0 {
            self.price_history.push_back(trade.price);
            if self.price_history.len() > self.max_history {
                self.price_history.pop_front();
            }
            return AnomalyResult {
                is_anomaly: false,
                z_score: 0.0,
                threshold: self.threshold,
            };
        }

        let z_score = (trade.price - mean) / std_dev;
        let is_anomaly = z_score.abs() > self.threshold;

        self.price_history.push_back(trade.price);
        if self.price_history.len() > self.max_history {
            self.price_history.pop_front();
        }

        AnomalyResult {
            is_anomaly,
            z_score,
            threshold: self.threshold,
        }
    }
}

