# Escape sequence comparison 

DEC VT52 and Heath H19 terminals use escape codes similar to the Model
T computers. But are they similar enough that one could use such a
terminal as a screen? This table lists all the escape codes and
whether the code is recognized by an H19 or VT52. If it is not
recognized, but an equivalent exists for that terminal, then the
equivalent is listed. 

In the tables below, '\e' stands for <kbd>Esc</kbd>.

## Output escape sequences

| Sequence | Meaning (on a Model T)       | H19  | VT52   |
|----------|------------------------------|------|--------|
| \eA      | cursor Up                    | [x]  | [x]    |
| \eB      | cursor Down                  | [x]  | [x]    |
| \eC      | cursor Right                 | [x]  | [x]    |
| \eD      | cursor Left                  | [x]  | [x]    |
| \eE      | clear screen                 | [x]  | \eH\eJ |
| \eH      | cursor home                  | [x]  | [x]    |
| \eJ      | clear to the end of screen   | [x]  | [x]    |
| \eK      | clear to the end of line     | [x]  | [x]    |
| \eL      | insert line                  | [x]  |        |
| \eM      | delete line                  | [x]  |        |
| \eP      | cursor normal                | \ey5 |        |
| \eQ      | cursor invisible             | \ex5 |        |
| \eT      | enable status line           |      |        |
| \eU      | disable status line          |      |        |
| \eV      | disable scrolling            | \e[  |        |
| \eW      | enable scrolling             | \e\  |        |
| \eY      | Move to cursor address *r,c* | [x]  | [x]    |
| \ej      | Clear screen (alias)         | \eE  | \eH\eJ |
| \el      | Clear line                   | [x]  |        |
| \ep      | Reverse text                 | [x]  |        |
| \eq      | Normal text                  | [x]  |        |

## Input escape sequences

The Model T computers do not define keys the same way as VT52/H19. In
fact, they always send a single byte (a control character), not an
escape sequence.

| Sequence | Meaning (on a Model T) | H19 and VT52 |
|----------|------------------------|--------------|
| ^^       | Arrow Up               | \eA          |
| ^_       | Arrow Down             | \eB          |
| ^\       | Arrow Right            | \eC          |
| ^]       | Arrow Left             | \eD          |



## Unusual escape sequences 

These escape sequences are recognized sometimes, but in such limited
circumstances that it wouldn't matter if a terminal did not support
them.

| Sequence | Model T Meaning                       | Where available |
|----------|---------------------------------------|-----------------|
| \eI      | type answerback id                    | TELCOM          |
| \eR      | restore saved line from first buffer  | Tandy 200       |
| \eS      | save current line to first buffer     | Tandy 200       |
| \er      | restore saved line from second buffer | Tandy 200       |
| \es      | save current line to second buffer    | Tandy 200       |
