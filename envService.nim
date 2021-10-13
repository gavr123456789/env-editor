import os, strutils, strformat
import unpack, print

const PATH = "PATH"

type 
  EnvVar = tuple
    line: int
    value: string
    key: string
    isPath: bool
  EnvVars = seq[EnvVar]

proc toString(env: EnvVars): string =
  for x in env:
    if x.isPath:
      result.add fmt"set {x.key} {x.value} $PATH"
    else:
      result.add fmt"set {x.key} {x.value}"
    result.add "\n"



proc getFishPath: string = getHomeDir() / ".config" / "fish" / "config.fish"

proc getFishEnv(): EnvVars =
  var fileContentLines = getFishPath().readFile.split "\n"
  for i, line in fileContentLines:
    if line == "": break
    [_, k, v] <- line.split " "
    result.add (line: i, value: v, key: k, isPath: k==PATH)

proc addKV(env: var EnvVars, k, v: string) =
  env.add (line: env.high + 1, value: v, key: k, isPath: k==PATH)
  
proc writeFishEnv(env: EnvVars) =
  let fishConfigFile = getFishPath()
  writeFile(fishConfigFile, env.toString)

when isMainModule:
  var x = getFishEnv()
  print x
  # x.addKV("Sas", "sud")
  # x.addKV("PATH", "sud")
  # print x
  # writeFishEnv x
  
  # for a in envPairs():
  #   print a