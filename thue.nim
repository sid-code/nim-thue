# compile: nim c -d:release thue
# run: ./thue [flags] program.t

import streams
import strutils
import sequtils
import math

type
  ThueRule = tuple[lhs, rhs: string]
  ThueOption = enum
    thDebug, thRTL, thLTR, thNoNl

  Thue = object
    rules: seq[ThueRule]
    opts: set[ThueOption]
    str: string

  ThueError = object of Exception

const
  Separator = "::="
  InputCommand = ":::"
  OutputPrefix = "~"

proc newThue(str = "", opts: set[ThueOption] = {}): Thue =
  Thue(rules: @[], opts: opts, str: str)

proc readFrom(th: var Thue, stream: Stream) =
  var line: TaintedString = newString(100)
  var lineCounter = 0
  while true:
    inc lineCounter

    if not stream.readLine(line):
      raise newException(ThueError, "rule list left unterminated")

    let stripped = line.strip()
    if stripped.len == 0 or stripped[0] == '#':
      continue

    if line == Separator:
      break
    
    let split = line.split(Separator)
    if split.len != 2:
      raise newException(ThueError, "line $1: malformed rule '$2'".format(lineCounter, line))
    
    let rule = (split[0], split[1])
    th.rules.add(rule)
  
  while true:
    if not stream.readLine(line):
      raise newException(ThueError, "no start string after rule list")

    let stripped = line.strip()
    if stripped.len == 0:
      continue
    else:
      break

  th.str = line

proc ruleMatches(th: Thue, rule: ThueRule): bool =
  rule.lhs in th.str

proc applyRule(th: var Thue, rule: ThueRule) =
  let rhs = rule.rhs
  var replacement: string
  if rhs == InputCommand:
    replacement = stdin.readLine()
  elif rhs.startsWith(OutputPrefix):
    stdout.write(rhs.substr(1))
    if thNoNL notin th.opts or rhs.len == 1:
      stdout.write("\n")

    replacement = ""
  else:
    replacement = rhs


  th.str = th.str.replace(rule.lhs, replacement)

randomize()

proc step(th: var Thue): bool =
  var matches = th.rules.filterIt(th.ruleMatches(it))
  if matches.len == 0:
    return false
  
  var rule: ThueRule
  if thLTR in th.opts:
    rule = matches[0]
  elif thRTL in th.opts:
    rule = matches[^1]
  else:
    rule = matches[random(matches.len)]

  if thDebug in th.opts:
    echo "Applying rule: ", rule.lhs, "::=", rule.rhs

  th.applyRule(rule)
  if thDebug in th.opts:
    echo "Tape reads: ", th.str
  return true
    

when isMainModule:
  import parseopt2
  var filename = ""
  var th = newThue()

  for kind, key, val in getopt():
    case kind:
      of cmdArgument:
        filename = key
      of cmdShortOption, cmdLongOption:
        case key:
          of "d", "debug":
            incl th.opts, thDebug
          of "r", "right-to-left":
            excl th.opts, thLTR
            incl th.opts, thRTL
          of "l", "left-to-right":
            excl th.opts, thRTL
            incl th.opts, thLTR
          of "nn", "no-newlines":
            incl th.opts, thNoNL
          else:
            stderr.write("Unexpected option: '", key, "'\n")
            quit 1
      of cmdEnd: assert(false)

  if filename.len == 0:
    stderr.write("filename expected\n")
    quit 1

  let stream = if filename == "STDIN": newFileStream(stdin) else: newFileStream(filename)
  if isNil(stream):
    stderr.write("file '", filename, "' doesn't exist\n")
    quit 1

  th.readFrom(newFileStream(filename))

  while th.step():
    if thDebug in th.opts:
      discard stdin.readLine()
    discard
