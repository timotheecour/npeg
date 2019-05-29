
import strutils
import tables

# Some constants with "sane" values - these will have to be made configurable one day

const
  PATT_LEN_MAX* = 4096
  INLINE_MAX_LEN* = 50
  RETSTACK_MAX* = 1024
  BACKSTACK_MAX* = 1024


type

  NPegException* = object of Exception
  
  CapFrameType* = enum cftOpen, cftClose
  
  CapKind* = enum
    ckStr,          # Plain string capture
    ckJString,         # JSON string capture
    ckJInt,         # JSON Int capture
    ckJFloat,       # JSON Float capture
    ckJArray,       # JSON Array
    ckJObject,      # JSON Object
    ckJFieldFixed,  # JSON Object field with fixed tag
    ckJFieldDynamic,# JSON Object field with dynamic tag
    ckAction,       # Action capture, executes Nim code at match time
    ckClose,        # Closes capture

  CapFrame* = tuple
    cft: CapFrameType
    si: int
    ck: CapKind
    name: string

const npegTrace* = defined(npegTrace)



proc subStrCmp*(s: string, slen: int, si: int, s2: string): bool =
  if si > slen - s2.len:
    return false
  for i in 0..<s2.len:
    if s[si+i] != s2[i]:
      return false
  return true


proc subIStrCmp*(s: string, slen: int, si: int, s2: string): bool =
  if si > slen - s2.len:
    return false
  for i in 0..<s2.len:
    if s[si+i].toLowerAscii != s2[i].toLowerAscii:
      return false
  return true


type

  TwoWayTable*[X,Y] = ref object
    x2y: Table[X, Y]
    y2x: Table[Y, X]

  Symtab* = TwoWayTable[string, int]

proc newTwoWayTable*[X,Y](): TwoWayTable[X,Y] =
  new result
  result.x2y = initTable[X, Y]()
  result.y2x = initTable[Y, X]()

proc add*[X,Y](s: TwoWayTable[X,Y], x: X, y: Y) =
  s.x2y[x] = y
  s.y2x[y] = x

proc contains*[X,Y](s: TwoWayTable[X,Y], y: Y): bool =
  return y in s.y2x

proc contains*[X,Y](s: TwoWayTable[X,Y], x: X): bool =
  return x in s.x2y

proc get*[X,Y](s: TwoWayTable[X,Y], y: Y): X =
  return s.y2x[y]

proc get*[X,Y](s: TwoWayTable[X,Y], x: X): Y =
  return s.x2y[x]

