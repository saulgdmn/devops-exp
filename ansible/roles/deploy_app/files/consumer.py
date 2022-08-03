import os
import logging
import json
import time
import random as rd
from pymongo import MongoClient

from kafka import KafkaConsumer
from kafka.errors import KafkaError


BOOTSTRAP_SERVER = os.getenv('BOOTSTRAP_SERVER')
MONGO_URI = os.getenv('MONGO_URI')
MONGO_DATABASE = os.getenv('MONGO_DATABASE')
MONGO_COLLECTION = os.getenv('MONGO_COLLECTION')
TOPIC = os.getenv('TOPIC')
CONSUMER_ID = os.getenv('CONSUMER_ID')

logging.basicConfig(level=logging.INFO)


def run():
    consumer = KafkaConsumer(
        bootstrap_servers=[BOOTSTRAP_SERVER],
        group_id=f'ConsumerGroup-{CONSUMER_ID}',
        value_deserializer=lambda v: json.loads(v),
        enable_auto_commit=True)

    mc = MongoClient(MONGO_URI)
    col = mc[MONGO_DATABASE][MONGO_COLLECTION]

    consumer.subscribe([TOPIC])
    for msg in consumer:
        value = msg.value
        logging.info(f'Consumed: {value}')
        col.insert_one(value)


if __name__ == '__main__':
    run()