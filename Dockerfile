# --- ЭТАП 1: Сборка проекта (Builder) ---
# Используем легковесный образ Node.js 22 на базе Alpine
FROM node:22-alpine AS builder

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файлы с зависимостями. Это важно для кэширования Docker.
COPY package.json package-lock.json ./

# Устанавливаем все зависимости, включая devDependencies, которые нужны для сборки
RUN npm install

# Копируем все остальные файлы проекта
COPY . .

# Собираем Nuxt-приложение для production.
# Эта команда создаст оптимизированную папку .output
RUN npm run build

# --- ЭТАП 2: Финальный образ (Production) ---
# Начинаем с такого же чистого и легковесного образа
FROM node:22-alpine

# Устанавливаем рабочую директорию
WORKDIR /app

# Устанавливаем переменную окружения для production.
# Это включает различные оптимизации в Nuxt и Node.js.
ENV NODE_ENV=production

# Копируем ТОЛЬКО результат сборки из этапа 'builder'.
# Весь исходный код и node_modules остаются в прошлом.
COPY --from=builder /app/.output ./.output

# Указываем порт, на котором будет работать приложение (стандартный для Nuxt - 3000)
EXPOSE 3000

# Устанавливаем переменную окружения PORT (хорошая практика)
ENV PORT=3000

# Команда для запуска production-сервера Nuxt
CMD ["node", ".output/server/index.mjs"]