import requests
import time

# === НАСТРОЙКИ ===

AVITO_CLIENT_ID = YFOR-7enZaCes5PWG9yP
AVITO_CLIENT_SECRET = 616t8gSsm8odXj-lkVVqNAQdh6Oo6ms-OSOB4v8z

TELEGRAM_BOT_TOKEN = 8339113185:AAHR_8DALrAXaFB8bstARYY16z2pfF-MP80
TELEGRAM_CHAT_ID = 639306010

POLL_INTERVAL = 30  # секунд между проверками

# === ФУНКЦИИ ===

def get_access_token():
    url = 'https://api.avito.ru/token/'
    data = {
        'grant_type': 'client_credentials',
        'client_id': AVITO_CLIENT_ID,
        'client_secret': AVITO_CLIENT_SECRET
    }
    response = requests.post(url, data=data)
    response.raise_for_status()
    return response.json()['access_token']

def get_messages(access_token):
    url = 'https://api.avito.ru/core/v1/messages'
    headers = {
        'Authorization': f'Bearer {access_token}'
    }
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()

def send_telegram_message(text):
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"
    data = {
        'chat_id': TELEGRAM_CHAT_ID,
        'text': text
    }
    requests.post(url, data=data)

# === ОСНОВНОЙ ЦИКЛ ===

def main():
    last_message_ids = set()
    access_token = get_access_token()
    
    while True:
        try:
            messages = get_messages(access_token)
            for thread in messages.get('messages', []):
                msg_id = thread['id']
                if msg_id not in last_message_ids:
                    last_message_ids.add(msg_id)
                    text = f"Новое сообщение от {thread['user']['name']}:\n{thread['last_message']['text']}"
                    send_telegram_message(text)
            
            time.sleep(POLL_INTERVAL)

        except Exception as e:
            print(f"Ошибка: {e}")
            # Пробуем обновить токен на случай ошибки авторизации
            try:
                access_token = get_access_token()
            except:
                pass
            time.sleep(10)

if name == 'main':
    main()