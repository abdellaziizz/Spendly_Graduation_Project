import requests
import json

URL = 'http://127.0.0.1:5000/api/predictions/predict-overrun'
PAYLOAD = {
    "currentSpending": 500,
    "budgetLimit": 1000,
    "expenses": [],
    "daysInMonth": 30,
    "currentDay": 15
}

def main():
    try:
        r = requests.post(URL, json=PAYLOAD, timeout=10)
        print('STATUS', r.status_code)
        try:
            print(json.dumps(r.json(), indent=2))
        except Exception:
            print('RAW:', r.text)
    except Exception as e:
        print('ERROR', e)

if __name__ == '__main__':
    main()
