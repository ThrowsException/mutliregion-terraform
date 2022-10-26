FROM node:lts-bullseye-slim

COPY ["package-lock.json", "package.json", "./"]
RUN npm ci

COPY . .
RUN npm run build


CMD ["node", "./build/app.js"]