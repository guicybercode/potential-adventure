import json
import time
import random
from kafka import KafkaProducer
import os

producer = KafkaProducer(
    bootstrap_servers=os.getenv('KAFKA_BROKERS', 'localhost:9092').split(','),
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

topic = os.getenv('TOPIC', 'trades')
symbols = ['BTCUSD', 'ETHUSD', 'SOLUSD', 'ADAUSD']

base_prices = {
    'BTCUSD': 45000.0,
    'ETHUSD': 3000.0,
    'SOLUSD': 100.0,
    'ADAUSD': 0.5
}

while True:
    symbol = random.choice(symbols)
    base_price = base_prices[symbol]
    price = base_price + random.uniform(-500, 500)
    quantity = random.uniform(0.1, 10.0)
    timestamp = int(time.time() * 1000)
    side = random.choice(['buy', 'sell'])

    trade = {
        'symbol': symbol,
        'price': round(price, 2),
        'quantity': round(quantity, 4),
        'timestamp': timestamp,
        'side': side
    }

    producer.send(topic, value=trade)
    print(f"Sent: {trade}")
    time.sleep(0.1)

