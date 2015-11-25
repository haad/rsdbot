# Description:
#   Prints log of hubot
# 
# Dependencies:
#
# Configuration:
#
# Commands:
#   hubot show <n> lines of log
#
# Author:
#   kuboj

run_cmd = (cmd, args, callBack) ->
  spawn = require('child_process').spawn;
  child = spawn(cmd, args);
  resp = "";

  child.stdout.on('data', (buffer) -> resp += buffer.toString());
  child.stdout.on('end', -> callBack(resp));

module.exports = (robot) ->
  robot.respond /show (\d+) lines of log$/, (res) ->
    run_cmd("tail", ["-n", res.match[1], process.env.LOG_PATH], (s) -> res.send("```#{s}```") );
