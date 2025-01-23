# Canvas LMS Docker

This repository contains the Docker setup for Canvas LMS, an open-source learning management system.

This repositroy is an easy setup for Canvas LMS, with queues

## Prerequisites

- Docker
- Docker Compose

## Getting Started

1. Clone the repository:

   ```sh
   git clone https://github.com/yourusername/canvas-lms-docker.git
   cd canvas-lms-docker
   ```

2. set env file

- Create env file:

  ```
  touch .env
  ```

- Set env variable:

  ```
  EMAIL_DOMAIN=example.com
  EMAIL_HOST_USER=admin@example.com
  EMAIL_HOST_PASSWORD=password
  EMAIL_SENDER_ADDRESS=canvas@example.com
  EMAIL_SENDER_NAME=Instructure Canvas
  CANVAS_LMS_DOMAIN=localhost
  CANVAS_LMS_ADMIN_EMAIL=admin@example.com
  CANVAS_LMS_ADMIN_PASSWORD=password
  CANVAS_LMS_ACCOUNT_NAME=Canvas Admin
  CANVAS_LMS_STATS_COLLECTION=opt_out
  POSTGRES_HOST=local
  POSTGRES_USER=canvas
  POSTGRES_PASSWORD=canvas
  POSTGRES_DB=canvas
  REDIS_HOST=redis
  AWS_ACCESS_KEY_ID=
  AWS_SECRET_ACCESS_KEY=
  AWS_REGION=
  AWS_S3_BUCKET=
  TZ=CA/US
  COMPOSE_FILE=docker-compose.local.yml
  ```

2. Run docker:
   ```sh
   ./run.sh
   ```
3. For setup db run:

   ```
   ./setup.sh
   ```

4. Access Canvas LMS:
   Open your web browser and go to `http://localhost`.

## Configuration

You can configure the environment variables in the [.env](http://_vscodecontentref_/1) file to customize the setup.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Acknowledgements

- [Canvas LMS](https://github.com/instructure/canvas-lms) - The core LMS software.
- [Docker](https://www.docker.com/) - Containerization platform.
