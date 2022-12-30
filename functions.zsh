function __cmd_functions_show_processes_on_port() {
	netstat -vanp tcp | grep $1
}

function __cmd_functions_cs_resolve_tree() {
	cs resolve -t $1 | fzf --reverse --ansi
}

function __cmd_functions_cs_install_java() {
	cs java --jvm $(cs java --available | fzf) --setup
}

function __cmd_functions_cs_change_java() {
	cs java --jvm $(cs java --installed | fzf | cut -d ' ' -f1) --setup -q
	rm -rf ~/.profile # the command above sets .profile and .zprofile, since we don't use .profile, we delete it.
	source ~/.zprofile
}

function __cmd_functions_cs_change_java_tmp() {
	jvm=$(cs java --installed | fzf | cut -d ' ' -f1)
	script=$(cs java --jvm $jvm --env)
	echo "Setting jvm for the current session to: $jvm"
	eval $script
}

function __cmd_functions_docker_stop_conts() {
	docker stop $(docker ps -aq)
}

function __cmd_functions_docker_rm_conts() {
	docker rm $(docker ps -aq)
}

function __cmd_functions_docker_rm_images() {
	docker rmi $(docker images -q)
}


