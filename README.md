# Dockerized WordPress Deployment with Ansible

This project provides a Docker-based setup for deploying a WordPress application. It includes configurations for WordPress, MariaDB, and Nginx, all orchestrated with Docker Compose. The deployment is automated using Ansible.

## Project Structure

The project is structured as follows:

- `tasks/main.yml`: Contains the main Ansible tasks for setting up the WordPress application.
- `handlers/main.yml`: Contains Ansible handlers, mainly used for restarting Docker and reloading the WordPress stack.
- `files/`: This directory contains various configuration files and Dockerfiles for the services.
- `docker-compose.yml`: Docker Compose file to orchestrate the services.
- `mariadb.env`: Environment variables for the MariaDB service.
- `wordpress.env`: Environment variables for the WordPress service.
- `wordpress/`: Contains the Dockerfile and configuration files for the WordPress service.
- `nginx/`: Contains the Dockerfile and configuration files for the Nginx service.

## Usage

To deploy the WordPress application, run the Ansible playbook. This will set up the WordPress application at /opt/wordpress on the target machine and start the Docker services.

## License

This project is open source and available under the MIT License.

## Attribution

If you use this project in your own work, please include the following attribution:

> This project uses code from [Dockerized WordPress Deployment](https://github.com/gsusi/yourrepository) by [Your Name].

Replace [Your Name] and the GitHub URL with your own details.

## Contributing

Contributions are welcome! Please submit a pull request or create an issue on the GitHub repository.

## Contact

If you have any questions or feedback, please contact me at your.email@example.com.

---
