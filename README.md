# BeSman Environment Scripts Repo

A BeSman environment script is a script file that contains instructions for setting up and configuring the necessary tools, dependencies, and settings required for a specific software or project environment. It typically includes commands or directives to install/manage libraries, frameworks, databases, and other components needed to run the software or project successfully. Environment scripts automate the setup process, ensuring consistency and reproducibility across different environments or systems. They are commonly used in software development, testing, deployment, and other related tasks to streamline the environment setup and configuration

The repository contains environment scripts for projects tracked by [Be-Secure](https://github.com/Be-Secure) community.

# Key Features

1. Customizable Environment Scripts: BeSman supports the use of environment variables, enabling users to define dynamic values that can be easily modified or shared. This flexibility allows for greater adaptability and customization of the environment setup.

2. Recyclable Environment Scripts: The environment scripts are recyclable thanks to its lifecycle functions.

3. Easier environment setup:  The environment helps security professionals to reduce the turn around time for assessment of Open Source projects, AI Models, Model Datasets leaving them focus on the assessment task rather than setting up environment for it.
   
# Types of environment script

Environment scripts are categorized based on the following.

1. **Red Team environments(RT)**: The env installs all the tools/utilities required for a security analyst to perform vulnerability assessment, create exploits etc.
2. **Blue Team environments(BT)**: The env would contain the instruction to install the tools required for a security professional to perform BT activities such as vulnerability remediation and patching.

# Lifecycle functions of BeSman environment scripts

A BeSman environment script contain the following lifecycle functions

- install: Installs the required tools.
- uninstall: Removes the installed tools.
- validate: Checks whether all the tools are installed and required configurations are met.
- update: Update configurations of the tools.
- reset: Reset the environment to the default state.


# Two ways of execution

A BeSman environment script can be executed in two ways,

### 1. Using Ansible Roles

The environment script uses ansible roles to install the required tools.

**Benefits**

- Tool configuration
- Easier installation
- Reusable components

**Drawback**

- Need an Ansible installation

**Skeletal Code**

    #!/bin/bash

    function __besman_install
    {

        __besman_check_vcs_exist || return 1 # Checks if GitHub CLI is present or not.
        __besman_check_github_id || return 1 # checks whether the user github id has been populated or not under BESMAN_USER_NAMESPACE 
        __besman_check_for_ansible || return 1 # Checks if ansible is installed or not.
        __besman_create_roles_config_file # Creates the role config file with the parameters from env config
        
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

        if [[ -d $BESMAN_ASSESSMENT_DATASTORE_DIR ]] 
        then
            __besman_echo_white "Assessment datastore found at $BESMAN_ASSESSMENT_DATASTORE_DIR"
        else
            __besman_echo_white "Cloning assessment datastore from $\BESMAN_USER_NAMESPACE/besecure-assessment-datastore"
            __besman_repo_clone "$BESMAN_USER_NAMESPACE" "besecure-assessment-datastore" "$BESMAN_ASSESSMENT_DATASTORE_DIR" || return 1

        fi
        # Please add the rest of the code here for installation
    }

    function __besman_uninstall
    {
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

    }

    function __besman_update
    {
        __besman_check_for_trigger_playbook "$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK"
        [[ "$?" -eq 1 ]] && __besman_create_ansible_playbook
        __besman_run_ansible_playbook_extra_vars "$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK" "bes_command=update role_path=$BESMAN_ANSIBLE_ROLES_PATH" || return 1
        # Please add the rest of the code here for update

    }

    function __besman_validate
    {
        __besman_check_for_trigger_playbook "$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK"
        [[ "$?" -eq 1 ]] && __besman_create_ansible_playbook
        __besman_run_ansible_playbook_extra_vars "$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK" "bes_command=validate role_path=$BESMAN_ANSIBLE_ROLES_PATH" || return 1
        # Please add the rest of the code here for validate

    }

    function __besman_reset
    {
        __besman_check_for_trigger_playbook "$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK"
        [[ "$?" -eq 1 ]] && __besman_create_ansible_playbook
        __besman_run_ansible_playbook_extra_vars "$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK" "bes_command=reset role_path=$BESMAN_ANSIBLE_ROLES_PATH" || return 1
        # Please add the rest of the code here for reset

    }

### 2. Without using Ansible Roles - Basic environment

In this environment script, you will have to right all the required steps to install all the required tools.

**Benefits**

- Lightweight
- No overhead of Ansible

**Drawback**

- Does have restricted customization.
- Cannot tweak tool configurations.

**Skeletal Code**

    #!/bin/bash

    function __besman_install
    {

    }

    function __besman_uninstall
    {
        
    }

    function __besman_update
    {
        
    }

    function __besman_validate
    {
        
    }

    function __besman_reset
    {
        
    }

# Available environments.

## RT Environments

1. [Fastjson](fastjson/0.0.1/besman-fastjson-RT-env.sh)
2. [zaproxy](zaproxy/0.0.1/besman-zaproxy-RT-env.sh)
3. [jackson-databind](jackson-databind/0.0.1/besman-jackson-databind-RT-env.sh)

## BT Environments

1. [Fastjson](fastjson/0.0.1/besman-fastjson-BT-env.sh)
2. [zaproxy](zaproxy/0.0.1/besman-zaproxy-BT-env.sh)
3. [jackson-databind](jackson-databind/0.0.1/besman-jackson-databind-BT-env.sh)
4. [HWC_API](HWC-API/0.0.1/besman-HWC-API-BT-env.sh)
1. [lettuce](lettuce/0.0.1/besman-lettuce-BT-env.sh)