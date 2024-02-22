#!/bin/bash

<<<<<<< HEAD
function __besman_install {

    __besman_check_vcs_exist || return 1   # Checks if GitHub CLI is present or not.
    __besman_check_github_id || return 1   # checks whether the user github id has been populated or not under BESMAN_USER_NAMESPACE
    __besman_check_for_ansible || return 1 # Checks if ansible is installed or not.
    __besman_create_roles_config_file      # Creates the role config file with the parameters from env config

    # Requirements file is used to list the required ansible roles. The data for requirements file comes from BESMAN_ANSIBLE_ROLES env var.
    # This function updates the requirements file from BESMAN_ANSIBLE_ROLES env var.
    __besman_update_requirements_file
    __besman_ansible_galaxy_install_roles_from_requirements # Downloads the ansible roles mentioned in BESMAN_ANSIBLE_ROLES to BESMAN_ANSIBLE_ROLES_PATH
    # This function checks for the playbook BESMAN_ARTIFACT_TRIGGER_PLAYBOOK under BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH.
    # The trigger playbook is used to run the ansible roles.
    __besman_check_for_trigger_playbook "$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK"
    [[ "$?" -eq 1 ]] && __besman_create_ansible_playbook # Creates the trigger playbook if not present.
    # Runs the trigger playbook. We are also passing these variables - bes_command=install; role_path=$BESMAN_ANSIBLE_ROLES_PATH
    __besman_run_ansible_playbook_extra_vars "$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK" "bes_command=install role_path=$BESMAN_ANSIBLE_ROLES_PATH" || return 1
    # Clones the source code repo.
    if [[ -d $BESMAN_ARTIFACT_DIR ]]; then
        __besman_echo_white "The clone path already contains dir names $BESMAN_ARTIFACT_NAME"
    else
        __besman_echo_white "Cloning source code repo from $BESMAN_USER_NAMESPACE/$BESMAN_ARTIFACT_NAME"
        __besman_repo_clone "$BESMAN_USER_NAMESPACE" "$BESMAN_ARTIFACT_NAME" "$BESMAN_ARTIFACT_DIR" || return 1
        cd "$BESMAN_ARTIFACT_DIR" && git checkout -b "$BESMAN_ARTIFACT_VERSION"_tavoss "$BESMAN_ARTIFACT_VERSION"
        cd "$HOME"
    fi

    if [[ -d $BESMAN_ASSESSMENT_DATASTORE_DIR ]]; then
        __besman_echo_white "Assessment datastore found at $BESMAN_ASSESSMENT_DATASTORE_DIR"
    else
        __besman_echo_white "Cloning assessment datastore from $\BESMAN_USER_NAMESPACE/besecure-assessment-datastore"
        __besman_repo_clone "$BESMAN_USER_NAMESPACE" "besecure-assessment-datastore" "$BESMAN_ASSESSMENT_DATASTORE_DIR" || return 1

    fi

    # Please add the rest of the code here for installation
=======
function __besman_install_opencti-RT-env
{
    
    __besman_check_for_gh || return 1
    __besman_check_github_id || return 1
    __besman_check_for_ansible || return 1
    __besman_update_requirements_file
    __besman_ansible_galaxy_install_roles_from_requirements
    __besman_check_for_trigger_playbook "$BESMAN_OSS_TRIGGER_PLAYBOOK_PATH/$BESMAN_OSS_TRIGGER_PLAYBOOK"
    [[ "$?" -eq 1 ]] && __besman_create_ansible_playbook
    __besman_run_ansible_playbook_extra_vars "$BESMAN_OSS_TRIGGER_PLAYBOOK_PATH/$BESMAN_OSS_TRIGGER_PLAYBOOK" "bes_command=install role_path=$BESMAN_ANSIBLE_ROLES_PATH" || return 1
    if [[ -d $BESMAN_OSSP_CLONE_PATH ]]; then
        __besman_echo_white "The clone path already contains dir names $BESMAN_OSSP"
    else
        __besman_gh_clone "$BESMAN_ORG" "$BESMAN_OSSP" "$BESMAN_OSSP_CLONE_PATH"
    fi
    # Please add the rest of the code here for installation
       # opencti-dev environment script
    echo "1 ------- opencti dev modules setup..."
    #!/bin/bash

>>>>>>> 0de428a (BR-RT environment for opencti project & added packagemanager and IDE for newrelic-java-agent)
    # Function to install Docker
    install_docker() {
        echo "Installing Docker..."
        # Update package index
        sudo apt update
        # Install dependencies
        sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
        # Add Docker GPG key
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        # Add Docker repository
        echo \
            "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
        # Install Docker Engine
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io
        # Add current user to Docker group
        sudo usermod -aG docker $USER
        echo "Docker installed successfully."
    }

    # Check if Docker is installed
    if ! command -v docker &>/dev/null; then
        install_docker
    else
        echo "Docker is already there to use."
    fi

<<<<<<< HEAD
=======
    # Function to stop and remove a container if it's running
    stop_and_remove_container() {
        local container_name=$1
        if docker ps -a --format '{{.Names}}' | grep -q "$container_name"; then
            echo "Stopping and removing existing $container_name container..."
            docker stop "$container_name" &>/dev/null
            docker rm "$container_name" &>/dev/null
        fi
    }

    # Stop and remove existing containers if they are already running
    stop_and_remove_container "opencti-dev-redis"
    stop_and_remove_container "opencti-dev-redis-insight"
    stop_and_remove_container "opencti-dev-elasticsearch"
    stop_and_remove_container "opencti-dev-kibana"
    stop_and_remove_container "opencti-dev-minio"
    stop_and_remove_container "opencti-dev-rabbitmq"
    stop_and_remove_container "opencti-dev-jaegertracing"

    # Now start the containers
    # Starting Redis
    echo "Starting Redis..."
    docker run -d --name opencti-dev-redis -p 6379:6379 redis:7.2.4

    # Starting Redis Insight
    echo "Starting Redis Insight..."
    docker run -d --name opencti-dev-redis-insight -p 8001:8001 redislabs/redisinsight:latest

    # Starting Elasticsearch
    echo "Starting Elasticsearch..."
    docker run -d --name opencti-dev-elasticsearch \
        -p 9200:9200 -p 9300:9300 \
        -v esdata:/usr/share/elasticsearch/data \
        -v essnapshots:/usr/share/elasticsearch/snapshots \
        -e "discovery.type=single-node" \
        -e "xpack.ml.enabled=false" \
        -e "xpack.security.enabled=false" \
        -e "ES_JAVA_OPTS=-Xms2G -Xmx2G" \
        --ulimit memlock=-1:-1 --ulimit nofile=65536:65536 \
        docker.elastic.co/elasticsearch/elasticsearch:8.12.0

    # Starting Kibana
    echo "Starting Kibana..."
    docker run -d --name opencti-dev-kibana \
        -p 5601:5601 \
        -e "ELASTICSEARCH_HOSTS=http://localhost:9200" \
        --link opencti-dev-elasticsearch:elasticsearch \
        docker.elastic.co/kibana/kibana:8.12.0

    # Starting Minio
    echo "Starting Minio..."
    docker run -d --name opencti-dev-minio \
        -p 9000:9000 -p 9001:9001 -p 35300:35300 \
        -e "MINIO_ROOT_USER=ChangeMe" \
        -e "MINIO_ROOT_PASSWORD=ChangeMe" \
        minio/minio:latest server /data --console-address ":9001"

    # Starting RabbitMQ
    echo "Starting RabbitMQ..."
    docker run -d --name opencti-dev-rabbitmq \
        -p 5672:5672 -p 15672:15672 \
        rabbitmq:3.12-management

    # Starting Jaeger Tracing
    echo "Starting Jaeger Tracing..."
    docker run -d --name opencti-dev-jaegertracing \
        -p 16686:16686 -p 4318:4318 \
        jaegertracing/all-in-one:latest

    echo "All services started successfully!"

    echo "1 ------- dev-module setup completed."
    print "/n"

    echo "2 ------- graphql setup...."
    #!/bin/bash

>>>>>>> 0de428a (BR-RT environment for opencti project & added packagemanager and IDE for newrelic-java-agent)
    # Check if Yarn is installed
    if ! command -v yarn &>/dev/null; then
        echo "Yarn is not installed. Installing Yarn..."
        # Add Yarn repository key
        curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
        # Add Yarn repository
        echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
        # Update package index
        sudo apt update
        # Install Yarn
        sudo apt install yarn -y
<<<<<<< HEAD
    else 
        echo "yarn is already there to use." 
    fi

=======
    fi

    cd $HOME/$BESMAN_OSSP/opencti-platform/opencti-graphql

    # Install dependencies using Yarn
    yarn install

    # Build GraphQL backend
    yarn build

    # Start GraphQL server
    yarn start &

    echo "2 ------- graphql setup completed...."
    print "/n"

    echo "3 ------- worker setup...."
    #!/bin/bash

>>>>>>> 0de428a (BR-RT environment for opencti project & added packagemanager and IDE for newrelic-java-agent)
    # Check if Python is installed
    if ! command -v python3 &>/dev/null; then
        echo "Python is not installed. Installing Python..."
        sudo apt update
        sudo apt install python3 -y
<<<<<<< HEAD
    else 
        echo "Python is already there to use."
=======
>>>>>>> 0de428a (BR-RT environment for opencti project & added packagemanager and IDE for newrelic-java-agent)
    fi

    # Check if pip is installed
    if ! command -v pip3 &>/dev/null; then
        echo "pip is not installed. Installing pip..."
        sudo apt update
        sudo apt install python3-pip -y
<<<<<<< HEAD
    else 
        echo "pip is already there is use."
    fi

    echo -e "\nopencti RT env installation is complete"
}

function __besman_uninstall {
    __besman_check_for_trigger_playbook "$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK"
    [[ "$?" -eq 1 ]] && __besman_create_ansible_playbook
    __besman_run_ansible_playbook_extra_vars "$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK" "bes_command=remove role_path=$BESMAN_ANSIBLE_ROLES_PATH" || return 1
    if [[ -d $BESMAN_ARTIFACT_DIR ]]; then
        __besman_echo_white "Removing $BESMAN_ARTIFACT_DIR..."
        rm -rf "$BESMAN_ARTIFACT_DIR"
    else
        __besman_echo_yellow "Could not find dir $BESMAN_ARTIFACT_DIR"
    fi

    # Please add the rest of the code here for uninstallation
    echo "opencti RT env un-installation is complete"

}

function __besman_update {
    __besman_check_for_trigger_playbook "$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK"
    [[ "$?" -eq 1 ]] && __besman_create_ansible_playbook
    __besman_run_ansible_playbook_extra_vars "$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK" "bes_command=update role_path=$BESMAN_ANSIBLE_ROLES_PATH" || return 1
=======
    fi

    # Navigate to the directory containing the worker script
    cd $HOME/$BESMAN_OSSP/opencti-worker/src

    # Install dependencies using pip
    pip3 install -r requirements.txt

    # Start the worker
    python3 worker.py &

    echo "3 ------- worker setup completed...."
    print "/n"

    echo "4 ------- front-end setup...."
    #!/bin/bash

    # Check if Yarn is installed
    if ! command -v yarn &>/dev/null; then
        echo "Yarn is not installed. Installing Yarn..."
        # Add Yarn repository key
        curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
        # Add Yarn repository
        echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
        # Update package index
        sudo apt update
        # Install Yarn
        sudo apt install yarn -y
    fi

    # Clone OpenCTI Frontend repository

    cd $HOME/$BESMAN_OSSP/opencti-platform/opencti-front

    # Install dependencies using Yarn
    yarn install

    # Build frontend
    yarn build

    # Serve frontend
    yarn start &

    sleep 30 # Wait for the server to start (you may adjust the duration if needed)
    firefox http://localhost:4000

    echo "OpenCTI Frontend is now running!"
    echo "4 ------- front-end setup completed...."
    print "/n"
}

function __besman_uninstall_opencti-RT-env
{
    __besman_check_for_trigger_playbook "$BESMAN_OSS_TRIGGER_PLAYBOOK_PATH/$BESMAN_OSS_TRIGGER_PLAYBOOK"
    [[ "$?" -eq 1 ]] && __besman_create_ansible_playbook
    __besman_run_ansible_playbook_extra_vars "$BESMAN_OSS_TRIGGER_PLAYBOOK_PATH/$BESMAN_OSS_TRIGGER_PLAYBOOK" "bes_command=remove role_path=$BESMAN_ANSIBLE_ROLES_PATH" || return 1
    if [[ -d $BESMAN_OSSP_CLONE_PATH ]]; then
        __besman_echo_white "Removing $BESMAN_OSSP_CLONE_PATH..."
        rm -rf "$BESMAN_OSSP_CLONE_PATH"
    else
        __besman_echo_yellow "Could not find dir $BESMAN_OSSP_CLONE_PATH"
    fi
    # Please add the rest of the code here for uninstallation

}

function __besman_update_opencti-RT-env
{
    __besman_check_for_trigger_playbook "$BESMAN_OSS_TRIGGER_PLAYBOOK_PATH/$BESMAN_OSS_TRIGGER_PLAYBOOK"
    [[ "$?" -eq 1 ]] && __besman_create_ansible_playbook
    __besman_run_ansible_playbook_extra_vars "$BESMAN_OSS_TRIGGER_PLAYBOOK_PATH/$BESMAN_OSS_TRIGGER_PLAYBOOK" "bes_command=update role_path=$BESMAN_ANSIBLE_ROLES_PATH" || return 1
>>>>>>> 0de428a (BR-RT environment for opencti project & added packagemanager and IDE for newrelic-java-agent)
    # Please add the rest of the code here for update

}

<<<<<<< HEAD
function __besman_validate {
    __besman_check_for_trigger_playbook "$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK"
    [[ "$?" -eq 1 ]] && __besman_create_ansible_playbook
    __besman_run_ansible_playbook_extra_vars "$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK" "bes_command=validate role_path=$BESMAN_ANSIBLE_ROLES_PATH" || return 1
=======
function __besman_validate_opencti-RT-env
{
    __besman_check_for_trigger_playbook "$BESMAN_OSS_TRIGGER_PLAYBOOK_PATH/$BESMAN_OSS_TRIGGER_PLAYBOOK"
    [[ "$?" -eq 1 ]] && __besman_create_ansible_playbook
    __besman_run_ansible_playbook_extra_vars "$BESMAN_OSS_TRIGGER_PLAYBOOK_PATH/$BESMAN_OSS_TRIGGER_PLAYBOOK" "bes_command=validate role_path=$BESMAN_ANSIBLE_ROLES_PATH" || return 1
>>>>>>> 0de428a (BR-RT environment for opencti project & added packagemanager and IDE for newrelic-java-agent)
    # Please add the rest of the code here for validate

}

<<<<<<< HEAD
function __besman_reset {
    __besman_check_for_trigger_playbook "$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK"
    [[ "$?" -eq 1 ]] && __besman_create_ansible_playbook
    __besman_run_ansible_playbook_extra_vars "$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK" "bes_command=reset role_path=$BESMAN_ANSIBLE_ROLES_PATH" || return 1
=======
function __besman_reset_opencti-RT-env
{
    __besman_check_for_trigger_playbook "$BESMAN_OSS_TRIGGER_PLAYBOOK_PATH/$BESMAN_OSS_TRIGGER_PLAYBOOK"
    [[ "$?" -eq 1 ]] && __besman_create_ansible_playbook
    __besman_run_ansible_playbook_extra_vars "$BESMAN_OSS_TRIGGER_PLAYBOOK_PATH/$BESMAN_OSS_TRIGGER_PLAYBOOK" "bes_command=reset role_path=$BESMAN_ANSIBLE_ROLES_PATH" || return 1
>>>>>>> 0de428a (BR-RT environment for opencti project & added packagemanager and IDE for newrelic-java-agent)
    # Please add the rest of the code here for reset

}
