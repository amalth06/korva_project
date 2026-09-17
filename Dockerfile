
FROM node:20-alpine AS dependencies

WORKDIR /app

COPY package*.json ./

RUN npm ci



FROM dependencies AS builder

COPY . .

RUN npm run build



FROM node:20-alpine AS production

WORKDIR /app

RUN npm install -g serve@14

COPY --from=builder /app/dist ./dist


RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup && \
    chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000


HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD node -e "fetch('http://127.0.0.1:3000').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

CMD ["serve", "-s", "dist", "-l", "3000"]
