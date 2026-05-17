import json
import urllib.request

url = 'http://127.0.0.1:5001/api/predictions/generate-report'
payload = {
    "userId": "test-user",
    "expenses": [
        {"date": "2026-05-01T00:00:00", "amount": 120.5, "category": "food", "description": "groceries"},
        {"date": "2026-05-02T00:00:00", "amount": 45.0, "category": "transport", "description": "taxi"}
    ],
    "budgets": {"food": 300, "transport": 100},
    "currentSpending": {"food": 120.5, "transport": 45.0},
    "historicalMonthly": [300, 250, 280],
    "daysInMonth": 31,
    "currentDay": 16,
    "goals": [{"title": "Vacation", "currentAmount": 200, "targetAmount": 1000, "progress": 0.2}]
}

data = json.dumps(payload).encode('utf-8')
req = urllib.request.Request(url, data=data, headers={'Content-Type': 'application/json'})

try:
    with urllib.request.urlopen(req, timeout=20) as resp:
        body = resp.read().decode('utf-8')
        print('STATUS', resp.status)
        print('BODY', body)
except Exception as e:
    print('ERROR', e)
