# -*- coding: utf-8 -*-

import os
import base

def get_chart_file(file_name):
    command = ["wget", file_name]
    ret = base.run_command(command)
    print("Command return: ", ret)
    command = ["tar", "xvf", file_name.split('/')[-1]]
    ret = base.run_command(command)
    print("Command return: ", ret)

def helm_login(harbor_server, user, password):
    os.putenv("HELM_EXPERIMENTAL_OCI", "1")
    command = ["helm3", "registry", "login", harbor_server, "-u", user, "-p", password]
    ret = base.run_command(command)
    print("Command return: ", ret)

def helm_save(chart_archive, harbor_server, project, repo_name):
    command = ["helm3", "chart","save", chart_archive, harbor_server+"/"+project+"/"+repo_name]
    base.run_command(command)

def helm_push(harbor_server, project, repo_name, version):
    command = ["helm3", "chart","push", harbor_server+"/"+project+"/"+repo_name+":"+version]
    ret = base.run_command(command)
    return ret

def helm_chart_push_to_harbor(chart_file, archive, harbor_server, project, repo_name, version, user, password):
    get_chart_file(chart_file)
    helm_login(harbor_server, user, password)
    helm_save(archive, harbor_server, project, repo_name)
    return helm_push(harbor_server, project, repo_name, version)

def helm2_add_repo(helm_repo_name, harbor_url, project, username, password, expected_error_message = None):
    command = ["helm2", "repo", "add", "--username=" + username, "--password=" + password, helm_repo_name, harbor_url + "/chartrepo/" + project]
    ret = base.run_command(command, expected_error_message = expected_error_message)


def helm2_push(helm_repo_name, chart_file, project, username, password):
    get_chart_file(chart_file)
    command = ["helm2", "push", "--username=" + username, "--password=" + password, chart_file.split('/')[-1], helm_repo_name]
    base.run_command(command)

def helm2_repo_update():
    command = ["helm2", "repo", "update"]
    base.run_command(command)

def helm2_fetch_chart_file(helm_repo_name, harbor_url, project, username, password, chart_file, expected_add_repo_error_message = None):
    helm2_add_repo(helm_repo_name, harbor_url, project, username, password, expected_error_message = expected_add_repo_error_message)
    if expected_add_repo_error_message is not None:
        return
    helm2_repo_update()
    command_ls = ["ls"]
    base.run_command(command_ls)
    command = ["helm2", "fetch", "{}/{}".format(helm_repo_name, chart_file)]
    base.run_command(command)
    base.run_command(command_ls)
