# Library Management API

## Table of Contents
1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Setup](#setup)
4. [Running the Application](#running-the-application)
5. [API Documentation](#api-documentation)
6. [Testing](#testing)
7. [Deployment](#deployment)

## Introduction

This project is a Library Management API built with Ruby on Rails. It provides endpoints for managing books, users, and borrowing operations in a library system. The API is designed to be RESTful and uses JSON for data exchange. 

## Prerequisites

This project is designed to be run locally using Docker. If you prefer to run it without Docker, ensure you have the following installed:
- Ruby 3.2.1
- Rails 7.1.4
- PostgreSQL
- Redis

## Setup
> Feel free to skip this section if you are using Docker

1. Install Homebrew
    ```sh
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```
   
2. Install Ruby using Ruby Version Management Tool (rbenv)
    ```sh
    # Install rbenv on MacOS/Linux
    brew install rbenv ruby-build
    rbenv init

    # Check rbenv installation
    # Reports status of rbenv installation
    curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-doctor | bash

    # Install Ruby 3.2.1
    rbenv install 3.2.1
    ```
   
3. Install PostgreSQL
    ```sh
    # List the available versions
    brew search postgresql@
   
    # Install the latest version
    brew install postgresql
    ```
   
4. Install Redis
    ```sh
    # List the available versions
    brew search redis@
   
    # Install the latest version
    brew install redis
    ```
   
5. Install Bundler
    ```sh
    gem install bundler:2.4.6
    ```
    > The Bundler gem provides the `bundle install` command. It is a dependency manager for Ruby, written in Ruby.

6. Ensure PostgreSQL and Redis are running
    ```sh
    brew services start postgresql
    brew services start redis
    ```

7. Set up environment variables:
   Create a `.env` file in the root directory and add the following variables:
   ```
   DATABASE_URL=postgres://username:password@localhost:5432/library_app_development
   TEST_DATABASE_URL=postgres://username:password@localhost:5432/library_app_test
   REDIS_URL=redis://localhost:6379/0
   HMAC_SECRET=your_secret_key_here
   ```

   Replace `username`, `password`, and `your_secret_key_here` with your actual PostgreSQL credentials and a secure secret key.  

8. Install the dependencies
    ```sh
    bundle install
    ```
   
9. Create the database
    ```sh
    rails db:create
    ```
   
10. Run the migrations
    ```sh
    # Run the migrations
    rails db:migrate
   
    # Check the status of the migrations
    rails db:migrate:status
    ```
11. Execute one-off rake task to create the admin user and retrieve the API key
    ```sh
    bundle exec rake one_off:create_admin_user
    bundle exec rake one_off:retrieve_admin_user_api_key
    ```

## Running the Application

### Using Rails Server
1. Start the Rails server:
   ```
   bundle exec rails server
   ```
2. The API will be available at `http://localhost:3000`

### Using Docker
1. Build and start the containers:
   ```
   docker-compose up --build
   ```
2. The API will be available at `http://localhost:3000`
3. Navigate to the container
   ```
   docker compose exec web bash
   ```
3. Execute one-off rake task to create the admin user and retrieve the API key
   ```sh
   bundle exec rake one_off:create_admin_user
   bundle exec rake one_off:retrieve_admin_user_api_key
   ```

## API Documentation

The API uses JWT for authentication. To access protected endpoints, you need to include the JWT token in the Authorization header of your requests.

Below are the screenshot of the Swagger UI to include the JWT token in the Authorization header of your requests.
![Swagger UI](swagger.png)

> [Remote Swagger UI](http://206.189.150.216/api-docs/index.html) is available, alternatively you can run the rails server locally and use the [Local Swagger UI](http://localhost:3000/api-docs/index.html)

> If you're experiencing issues with the `127.0.0.1:3000/api-docs/index.html` (e.g. CORS policy, LoadError), please use `localhost:3000/api-docs/index.html`

### Authentication

#### Create Token
- **POST** `/api/v1/tokens`
- **Body**: `{ "api_key": "your_api_key" }`
- **Response**: Returns access and refresh tokens

> We can retrieve the API key for local env by running `bundle exec rake one_off:retrieve_admin_user_api_key `.

> The API key for remote env is `4435b3e3731ff72ccecc7745ac604daaf21a4fd9`

#### Refresh Token
- **POST** `/api/v1/tokens/refresh`
- **Body**: `{ "refresh_token": "your_refresh_token" }`
- **Response**: Returns a new access token

### Books

#### Create Book (Protected endpoint)
- **POST** `/api/v1/books`
- **Headers**: `Authorization: Bearer your_access_token`
- **Body**: `{ "isbn": "1234567890", "title": "Book Title", "author": "Author Name" }`

#### List Books (Protected endpoint)
- **GET** `/api/v1/books`
- **Headers**: `Authorization: Bearer your_access_token`
- **Query Parameters**: `page` (optional, for pagination)

#### Borrow a Book (Protected endpoint)
- **POST** `/api/v1/borrowed_books`
- **Headers**: `Authorization: Bearer your_access_token`
- **Body**: `{ "email": "user@example.com", "book_id": 1 }`

#### Return a Book (Protected endpoint)
- **POST** `/api/v1/returned_books`
- **Headers**: `Authorization: Bearer your_access_token`
- **Body**: `{ "email": "user@example.com", "book_id": 1 }`

### Users

#### Create User (Protected endpoint)
- **POST** `/api/v1/users`
- **Headers**: `Authorization: Bearer your_access_token`
- **Body**: `{ "name": "User Name", "email": "user@example.com" }`

## Testing

All tests are written using RSpec and should be run before pushing any changes to the main branch. It's also a good way to understand the codebase and the requirements. It's located in the `spec` folder.

Run the test suite using RSpec:
```
bundle exec rspec [path_to_spec_file]
```

If you are using Docker and Docker Compose, you can run the test suite using the following command:
```
docker compose exec web bash
bundle exec rspec [path_to_spec_file]
```

## Deployment

This application is setup with a CI/CD pipeline using Github Actions. The pipeline includes steps for setting up the environment, running the test suite, and deploying the application to a remote server.

THe pipeline is defined in the `.github/workflows/ci-build.yml` and `.github/workflows/cd.yml` file. Here's a quick overview of the pipeline:
1. PR is required for any changes to be merged into the `main` branch
2. Test suites are executed and pass as part of the PR workflow
3. When merged to main, user can proceed to the CD workflow
4. It allows users to choose which branch to deploy via the GitHub Actions UI
5. Builds a Docker image as a production build
6. Pushes the image to your DigitalOcean Container Registry
7. Connects to the DigitalOcean Droplet via SSH
8. Pulls the new image from the Container Registry
9. Stops and removes the existing container (if any)
10. Starts a new container with the updated image

![CI test](CI.png)
![CD Diagram](CD.png)
To use this workflow:
1. Go to the "Actions" tab in your GitHub repository
2. Select the "Continuous Deployment" workflow
3. Click "Run workflow"
4. Choose the branch you want to deploy
5. Click "Run workflow" to start the deployment process

> Container Registry only has 500MB for the free plan, the deployment process will fail if the registry is full.

Alternatively, this application is configured for deployment using Docker. You can deploy it to any platform that supports Docker containers. On your deployment platform, ensure you set the following environment variables:
   - `PRODUCTION_DATABASE_URL`
   - `REDIS_URL`
   - `HMAC_SECRET`
   - `SECRET_KEY_BASE`

