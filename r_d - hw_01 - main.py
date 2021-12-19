import requests as rq
import json
import os

import datetime
from datetime import date

from requests.exceptions import RequestException

from config import Config


def app():

    config = Config("./config.yaml").get_config()
    headers = {"content-type": config['content-type']}
    data = {"username": config['username'], "password": config['password']}

    try:
        r = rq.post(config['url_auth'], headers=headers, data=json.dumps(data))
        token = r.json()['access_token']

    except RequestException:
        print("Got an error during receiving token")

    process_date = datetime.date(config['year_start'], config['month_start'], config['day_start'])

    # ATTENTION!!!! WHILE!!!!!!!!!!!

    while process_date != date.today() + datetime.timedelta(days=1):
        headers = {"content-type": config['content-type']
                    , "Authorization": config['Authorization'] + token}
        data = {"date": str(process_date)}

        try:
            r = rq.get(config['url_out_of_stock'], headers=headers, data=json.dumps(data))
            r.raise_for_status()
            data = r.json()
            path_to_dir = os.path.join('.', 'data', str(process_date))
            os.makedirs(path_to_dir, exist_ok=True)
            with open(os.path.join(path_to_dir, config['filename']), 'w') as json_file:
                json.dump(data, json_file)

        except RequestException:
            print(str(process_date) + " - Got an error during receiving data")

        process_date += datetime.timedelta(days=1)


if __name__ == '__main__':
    app()
