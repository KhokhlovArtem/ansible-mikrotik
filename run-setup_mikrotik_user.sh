#!/bin/bash
cd "$(dirname "$0")"

# Загружаем .env (убираем export)
if [ -f .env ]; then
    set -a
    source .env
    set +a
else
    echo "❌ Файл .env не найден!"
    exit 1
fi

echo "✅ Переменные загружены"
echo "👤 MikroTik пользователь: $MIKROTIK_USER"

# Запуск playbook
ansible-playbook -i inventory.ini setup_mikrotik_user.yml \
    -e "mikrotik_user=$MIKROTIK_USER" \
    -e "mikrotik_password=$MIKROTIK_PASSWORD" \
    -e "ansible_user_password=$ANSIBLE_USER_PASSWORD" \
    "$@"
