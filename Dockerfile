FROM node:20-alpine

RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev

WORKDIR /srv/app

# Force cache bust - v2
RUN npx create-strapi-app@latest . \
    --no-run \
    --dbclient=sqlite \
    --dbfile=.tmp/data.db \
    --skip-cloud \
    && ls -la

# Install SendGrid provider  
RUN npm install @strapi/provider-email-sendgrid

ENV NODE_ENV=development

EXPOSE 1337

CMD ["npm", "start"]
