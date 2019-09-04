FROM alpine:3.10

# Installs latest Chromium package.
RUN apk add --no-cache \
      chromium \
      nss \
      freetype \
      freetype-dev \
      harfbuzz \
      ca-certificates \
      ttf-freefont \
      nodejs \
      npm \
      git

# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Add user so we don't need --no-sandbox.
RUN addgroup -S pptruser && adduser -S -g pptruser pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && chown -R pptruser:pptruser /home/pptruser

# Run everything after as non-privileged user.
USER pptruser

WORKDIR /home/pptruser

# RUN git clone https://github.com/hypercharge-code/rendertron.git
# or
RUN mkdir -p /home/pptruser/rendertron
COPY --chown=pptruser:pptruser . /home/pptruser/rendertron

WORKDIR /home/pptruser/rendertron

RUN npm install || \
  ((if [ -f npm-debug.log ]; then \
      cat npm-debug.log; \
    fi) && false)
RUN npm run build

EXPOSE 3000

CMD ["npm", "start"]
