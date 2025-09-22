This repository contains the **deployment stack** for the Gemini application (backend + frontend + database) using Docker Compose.  
The stack includes:
- **[gemini-service](https://github.com/cah1r/gemini-service)** – backend (Spring Boot 3, Java 21)
- **[gemini-ui](https://github.com/cah1r/gemini-ui)** – frontend (Angular, built into static files served by Caddy2)
- **PostgreSQL** – database
- **Flyway** – database migrations executed on backend startup
- **Caddy2** – reverse proxy for frontend + API with HTTPS support

---

### Requirements
For successful deployment you have to create `.env` file in project root directory with following variables:
```env
LE_EMAIL=
APP_DOMAIN=
JAVA_OPTS=
```
- `LE_EMAIL` – email for Let's Encrypt certificate registration (can be any valid email)
- `APP_DOMAIN` – domain name for your application (e.g. `app.example.com`)
- `JAVA_OPTS` – additional Java options for backend (e.g. `-Xmx512m` to set max heap size to 512MB)
---
Then create `secrets` directory with following files:
- `db_password` – password for PostgreSQL user (default user is `gemini_app`)
- `backend.yml` – configuration file for backend with secrets with following content:

```yaml
spring:
  datasource:
    username: gemini_app
    password: <content of db_password file>
    url: jdbc:postgresql://db:5432/gemini_db
  mail:
    host: <your smtp host>
    port: <your smtp port>
    username: <your email address>
    password: <your mail app password>

app:
  security:
    allowed-origin: <value of APP_DOMAIN env variable for CORS configuration>
    jwt:
      signing-key: <random string for JWT signing, e.g. a UUID>

paynow:
  api-key: <your Paynow API key>
  signature-key: <your Paynow signature key>
```
App has integration with mBank Paynow service so for handling payments you need to register free sandbox account 
and retrieve API credentials from [here](https://panel.sandbox.paynow.pl/auth/login).

Next to `gemini-deploy` you need to have [gemini-service](https://github.com/cah1r/gemini-service) 
as a backend part of application and also [gemini-ui](https://github.com/cah1r/gemini-ui) for the frontend part.

### App structure
```
gemini-app/
|-- gemini-deploy
|-- gemini-service
|-- gemini-ui
```

---

### Local Docker Deployment
For local deployment, ensure you have Docker and Docker Compose installed on your machine. Then, create `docker-compose.override.yml`
file with following content:
```yaml
services:
  db:
    ports:
      - "5433:5432"
  backend:
    build:
      context: ../gemini-service
      dockerfile: Dockerfile
    image: cah1r/gemini-service:local
    pull_policy: never
  web:
    build:
      context: ../gemini-ui
      dockerfile: Dockerfile
      args:
        APP_DOMAIN: localhost
    image: cah1r/gemini-ui:local
    pull_policy: never
    environment:
      APP_DOMAIN: localhost
      LE_EMAIL: ignore@example.com
    volumes:
      - ./Caddyfile.dev:/etc/caddy/Caddyfile:ro
```

---

### Final steps
To start the deployment, run following command from `gemini-deploy` directory:
```bash
docker compose up --build
```
This command will build and start all the services defined in the `docker-compose.yml` file and the override file if present.