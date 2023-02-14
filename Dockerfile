FROM node:14.5.0-alpine AS development
WORKDIR /to-do-app
EXPOSE 3000
COPY ./package.json /to-do-app
RUN npm install
COPY . .
CMD npm start
