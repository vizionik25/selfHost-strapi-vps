FROM node:20-alpine

RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev

WORKDIR /srv/app

# Create Strapi project
RUN npx create-strapi-app@latest . --no-run --dbclient=sqlite --dbfile=.tmp/data.db

# Install SendGrid provider
RUN npm install @strapi/provider-email-sendgrid

ENV NODE_ENV=production
RUN npm run build

EXPOSE 1337
CMD ["npm", "run", "start"]
