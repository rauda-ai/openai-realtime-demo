FROM node:20-slim

WORKDIR /app

# Install wget for healthcheck
RUN apt-get update && apt-get install -y --no-install-recommends wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

COPY ./src/twiml.xml ./dist/twiml.xml

EXPOSE 8081
CMD ["npm", "run", "start"]
