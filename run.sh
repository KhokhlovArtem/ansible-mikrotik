#!/bin/bash
cd "$(dirname "$0")"

# Загружаем .env
if [ -f .env ]; then
    set -a
    source .env
    set +a
else
    echo "❌ Файл .env не найден!"
    exit 1
fi

echo "✅ Переменные загружены из .env"
echo "👤 Администратор: $MIKROTIK_USER"
echo "👤 Меняем пароль для: $USER_CHANGE_PASSWORD"
echo "🔐 Новый пароль: ***"

# Проверка что USER_CHANGE_PASSWORD задан
if [ -z "$USER_CHANGE_PASSWORD" ]; then
    echo "❌ ОШИБКА: USER_CHANGE_PASSWORD не задан в .env"
    exit 1
fi

# Запуск playbook
ansible-playbook -i inventory.ini change_user_password.yml \
    -e "mikrotik_user=$MIKROTIK_USER" \
    -e "mikrotik_password=$MIKROTIK_PASSWORD" \
    -e "ansible_user_password=$ANSIBLE_USER_PASSWORD" \
    -e "user_change_password=$USER_CHANGE_PASSWORD" \
    "$@"
