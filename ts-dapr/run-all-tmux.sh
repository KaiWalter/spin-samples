#!/bin/bash
tmux split-window "./run.sh distributor"
tmux split-window "./run.sh receiver-express"
tmux split-window "./run.sh receiver-standard"
