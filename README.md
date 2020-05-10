<img align="right" src="README.md.d/worms-lowres.gif">

# Tandy-Terminfo
Tandy Model 100, 102, 200 Terminfo for screen control on UNIX machines

## What is this?

When using the TELCOM terminal program on a Tandy portable computer
such as the Model 200, the remote host needs to know how to send
escape sequences to do things like clear the screen, move the cursor,
show text in reverse, and so on. In UNIX, that information is stored
in the TERMINFO database and then used by setting the TERM environment
variable.

This repository provides both the [source TERMINFO](tandy.terminfo)
file and the [compiled versions](.terminfo/t/).

## Installation

Download the [source TERMINFO](tandy.terminfo) file and compile it
with `tic` on your UNIX host.

    tic tandy.terminfo
    
That will create the proper files in your `.terminfo` directory so
they can be used immediately.

## Usage

Set your TERM environment variable to one of the available terminal
types (see below) to inform programs how to talk to your Tandy. For
example,

    export TERM=td200
    
There are different terminal types for the Model 100 (`td100`) and the
Model 200 (`td200`) as those have a different number of lines.

<img src="README.md.d/labelbutton.jpg" align="right">
There are also different types depending upon whether you have your
status line ("labels") disabled or not. By default it is presumed you
will disable the status line by pressing the LABEL button. If you do
not wish to disable the status line, use the `-s` variant, like so,

    export TERM=td200-s
    
For convenience, there are aliases so you can refer to the TERM by
number of lines instead of whether it has a status line (`td200-15`).

## The list of available terminals

* `td200`: Tandy Model 200 (no status line). 40 columns x 16 rows.
  Aliases: `td200-ns`, `td200-16`.
* `td200-s`: Tandy Model 200 (has status line). 40 columns x 15 rows.
  Alias:`td200-15`.
* `td100`: Tandy Model 100 (no status line). 40 columns x 8 rows.
  Aliases: `td100-ns`, `td100-8`
* `td100-s`: Tandy Model 100 (has status line). 40 columns x 7 rows.
  Alias: `td100-7`
* `td102`: Tandy Model 102 (no status line). 40 columns x 8 rows.
  Aliases: `td102-ns`, `td102-8`
* `td102-s`: Tandy Model 102 (has status line). 40 columns x 7 rows.
  Alias: `td102-7`

## Testing

You can test whether it worked by pressing Control-L. If it clears the
screen, then you have correctly installed the TERMINFO files. You can
also try running a `curses` program, such as the BSD game "worms"
which animates ASCII worms crawling on your screen. (`apt install
bsdgames`).

## Suggestions

While setting the `TERM` environment variable will get you most of the
way to a usable interface, there are some other commands which I
recommend running when using a Tandy portable as a terminal. You can
put these in your `.bash_profile` so they'll be sourced when you login
or you can put them in a file and use `source filename` to read the
commands into your current shell.

### td200 or .bash_profile

Here is a shell script, [td200](td200),
which configures the teminal and sets
up workarounds for some programs.
Because it sets environment variables,
you must source it by `source td200` or
`. td200`.

    # Set terminal type to Tandy 200
    export TERM=td200
    # Send ASCII, not Unicode UTF-8 chars
    export LANG=C
    # Reset the terminal (turns off labels)
    reset
    # Turn on software flow control (^S/^Q)
    stty ixon ixoff
    # Some apps ignore the size in TERMINFO
    stty rows 16 cols 40
    # Backspace key sends ^H not ^?
    stty erase ^H
    # Right arrow key sends ^\, so don't use that to abort and dump core.
    stty quit undef

    # Workarounds
    export MANPAGER=more
    export MANWIDTH=40
    export GCC_COLORS=""
    alias nano="nano -Op"
    alias w3m="w3m -color=0"

    if [ $SHLVL -gt 1 ]; then
      echo "Error, do not run this script."
      echo "It must be sourced, like so:"
      echo -ne "\n\t"
      if type $(basename $0)>/dev/null 2>&1
      then
        echo ". $(basename $0)"
      else
        echo "source $0"
      fi
      echo
      exit 1
    fi

Tip 1: If you put the `td200` program
in your PATH and make it executable,
you can source it without specifying
the full path. For example, `. td200` .

Tip 2: You can automatically source the
td200 script from your .bash_profile
automatically when logging in from a
serial port like so:

    # If logging in from a serial console,
    # it's my Tandy 200 Portable Computer.
    if [[ $(tty) =~ /dev/tty(S|ACM) ]]
    then
       source $HOME/bin/td200
    fi

### .inputrc for arrow keys

I also recommend adding the following
to your `.inputrc` so that the arrow
keys will work in Bash and other
programs that use libreadline.

	$if term=td200
	    Control-^: previous-history
	    Control-_: next-history
	    Control-]: backward-char
	    # Use 'stty quit undef' to make right arrow work.
	    Control-\: forward-char
	    # Shift + BkSp to delete next char.
	    "\d": delete-char
	$endif

### .emacs for flow control

Emacs by default uses C-s for search. You can tell emacs that the
td200 will be using C-s for XON/XOFF flow control by adding this to
your .emacs file:

	;; Tandy 200/100/102 requires
	;; XON/XOFF flow control.
	(enable-flow-control-on "td200" "td100" "td102")


## Problems

* If you have trouble with the screen occasionally scrolling, be sure
  you have the status line turned off by pressing the LABEL button.

* If you are trying to use the arrow keys, many applications will not
  accept them because Tandy's TELCOM program sends them as simple
  control-key characters instead of escape sequences.

        key_up=^^, key_down=^_,
        key_left=^], key_right=^\,

  However, see the workaround above for Bash and other readline programs.

* If control-L clears the screen, but certain programs show
  uninterpreted escape sequences (e.g., `0;m`), then the problem is
  that those programs are not using TERMINFO. They are instead
  presuming there is only one kind of terminal and implementing the
  escape sequences themselves which not only is redundant work, it is
  incorrect.

### Reportedly buggy programs

  * man (workaround, `export PAGER=more`)
  * bash's PS1 prompt, tab completion when ambiguous
  * gcc error messages (workaround, `export GCC_COLORS=""`)
  * w3m colors (workaround `w3m -color=0` or use **O**ptions to set
    *Display With Color* to 0)
  * w3m disables flow control (workaround, w3m-mode in emacs works fine) 
  * git (workaround, disable ANSI color using `git config --add color.ui false`)
  * nano mumbles about XON/XOFF 
	(workaround, `nano -p` or `set preserve` in .nanorc)
  * apt
  * pacman
  * ssh disables flow control (workaround, see below).

  You can test if an application is indeed buggy by running `xterm -ti
  vt52 -tn vt52`. If that terminal shows the same errors as on your
  Tandy 200 (or Model 100), then it is the program that is at fault
  and you should file a bug report with that project. On the other
  hand, if vt52 works (does not show escape sequences), please file a
  bug with this project. (Bug reports are always appreciated.)

## Notes on using the TELCOM program

* For a standard serial port @9600 baud, type this command in TELCOM:

    stat 88n1enn

* 19200 bps works fine if your UNIX getty is configured to talk that speed:

    stat 98n1enn

* Software flow control (XON/XOFF) is absolutely necessary as the 8250
  UART has a one byte buffer.

* Hardware flow control (RTS/CTS) is not available.

* Because `ssh` disables flow control, it will often have garbage
  shown on the screen. A workaround is to login from another terminal
  on the local host after ssh has started and run:
 
      stty -F /dev/ttyS0 ixoff

  (Where `ttyS0` is the name of the serial port you are logging in from.)
 
* To connect to a PC running UNIX, you'll need a null modem cable.

* The Tandy Model 200 has a *FEMALE* 25 pin RS-232c port. 

### Special keys:

    \    GRPH -          Backslash
    |    GRPH SHIFT _    Pipe
    `    GRPH [          Backtick
    ~    GRPH SHIFT ]    Tilde
    {    GRPH 9          Open curly brace
    }    GRPH 0          Close curly brace
    ^@   GRPH P          Sends 0x80, useful in Emacs to set the mark 

Note that Tandy docs say CTRL-@ is supposed to work, but it does not.

## Enabling a serial login on Unix systems with systemd and agetty

If you have a UNIX box running `systemd`, such as Debian GNU/Linux,
you can enable a serial port login like so:

    systemctl enable serial-getty@ttyS0
    systemctl start serial-getty@ttyS0

Presuming you have a serial port on `ttyS0`, of course. If you have a
USB to serial converter, try `ttyACM0`.

### Optional: allow different baud rates

The default baud rates should work with the Tandy portables as 9600 is
one of the standard ones. However, I wanted to allow both higher and
lower speeds as I use different terminals.

There may be a way to change the baud rates accepted using systemd,
but I don't know it. What I did is copy over the symlink that `enable`
created, made a symlink to it because systemd is persnickety, and then
edited the file by hand.

    cd /etc/systemd/system/getty.target.wants/
    rm serial-getty@ttyS0.service
    cp /lib/systemd/system/serial-getty@.service serial-getty@ttyS0.service.real
    ln -s serial-getty@ttyS0.service.real serial-getty@ttyS0.service
    emacs serial-getty@ttyS0.service

If you set the baud rate to multiple values, the agetty program will
switch to the next one, if it's at the wrong speed, whenever you hit
the ENTER key. For example, you could use the following:

    ExecStart=-/sbin/agetty 115200,19200,9600,300 %I $TERM

When you connect with your Tandy portable, you'll see some garbage
characters instead of a Login prompt because it is talking at 115,200
bps. When you hit Enter, it'll try again at 19200. If you still get
line noise, hit Enter once more for 9600. (There is no harm in hitting
Enter too many times as it won't change baud rate when it is correctly
detected.)

## Further Reading

* terminfo(5) - terminal capability data base
* tic(1) - the TERMINFO entry-description compiler
* infocmp(1) - compare or print out TERMINFO descriptions
* [Tandy 200 TELCOM manual](https://archive.org/details/Telcom_for_Tandy_200_1985_Microsoft)
  Particularly:
  * [Table of Escape Sequence Codes](https://archive.org/details/Telcom_for_Tandy_200_1985_Microsoft/page/n48/mode/1up)
  * [TERMCAP for use with Microsoft Xenix](https://archive.org/details/Telcom_for_Tandy_200_1985_Microsoft/page/n40/mode/1up):

## Table of Escape Sequences

Here are the escape sequences which my Tandy 200 responds to.

Sequence | Meaning | Notes
---------|---------|------
 \eA     | cursor Up
 \eB     | cursor Down | ^J may be equivalent.
 \eC     | cursor Right
 \eD     | cursor Left | ^H may be equivalent.
 \eE     | clear screen | \ej may be equivalent, undocumented in [TELCOM manual](https://archive.org/details/Telcom_for_Tandy_200_1985_Microsoft/page/n48/mode/1up), but this is what the sample TERMCAP in the same manual actually uses.
 \eH     | cursor home
 \eI     | type answerback id | Types **"#RSM200"** on my Radio-Shack Model 200.
 \eJ     | clear to the end of screen
 \eK     | clear to the end of line
 \eL     | insert line
 \eM     | delete line
 \eP     | cursor normal
 \eQ     | cursor invisible
 \eR     | restore saved line | _not documented,_ currently used by dsl to restore status line.
 \eS     | save current line | _not documented,_ currently used by dsl to save status line.
 \eT     | enable status line | used in init for variants which have a status line (e.g. td200-s).
 \eU     | disable status line | used in init_1string for variants which have no status line (e.g. td200).
 \eV     | disable scrolling | _not used,_ not defined by terminfo. (Was this ever useful?)
 \eW     | enable scrolling | used in init_2string for `reset`.
 \eY     | Move to cursor address *r,c* | cursor_address=\eY%p1%' '%+%c%p2%' '%+%c <br/> Row and column are sent as single bytes which start at 32 (ASCII space) for zero.
 \ej     | Clear screen | _not used,_ \eE is the same
 \el     | Clear line | _not used,_ terminfo does not define this function. Unlike Delete line (\eM), this does not close the gap by moving lines up.
 \ep     | Inverse text
 \eq     | Normal text
 \er     | mystery! | _not used._ Erases current line and displays **"7A tua"** on my Tandy 200.

### Comparison with VT52

The TELCOM manual claims the terminal is DEC VT52 compatible, but that
seems [approximate](compare.vt52). While the cursor movement and
screen clearing are the same, it is just different enough to cause
problems.

1. Perhaps most noteworthy is that TELCOM uses one of the escape
sequences, \eI, the VT52's scroll_reverse, for a completely different
purpose. So, if you are editing a file with `TERM=vt52` and you scroll
back, your Tandy portable will muck up the screen and type its
"Answerback ID" into your file.

1. Additionally, the sequences expected for the arrow keys have been
redefined to control characters. This is rather inconvenient as those
control characters were already used for other things and it is a
rather questionable decision to redefine them. I would bet dollars to
donuts that Radio-Shack came up with this kludge after writing a
program that sends exactly one byte for each key and only realizing at
the last minute that it's not always true.

1. A final downside of using the VT52 terminfo file is that extra
capabilities that TELCOM has will not be used: reverse mode, delete
line, toggle status line, and hide cursor.

The only feature which the VT52 sported that TELCOM does not support
(yet!) is Alternate Character Set mode for box drawing and glyphs. I
am currently working on figuring out if I can add 8-bit codes to the
terminfo file so I can use Tandy's Extended ASCII. (See TODO below).

## History

This started out as a woefully inadequate TERMCAP entry for
Microsoft's Xenix in the back of the TELCOM manual. (Yes,
Microsoft had their own flavor of UNIX back then. And you could buy it
at Radio Shack on their [TRS-80 Model 16](https://archive.org/details/RSC-09_Computer_Catalog_1983_Radio_Shack/page/n3/mode/1up)
computer). Just for historical interest, [here](orig.termcap) is the
original Tandy 16/Xenix termcap entry from [page 72 of the TELCOM Manual](https://archive.org/details/Telcom_for_Tandy_200_1985_Microsoft/page/n40/mode/1up):

    n1|td200|Tandy 200:\
      :am:bs:xt:co#40:li#16:al=\EL:dl=\EM:cd=^L:ce=\EK:cl=\EE:cm=\EY%+ %+ :\
      :nd=^\:dn=^_:up=\EA:se=\Eq:so=\Ep:kl=^J:kr=^^:ku=^^:kd=^_:

### Differences 

Using captoinfo we can convert the above entry to
[terminfo](orig.terminfo) and compare it to [the current
terminfo](tandy.terminfo) for this project.

	$ infocmp -L -d origtd200 td200 | tr , : | column -t -s:
	comparing origtd200 to td200.
		comparing booleans.
			auto_left_margin        F       T.
			xon_xoff                F       T.
		comparing numbers.
			init_tabs               NULL    8.
		comparing strings.
			clr_eos                 '^L'   '\EJ'.
			cursor_down             '^_'   '\EB'.
			cursor_home             NULL   '\EH'.
			cursor_invisible        NULL   '\EQ'.
			cursor_left             '^H'   '\ED'.
			cursor_normal           NULL   '\EP'.
			cursor_right            '^\'   '\EC'.
			dis_status_line         NULL   '\EU\EY0 \ES\EM'.
			enter_reverse_mode      NULL   '\Ep'.
			exit_attribute_mode     NULL   '\Eq'.
			init_1string            NULL   '\EU'.
			init_2string            NULL   '\EW\Eq\EE'.
			key_left                '\n'   '^]'.
			key_right               '^^'   '^\'.

## Future

This will hopefully eventually be added to the official TERMINFO
databases used by BSD and GNU/Linux systems, but it'd be good to find
out all the undocumented features before doing that. (See Questions
and TODO below).

## Implementation Notes

* What Tandy calls "LABELS" I call a
  "Status Line" because in terminfo
  parlance "Soft Labels" is for text
  above reprogrammable Function keys.
  From a Unix program's perspective,
  the Tandy Function keys are
  immutable. While "Status Line" is
  not quite correct as it doesn't
  show any status, it is more correct
  than the alternatives.

* Terminfo allows codes to overwrite
  the status line using tsl/fsl. We
  could implement tsl, but I don't
  see how we'd define fsl which is
  supposed to pop back to the
  previous cursor location. Since
  ncurses never uses tsl/fsl, there's
  probably no point in trying.

  For anyone who cares to try, the
  following will overwrite your
  status line for one second and then
  restore it.

	  echo $'\eU\eY0 \eS\eM'$(date)$'\eT'
	  sleep 1
	  echo $'\eU\eY0 \eR\eT'

* Why I overloaded dsl:

  Terminfo doesn't support enabling status lines. It can, however,
  disable them with "dsl". I used dsl in this normal way for the
  terminal types without a status line (e.g., `td200`).

  However, I made a kludge that I think actually works pretty well:
  the "dsl" sequence for variants _with_ status lines actually enables
  it. I think terminfo should either add "*enable*_status_line" or just
  let dsl mean "*default*_status_line": do the right thing for this
  terminal.

  Just for fun, my dsl strings also
  save and restore the labels in the
  status line using the undocumented
  \eS and \eR escape sequence. This
  works to properly turn off the
  status line then to re-enable it on 
  my Tandy 200 (but I have not tested
  a Model 100 or 102):

      $ TERM=td200
      $ tput dsl
      $ TERM=td200-s
      $ tput dsl

  By default, the Tandy terminals do
  *not* rewrite the last line of the
  screen when the status line is
  enabled with an escape sequence. That
  means you would not get back the line
  that says "Prev Down Up Full". 

* Reminder to self: although scroll backward can be faked with HOME,
  Insert Line (\eH\eL), there's no point in doing it since ncurses
  is smart enough to do it for us.

* The `td200` entry defaults to presuming the status line is _off_
  (which is the preferred way to use it), not _on_ (which is how the
  TELCOM software always starts up).


## Questions

* Is it possible to read the Function keys? 

* Eight bit codes show up as graphics characters, but they are not in
  Latin-1 order. Is there something that can be done about that? It'd
  be nice to have umlauts and such. What is easiest: hacking the
  TELECOM binary, writing a C program to create a PTY and translate
  character by character, or create a "locale charmap"?

* Do all escape sequences (including the undocumented ones) work the
  same on a Model 100? 

## TODO

* Figure out why man pages have `\e[m` sent at the end of each line,
  but *only* when my PAGER is `less`. Note that `nroff | less` doesn't
  have the same problem.

* Maybe report bugs to projects which presume ANSI colors are always
  available. Why don't programs like `git` link with ncurses?
  
* Investigate creating a new charmap for locale. (See `locale -m` and
  `locale(1)`)

* Maybe get cursor keys working in Emacs.

  Cursor keys work in vi, but not in Emacs. Emacs is doing something
  clever to get around xon/xoff brain damage. Right (^]) takes over
  for Search Forward (normally ^S) and Up (^^) is bound to quote next
  character (usually ^Q). This is actually kind of handy for me since
  I never use the arrow keys. I just wish they had bound one of the
  others to run Help, since that is missing as ^H.

* Implement VT100 line drawing characters. It looks like they exist
  in the Model 100 characterset, so we just need to create the `acsc`
  capability and set `smacs` and `rmacs` to the empty string. (See
  Line Graphics below).

### Line Graphics (verbatim from the terminfo(5) manpage)

  Many terminals have alternate character sets useful for
  forms-drawing. Terminfo and curses build in support for the drawing
  characters supported by the VT100, with some characters from the
  AT&T 4410v1 added. This alternate character set may be specified by
  the `acsc` capability.

      Glyph                           ACS                Ascii         VT100
      Name                            Name               Default       Name
      UK pound sign                   ACS_STERLING       f             }
      arrow pointing down             ACS_DARROW         v             .
      arrow pointing left             ACS_LARROW         <             ,
      arrow pointing right            ACS_RARROW         >             +
      arrow pointing up               ACS_UARROW         ^             -
      board of squares                ACS_BOARD          #             h
      bullet                          ACS_BULLET         o             ~
      checker board (stipple)         ACS_CKBOARD        :             a
      degree symbol                   ACS_DEGREE         \             f
      diamond                         ACS_DIAMOND        +             `
      greater-than-or-equal-to        ACS_GEQUAL         >             z
      greek pi                        ACS_PI             *             {
      horizontal line                 ACS_HLINE          -             q
      lantern symbol                  ACS_LANTERN        #             i
      large plus or crossover         ACS_PLUS           +             n
      less-than-or-equal-to           ACS_LEQUAL         <             y
      lower left corner               ACS_LLCORNER       +             m
      lower right corner              ACS_LRCORNER       +             j
      not-equal                       ACS_NEQUAL         !             |
      plus/minus                      ACS_PLMINUS        #             g
      scan line 1                     ACS_S1             ~             o
      scan line 3                     ACS_S3             -             p
      scan line 7                     ACS_S7             -             r
      scan line 9                     ACS_S9             _             s
      solid square block              ACS_BLOCK          #             0
      tee pointing down               ACS_TTEE           +             w
      tee pointing left               ACS_RTEE           +             u
      tee pointing right              ACS_LTEE           +             t
      tee pointing up                 ACS_BTEE           +             v
      upper left corner               ACS_ULCORNER       +             l
      upper right corner              ACS_URCORNER       +             k
      vertical line                   ACS_VLINE          |             x

  The best way to define a new device's graphics set is to add  a  column
  to  a  copy of this table for your terminal, giving the character which
  (when emitted between smacs/rmacs switches) will  be  rendered  as  the
  corresponding graphic.  Then read off the VT100/your terminal character
  pairs right to left in sequence; these become the ACSC string.

### Alternate Character Set (Verbatim from termcap(5) manpage)

       The block graphic characters can be specified by three string capabili‐
       ties:

       as     start the alternative charset

       ae     end the alternative charset

       ac     pairs  of  characters.   The  first character is the name of the
              block graphic symbol and the second characters  is  its  defini‐
              tion.

       The following names are available:

       +    right arrow (>)
       ,    left arrow (<)
       .    down arrow (v)
       0    full square (#)
       I    lantern (#)
       -    upper arrow (^)
       '    rhombus (+)
       a    chess board (:)
       f    degree (')
       g    plus-minus (#)
       h    square (#)
       j    right bottom corner (+)
       k    right upper corner (+)
       l    left upper corner (+)
       m    left bottom corner (+)
       n    cross (+)
       o    upper horizontal line (-)
       q    middle horizontal line (-)
       s    bottom horizontal line (_)
       t    left tee (+)
       u    right tee (+)
       v    bottom tee (+)
       w    normal tee (+)
       x    vertical line (|)
       ~    paragraph (???)

       The  values in parentheses are suggested defaults which are used by the
       curses library, if the capabilities are missing.


