import os
import logging
import json
import time
import random as rd

from kafka import KafkaProducer
from kafka.errors import KafkaError


BOOTSTRAP_SERVER = os.getenv('BOOTSTRAP_SERVER')
TOPIC = os.getenv('TOPIC')
PRODUCER_ID = os.getenv('PRODUCER_ID')
DELAY_MIN = 0.1
DELAY_MAX = 1

logging.basicConfig(level=logging.INFO)


def run():
    producer = KafkaProducer(
        bootstrap_servers=[BOOTSTRAP_SERVER],
        value_serializer=lambda m: json.dumps(m).encode('ascii'),
        request_timeout_ms=120000)

    while True:
        producer.send(topic=TOPIC, value={
            'producer_id': PRODUCER_ID,
            'value': rd.uniform(-100.0, 100.0),
            'ts': time.time()
        })
        producer.flush()
        time.sleep(rd.uniform(DELAY_MIN, DELAY_MAX))


if __name__ == '__main__':
    run()