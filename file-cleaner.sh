#!/bin/bash

# Проверяем, указан ли путь к .env файлу
if [ -z "$1" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Ошибка: Укажите путь к .env файлу." >> /tmp/file-cleaner-error.log
  exit 1
fi

ENV_FILE=$1

# Проверяем, существует ли файл .env
if [ ! -f "$ENV_FILE" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Ошибка: Файл .env не найден по указанному пути: $ENV_FILE" >> /tmp/file-cleaner-error.log
  exit 1
fi

# Загружаем переменные из указанного .env файла
export $(grep -v '^#' "$ENV_FILE" | xargs)

# Проверяем наличие необходимых переменных
if [ -z "$TARGET_DIR" ] || [ -z "$DAYS" ] || [ -z "$LOG_FILE" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Ошибка: В файле .env отсутствуют необходимые параметры (TARGET_DIR, DAYS или LOG_FILE)." >> /tmp/file-cleaner-error.log
  exit 1
fi

# Проверяем существование указанной папки
if [ ! -d "$TARGET_DIR" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Ошибка: Папка не найдена: $TARGET_DIR" >> "$LOG_FILE"
  exit 1
fi

# Логируем начало процесса
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Начало очистки файлов в папке $TARGET_DIR старше $DAYS дней." >> "$LOG_FILE"

# Удаляем файлы старше указанного количества дней
DELETED_FILES=$(find "$TARGET_DIR" -type f -mtime +$DAYS -exec rm -v {} \; 2>>"$LOG_FILE")

# Логируем завершение процесса
if [ -z "$DELETED_FILES" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Очистка завершена. Файлы для удаления не найдены." >> "$LOG_FILE"
else
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Очистка завершена. Удалены файлы:" >> "$LOG_FILE"
  echo "$DELETED_FILES" >> "$LOG_FILE"
fi

