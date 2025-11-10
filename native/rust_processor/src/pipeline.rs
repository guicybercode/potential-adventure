#[allow(dead_code)]
pub trait Normalizer {
    fn normalize(&self, data: &[u8]) -> Result<Vec<u8>, String>;
}

#[allow(dead_code)]
pub trait Aggregator {
    fn aggregate(&mut self, data: &[u8]) -> Result<Vec<u8>, String>;
}

#[allow(dead_code)]
pub trait AnomalyDetector {
    fn detect(&self, data: &[u8]) -> Result<bool, String>;
}

