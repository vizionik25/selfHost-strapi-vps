FROM node:20-alpine

RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev

WORKDIR /srv/app

# Create Strapi project (--yes skips all prompts including cloud login)
RUN npx create-strapi-app@latest . \
    --no-run \
    --dbclient=sqlite \
    --dbfile=.tmp/data.db \
    --yes

# Install SendGrid provider  
RUN npm install @strapi/provider-email-sendgrid

ENV NODE_ENV=development

EXPOSE 1337

CMD ["npm", "run", "develop"]
