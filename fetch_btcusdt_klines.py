import requests
import datetime
import csv


def fetch_data(date):
    base_url = "https://api.binance.com/api/v3/klines"
    symbol = "BTCUSDT"
    interval = "1m"
    start_str = f"{date} 00:00:00"
    end_str = f"{date} 23:59:59"
    start_time = int(datetime.datetime.strptime(
        start_str, "%Y.%m.%d %H:%M:%S").timestamp() * 1000)
    end_time = int(datetime.datetime.strptime(
        end_str, "%Y.%m.%d %H:%M:%S").timestamp() * 1000)
    params = {
        'symbol': symbol,
        'interval': interval,
        'startTime': start_time,
        'endTime': end_time,
        'limit': 1000
    }
    response = requests.get(base_url, params=params)
    if response.status_code == 200:
        return response.json()
    else:
        return None


def save_to_file(data, filename):
    with open(filename, 'a', newline='') as file:
        for line in data:
            time = datetime.datetime.fromtimestamp(line[0] / 1000)
            formatted_time = time.strftime('%Y%m%d,%H%M%S')
            formatted_line = f"{formatted_time},{float(line[1]):.2f},{float(line[2]):.2f},{
                float(line[3]):.2f},{float(line[4]):.2f}\n"
            file.write(formatted_line)


def process_daily_data(start_date, end_date, filename):
    current_date = start_date
    while current_date <= end_date:
        data = fetch_data(current_date.strftime("%Y.%m.%d"))
        if data:
            save_to_file(data, filename)
            print(f"已获取 {current_date.strftime('%Y.%m.%d')} 的数据")
        else:
            print(f"无法获取 {current_date.strftime('%Y.%m.%d')} 的数据，请稍后再试。")
        current_date += datetime.timedelta(days=1)


start_date = datetime.datetime(2023, 12, 1)
end_date = datetime.datetime(2024, 2, 6)
filename = "get_all_data.txt"

open(filename, 'w').close()

process_daily_data(start_date, end_date, filename)
