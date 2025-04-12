ps aux | grep "cs2 -dedicated" | awk '{print $2}' | xargs kill
