FROM node:20-alpine

RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev

WORKDIR /srv/app

# Create Strapi project
RUN npx create-strapi-app@latest . --no-run --dbclient=sqlite --dbfile=.tmp/data.db

# Install SendGrid provider
RUN npm install @strapi/provider-email-sendgrid

# Build admin panel using local strapi
ENV NODE_ENV=production
RUN node ./node_modules/@strapi/strapi/bin/strapi.js build

EXPOSE 1337
CMD ["node", "./node_modules/@strapi/strapi/bin/strapi.js", "start"]
