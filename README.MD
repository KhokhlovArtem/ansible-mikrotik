# 🖧 MikroTik Ansible Automation

Автоматизация управления пользователями и ротации паролей на роутерах MikroTik RouterOS через Ansible.

## 📋 Оглавление

- [Возможности](#-возможности)
- [Структура проекта](#-структура-проекта)
- [Требования](#-требования)
- [Установка](#-установка)
- [Настройка](#-настройка)
- [Использование](#-использование)
- [Playbooks](#-playbooks)
- [Безопасность](#-безопасность)
- [Устранение неполадок](#-устранение-неполадок)
- [Roadmap](#-roadmap)

## ✨ Возможности

- ✅ Создание и обновление пользователей на MikroTik через Ansible
- ✅ Кросс-обновление паролей (взаимная смена паролей между пользователями)
- ✅ Смена пароля конкретному пользователю
- ✅ Параллельная работа с несколькими роутерами
- ✅ Идемпотентность (безопасный повторный запуск)
- ✅ Безопасное хранение паролей через `.env`
- ✅ Поддержка MikroTik RouterOS 6.x

## 📁 Структура проекта

```
mikrotik-ansible/
├── .env                         # Конфигурация (не коммитится!)
├── .gitignore                   # Игнорируемые файлы
├── ansible.cfg                  # Настройки Ansible
├── inventory.ini                # Инвентарь с роутерами
├── README.md                    # Документация
├
├── run-setup_mikrotik_user.sh   # Скрипт запуска кросс-обновления
├── setup_mikrotik_user.yml      # Playbook: кросс-обновление
├
├── run-change_user_password.sh  # Скрипт смены пароля пользователя
└── change_user_password.yml     # Playbook: смена пароля
```

## 🔧 Требования

- **Ansible**: версия 2.10+ (рекомендуется 2.17+)
- **sshpass**: для автоматизации SSH-подключений
- **MikroTik RouterOS**: версия 6.x
- **Доступ по SSH** к роутерам

### Установка зависимостей

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install ansible -y
sudo pip update ansible
sudo apt install sshpass -y

```

## ⚙️ Настройка

### 1. Клонирование репозитория

```bash
git clone https://github.com/KhokhlovArtem/ansible-mikrotik.git
cd mikrotik-ansible
```

### 2. Настройка инвентаря (`inventory.ini`)

```ini
[routers]
router1 ansible_host=10.1.1.1
router2 ansible_host=10.1.1.2
router3 ansible_host=10.1.1.3

[routers:vars]
ansible_connection=ssh
```

### 3. Настройка переменных окружения (`.env`)

```bash
# Скопируйте пример
cp .env.example .env

# Отредактируйте .env
nano .env
```

## 🚀 Использование

### Playbook 1: Кросс-обновление пользователей

Создает/обновляет пользователей `ansible_user01` и `ansible_user02` с взаимной сменой паролей.

```bash
# Даем права на выполнение
chmod +x run-setup_mikrotik_usersh.sh

# Запуск
./run-setup_mikrotik_usersh.sh

# С подробным выводом
./run-setup_mikrotik_usersh.sh -v

# Проверка без изменений (dry-run)
./run-setup_mikrotik_usersh.sh --check
```

### Playbook 2: Смена пароля конкретному пользователю

Меняет пароль указанному в `.env` пользователю.

```bash
chmod +x run-change_user_password.sh
./run-change_user_password.sh
```

## 📜 Playbooks

### `setup_mikrotik_user.yml` - Кросс-обновление

**Что делает:**
1. Вход под `MIKROTIK_USER` (должен иметь гарантированные права на вход, для регулярного обновления используй ansible_user01)
2. Создание/обновление `ansible_user02` с новым паролем
3. Вход под `ansible_user02` и обновление пароля `ansible_user01`
4. Проверка доступа обоих пользователей

**Результат:** Оба пользователя имеют одинаковый новый пароль

### `change_user_password.yml` - Смена пароля

**Что делает:**
1. Проверка: указан ли пользователь
2. Проверка: существует ли пользователь на роутере
3. Смена пароля
4. Проверка входа с новым паролем
5. Вывод списка всех пользователей

## 🔒 Безопасность

### Хранение паролей

- ✅ Пароли хранятся **только** в `.env`
- ✅ `.env` добавлен в `.gitignore`
- ✅ Использование `no_log: true` в playbook

### Рекомендации

1. **Никогда не коммитьте `.env` в Git**
2. Используйте сложные пароли (буквы + цифры, без спецсимволов для RouterOS 6.x)
3. Ограничьте доступ к файлам:
   ```bash
   chmod 600 .env
   chmod 700 *.sh
   ```
4. Регулярно меняйте пароли через playbook

### Пример безопасного пароля для RouterOS

```bash
# Допустимые символы: a-z, A-Z, 0-9
ANSIBLE_USER_PASSWORD="X7kP9mR2qW5nL8tY3vS6"
```

## 🔧 Устранение неполадок

### Ошибка: `Permission denied`

**Причина:** Неверный пароль или пользователь
**Решение:** Проверьте `MIKROTIK_PASSWORD` в `.env`

### Ошибка: `expected end of command`

**Причина:** Спецсимволы в пароле
**Решение:** Используйте только буквы и цифры в пароле

### Ошибка: `user with the same name already exists`

**Причина:** Пользователь уже существует (не ошибка, нормальное поведение)
**Решение:** Playbook обновит пароль существующего пользователя

### Ошибка: `Connection refused`

**Причина:** MikroTik не доступен по SSH
**Решение:**
```bash
# Проверка вручную
ssh admin@10.1.1.1

# На роутере включите SSH
/ip service enable ssh
/ip service set ssh port=22
```

### Логирование

```bash
# Запуск с максимальным выводом
./run.sh -vvv > ansible.log 2>&1
```

## 📈 Roadmap

- [ ] Поддержка RouterOS 7.x
- [ ] Управление через API (REST)
- [ ] Шифрование `.env` через `ansible-vault`
- [ ] Интеграция с HashiCorp Vault
- [ ] Telegram/Slack уведомления
- [ ] Генерация отчетов
- [ ] Управление SSH-ключами
- [ ] Ротация паролей по расписанию (cron/systemd timer)

## 📝 Примеры

### Пример 1: Первоначальная настройка

```bash
# 1. Настройте .env
MIKROTIK_USER=admin
MIKROTIK_PASSWORD="admin123"
ANSIBLE_USER_PASSWORD="NewStrongPass2024"

# 2. Запустите кросс-обновление
./run.sh

# 3. После успеха, обновите .env
MIKROTIK_USER=ansible_user01
MIKROTIK_PASSWORD="NewStrongPass2024"
```

### Пример 2: Ежеквартальная ротация паролей

```bash
# 1. Сгенерируйте новый пароль
NEW_PASS=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-20)

# 2. Обновите .env
sed -i "s/ANSIBLE_USER_PASSWORD=.*/ANSIBLE_USER_PASSWORD=\"$NEW_PASS\"/" .env

# 3. Запустите обновление
./run.sh

# 4. Оповестите команду (через любую систему уведомлений)
```

### Пример 3: Смена пароля конкретному пользователю

```bash
# 1. В .env укажите USER_CHANGE_PASSWORD
USER_CHANGE_PASSWORD=admin

# 2. Запустите
./change_pass.sh
```

## 🤝 Вклад в проект

1. Форкните репозиторий
2. Создайте ветку (`git checkout -b feature/amazing-feature`)
3. Зафиксируйте изменения (`git commit -m 'Add amazing feature'`)
4. Отправьте в ветку (`git push origin feature/amazing-feature`)
5. Откройте Pull Request