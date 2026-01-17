FROM node:20-alpine

RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev

WORKDIR /srv/app

# Create Strapi project
RUN npx create-strapi-app@latest . \
    --no-run \
    --dbclient=sqlite \
    --dbfile=.tmp/data.db \
    --skip-cloud

# Show what we have
RUN echo "=== package.json ===" && cat package.json && echo "=== node_modules/.bin ===" && ls -la node_modules/.bin/

# Install SendGrid provider
RUN npm install @strapi/provider-email-sendgrid

ENV NODE_ENV=development

EXPOSE 1337

# Use strapi from node_modules bin
CMD ["node", "node_modules/@strapi/strapi/bin/strapi.js", "develop"]
