FROM node:18-alpine
#RUN addgroup --system guavagroup && adduser --system --group guavauser
WORKDIR /src/rg-ops
COPY package*.json ./
RUN npm ci --only=production
COPY app.js ./
USER appuser
EXPOSE 3000
#HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl -f http://localhost:3000/health || exit 1
CMD ["node", "app.js"]

