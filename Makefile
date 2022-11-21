.PHONY: default
default:
	@echo "No default target; see 'deploy' target"

.PHONY: deploy
deploy:
	podman build . --tag den_dash_server
	podman save -o den_dash_server.tar localhost/den_dash_server:latest
	scp den_dash_server.tar dendash.case.edu:~
	rm den_dash_server.tar
	ssh dendash.case.edu "podman load -i ~/den_dash_server.tar && rm den_dash_server.tar && systemctl --user stop den-dash-server.service && podman run --env-file /home/simon/den_dash/VARS.env -v /home/simon/den_dash/db/:/var/den_dash/db:rw,U --rm localhost/den_dash_server:latest /app/bin/migrate && systemctl --user restart den-dash-server.service"
