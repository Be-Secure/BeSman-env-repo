#!/bin/bash

function __besman_install_tomcat-RT-env
{
    local playbook repo namespace clone_path
    __besman_check_for_ansible || return 1
    __besman_check_for_gh || return 1
    namespace=Be-Secure
    __besman_check_github_id || return 1
    __besman_gh_auth "$BESMAN_USER_NAMESPACE" || return 1
    playbook=$HOME/besman-trigger-tomcat-RT-roles.yml
    export BESMAN_ANSIBLE_ROLE_PATH=$HOME/tmp
    export BESMAN_ANSIBLE_GALAXY_ROLES=asa1997/ansible-role-oah-java:asa1997/ansible-role-oah-ant:asa1997/ansible-role-oah-eclipse:Pranshu021/ansible-role-oah-docker:Pranshu021/ansible-role-oah-sonarQube:Pranshu021/ansible-role-oah-sbomGenerator
    __besman_update_requirements_file
    __besman_ansible_galaxy_install_roles_from_requirements
    __besman_check_for_trigger_playbook "$playbook"
    [[ "$?" -eq 1 ]] && __besman_create_ansible_playbook "$playbook" "$BESMAN_ANSIBLE_GALAXY_ROLES"
    __besman_run_ansible_playbook_extra_vars "$playbook" "bes_command=install role_path=$BESMAN_ANSIBLE_ROLE_PATH" || return 1
    repo=tomcat
    clone_path=$HOME/tomcat
    [[ ! -d $clone_path ]] && __besman_gh_clone "$namespace" "$repo" "$clone_path"
    unset playbook repo namespace clone_path
}

function __besman_uninstall_tomcat-RT-env
{
    local playbook 
    playbook=$HOME/besman-trigger-tomcat-RT-roles.yml
    __besman_run_ansible_playbook_extra_vars "$playbook" "bes_command=remove role_path=$BESMAN_ANSIBLE_ROLE_PATH" || return 1
    [[ -d $HOME/tomcat ]] && rm -rf $HOME/tomcat
}

function __besman_update_tomcat-RT-env
{
    local playbook
    playbook=$HOME/besman-trigger-tomcat-RT-roles.yml
    __besman_run_ansible_playbook_extra_vars "$playbook" "bes_command=update role_path=$BESMAN_ANSIBLE_ROLE_PATH" || return 1
    unset playbook
}

function __besman_validate_tomcat-RT-env
{
    local playbook
    playbook=$HOME/besman-trigger-tomcat-RT-roles.yml
    __besman_run_ansible_playbook_extra_vars "$playbook" "bes_command=validate role_path=$BESMAN_ANSIBLE_ROLE_PATH" || return 1
   if [[ -d $HOME/tomcat ]]; then
        __besman_echo_green "tomcat found"
   else
        __besman_echo_red "tomcat not found"
   fi
    unset playbook
}

function __besman_reset_tomcat-RT-env
{
    local playbook
    playbook=$HOME/besman-trigger-tomcat-RT-roles.yml
    __besman_run_ansible_playbook_extra_vars "$playbook" "bes_command=reset role_path=$BESMAN_ANSIBLE_ROLE_PATH" || return 1
    unset playbook
}