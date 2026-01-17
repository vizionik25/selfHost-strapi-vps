FROM node:20-alpine

# Install runtime dependencies for 'better-sqlite3' and sharp
RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev

WORKDIR /srv/app

# Copy package files
COPY package*.json ./

# Install dependencies
ENV CI=true
RUN npm ci

# Copy the rest of the source code
COPY . .

# Build Strapi admin panel
ENV NODE_ENV=production
RUN npm run build

# Expose port
EXPOSE 1337

# Start Strapi
CMD ["npm", "run", "start"]
