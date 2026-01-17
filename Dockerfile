FROM node:20-alpine

RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev

WORKDIR /srv/app

# Create Strapi project and show available scripts
RUN npx create-strapi-app@latest . --no-run --dbclient=sqlite --dbfile=.tmp/data.db \
    && cat package.json

# Install SendGrid provider
RUN npm install @strapi/provider-email-sendgrid

ENV NODE_ENV=development

EXPOSE 1337

# Use the strapi CLI from node_modules
CMD ["./node_modules/.bin/strapi", "develop"]
