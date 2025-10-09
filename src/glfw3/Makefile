include ../../vars.mk

__FILES:=$(call format_lib,glfw3)
__DEPS:=
__IMPL_LINK:=-lglfw

$(__FILES):
	@if ![[ $(gcc /dev/null $$(__IMPL_LINK) 2>&1 | grep _start 1>/dev/null ; echo ?) -eq 0 ]]; then
		echo "$(__FILES) not installed, please check your package manager"
	else
		echo "$(__FILES) are all checked"
	fi
