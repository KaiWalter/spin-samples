#!/bin/bash
tmux split-window "./run-instance.sh distributor"
tmux split-window "./run-instance.sh receiver-express"
tmux split-window "./run-instance.sh receiver-standard"
tmux selectl even-vertical
